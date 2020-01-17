%% Wczytanie pliku

I = imread('img/snow.seq14.png');
%I = imread('img/bright.seq2.png');
%I = imread('img/dark.seq5.png');
I = rgb2gray(I);
kmedian = medfilt2(I);
wiener = wiener2(I, [5 5]);
guided = imguidedfilter(I);

m = 1;
n = 4;

subplot(m,n,1)
imshow(I)
subplot(m,n,2)
imshow(kmedian)
subplot(m,n,3)
imshow(wiener)
subplot(m,n,4)
imshow(guided)

%% Gradient 


[Gmag, Gdir] = imgradient(guided);
Gmag = imopen(Gmag, strel('disk', 1)); % morphology

figure
imshowpair(Gmag, Gdir, 'montage');
title('Sobel')

edges = edge(Gmag);

figure 
imshow(edges)

%% Hough Transform
[H, theta, rho] = hough(edges);



subplot(2,1,1);
imshow(I);
title('Original picture')
subplot(2,1,2);
imshow(imadjust(rescale(H)), 'XData', T, 'YData', R);
title('Hough transform');
xlabel('\theta (degrees)')
ylabel('\rho')
axis on
axis normal 
hold on
colormap(gca,hot);

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'s','color','black');

lines = houghlines(edges,theta,rho,P,'FillGap',5,'MinLength',7);

%% Plot lines

figure, imshow(I), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

    