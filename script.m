%% Test kilku na raz

%{
images = {'images/snow.seq14.png','images/bright.seq2.png','images/bright.seq31.png','images/dark.seq5.png'};

m = 4;
n = 4;


for i = 1:length(images)

    I = imread(images{1,i});
    I = imresize(I, [240 NaN]);
    I = rgb2gray(I);
    
    kmedian = medfilt2(I);
    wiener = wiener2(I, [5 5]);
    guided = imguidedfilter(I);
    
    no = i*4-3;
    
    if DEBUG == true
        subplot(m,n,no)
        imshow(I)
        title('original')
        subplot(m,n,no+1)
        imshow(kmedian)
        title('kmedian')
        subplot(m,n,no+2)
        imshow(wiener)
        title('wiener')
        subplot(m,n,no+3)
        imshow(guided)
        title('guided')
    end
end
%}

%% Wczytanie pliku

DEBUG = false;
LINES_LENGTH = 3;
FILL_GAPS = 3;
PEAKS = 15;
HORIZONTAL_LINE = 80; % 80
CENTER_TOLERANCE = 20;
REMOVE = 10;

% 4,8,9,10,11,12,15,16,17,18

listing = dir('images');
i = 5;

path = strcat('images/', listing(i).name);

I = imread(path);


%I = imread('images/snow.seq14.png');
%I = imread('images/bright.seq2.png');
%I = imread('images/bright.seq31.png');
%I = imread('images/dark.seq5.png'); % shadow -  hard

I = imresize(I, [240 NaN]);
I = rgb2gray(I);
m = 1;
n = 4;

kmedian = medfilt2(I);
wiener = wiener2(I, [5 5]);
guided = imguidedfilter(I);

if DEBUG == true
    subplot(m,n,1)
    imshow(I)
    title('original')
    subplot(m,n,2)
    imshow(kmedian)
    title('kmedian')
    subplot(m,n,3)
    imshow(wiener)
    title('wiener')
    subplot(m,n,4)
    imshow(guided)
    title('guided')
end



%% Gradient 


[Gmag, ang] = imgradient(guided);
Gmag = imclose(Gmag, strel('disk', 1)); % morphology

%imshowpair(Gmag, Gmag2, 'montage');


edges = edge(Gmag);

% remove small edges (less than 30px)
bedges = bwareaopen(edges,REMOVE);

if DEBUG == true
    figure
    imshowpair(bedges, edges, 'montage');
    title('Sobel')
end



%% Hough Transform
edges = bedges;

[H, theta, rho] = hough(edges);
P = houghpeaks(H,PEAKS,'threshold',ceil(0.3*max(H(:))));


if DEBUG == true
    subplot(1,2,1);
    imshow(I);
    title('Original picture')
    subplot(1,2,2);
    imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho);
    title('Hough transform');
    xlabel('\theta (degrees)')
    ylabel('\rho')
    axis on
    axis normal 
    hold on
    colormap(gca,hot);
    x = theta(P(:,2));
    y = rho(P(:,1));
    plot(x,y,'s','color','black');
end


%% Plot lines
[height, width, dim] = size(I);

lines = houghlines(edges,theta,rho,P,'FillGap',FILL_GAPS,'MinLength',LINES_LENGTH);
figure, imshow(I), hold on
max_len = 0;
h_line = HORIZONTAL_LINE;
tol = CENTER_TOLERANCE;

left = [];
right = [];

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   
   % remove lines above horizontal line || almost horizontal lines || lines close to center
   if (xy(1,2) < h_line || xy(2,2) < h_line) || (abs(lines(k).theta) > 45) || ...
           (width/2 - tol <= xy(1,1) && xy(1,1) <= width/2 + tol || width/2 - tol <= xy(2,1) && xy(2,1) <= width/2 + tol)  % remove 
       continue;
   end
   
   point.x = xy(1,1);
   point.y = xy(1,2);
   point1.x = xy(2,1);
   point1.y = xy(2,2);

   % divide into left, right lanes
   if xy(1,1) <= width/2
       color = 'green';
       left = [left, point, point1];
   else
       color = 'blue';
       right = [right, point, point1];
   end
   
   
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',color);

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'o','LineWidth',1,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);


   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%plot(center.x,center.y,'x','LineWidth',2,'Color','yellow');
plot([0, width],[h_line,h_line],'LineWidth',1,'Color','red');
plot([width/2-tol, width/2-tol],[0,height],'LineWidth',1,'Color','red');
plot([width/2+tol, width/2+tol],[0,height],'LineWidth',1,'Color','red');


%% Remove wrong points




%% INTERPOLATION TEST
% No need to sorting 
range = linspace(0,240,20);

% LEFT
left_xFit = interpy(left, range);
right_xFit = interpy(right, range);

if DEBUG == true
    figure, imshow(I), hold on
    plot(extractfield(left,'x'), extractfield(left, 'y'), 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'Color', 'green');
    plot(extractfield(right,'x'), extractfield(right, 'y'), 'ro', 'MarkerSize', 8, 'LineWidth', 2);

    plot(left_xFit, range, 'b.-', 'MarkerSize', 15, 'LineWidth', 1);
    plot(right_xFit, range, 'b.-', 'MarkerSize', 15, 'LineWidth', 1);
end

%% BOUNDARY

%{
x = [extractfield(left,'x'), extractfield(right,'x')];
x = x.';
y = [extractfield(left, 'y'), extractfield(right, 'y')];
y = y.';

k = boundary(x,y);

figure, imshow(I), hold on
plot(x(k), y(k))
%}

%% OUTPUT



output = zeros(size(I));

range = linspace(0,240,20);

% LEFT
left_xFit = interpy(left, range);
right_xFit = interpy(right, range);

out = figure; 
subplot(1,2,1)
imshow(I)
subplot(1,2,2)

imshow(output), hold on
%plot(extractfield(left,'x'), extractfield(left, 'y'), 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'Color', 'green');
%plot(extractfield(right,'x'), extractfield(right, 'y'), 'ro', 'MarkerSize', 8, 'LineWidth', 2);

plot(left_xFit, range, 'w-',  'LineWidth', 1);
plot(right_xFit, range, 'w-', 'LineWidth', 1);



pause()
close all


    