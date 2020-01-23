%% Wczytanie pliku

DEBUG = false;

I = imread('images/snow.seq14.png');
%I = imread('images/bright.seq2.png');
%I = imread('images/dark.seq5.png'); % shadow -  hard
%I = imread('images/bright.seq31.png');

I = imresize(I, [240 NaN]);
I = rgb2gray(I);
kmedian = medfilt2(I);
wiener = wiener2(I, [5 5]);
guided = imguidedfilter(I);

m = 1;
n = 4;

if DEBUG == true
    subplot(m,n,1)
    imshow(I)
    subplot(m,n,2)
    imshow(kmedian)
    subplot(m,n,3)
    imshow(wiener)
    subplot(m,n,4)
    imshow(guided)
end

%% Gradient 


[Gmag, ang] = imgradient(guided);
Gmag = imopen(Gmag, strel('disk', 1)); % morphology
edges = edge(Gmag);


% remove small edges (less than 30px)
bedges = bwareaopen(edges,30);

if DEBUG == true
    figure
    imshowpair(bedges, edges, 'montage');
    title('Sobel')
end



%% Hough Transform
edges = bedges;

[H, theta, rho] = hough(edges);
P = houghpeaks(H,30,'threshold',ceil(0.3*max(H(:))));


if DEBUG == true
    subplot(2,1,1);
    imshow(I);
    title('Original picture')
    subplot(2,1,2);
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

lines = houghlines(edges,theta,rho,P,'FillGap',7,'MinLength',15);
figure, imshow(I), hold on
max_len = 0;
h_line = 80;
tol = 10;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   
   % remove lines above horizontal line
   if (xy(1,2) < h_line || xy(2,2) < h_line)
       continue;
   end
   
   % remove almost horizontal lines
   if abs(lines(k).theta) > 45  
      continue;
   end
   
   % remove lines close to center
   if width/2 - tol <= xy(1,1) && xy(1,1) <= width/2 + tol
    continue
   end


   % divide into left, right lanes
   if xy(1,1) <= width/2
       color = 'green';
   else
       color = 'blue';
   end
   
   
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',color);

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'o','LineWidth',1,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',1,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   %{
   disp(xy);
   disp(lines(k).theta);
   pause()
   %}

   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
%plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');


%% INTERPOLATION TEST
%{
X = linspace(0, 200, 20);
Y = randi([3 20], 1, 20);

X1 = linspace(0,200,50);
Y1 = interp1(X,Y,XI);

figure
plot(X,Y)

figure
plot(X1,smooth(Y1))
%}


    