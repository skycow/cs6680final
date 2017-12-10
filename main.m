% Skyler Cowley
% CS 6680
% Final Project

close all;

%create file handle
v = VideoReader('Road - 1101.mp4');

%read video into a 4-d matrix
vv = v.read();

%part a - roi
imgidx = 71;
cropped = vv(400:700,:,:,imgidx);

figure;
imshow(cropped);

%part b - pre-processing

%ihat = cropped(:,:,1);

% for row = 1:size(cropped, 1)
%     for col = 1:size(cropped, 2)
%         ihat(row,col) = (cropped(row,col,1) + ...
%         cropped(row,col,2) + ...
%         cropped(row,col,3))/3;
%     end
% end

ihat = rgb2gray(cropped);

figure;
imshow(ihat);

%part c - temporal blur

avgimg = double(ihat);
N = 6;

for frame = (imgidx):(imgidx+N)
    fprintf("frame %d\n",frame);
    avgimg = avgimg + double(rgb2gray(vv(400:700,:,:,frame)));
end
avgimg = avgimg/(N+1);

ihat = uint8(avgimg);

figure;
imshow(ihat);

%part d - adaptive local threshold

%changed 10 -> 20
minrange = 255/20;

Q0 = ihat;

minpadded = padarray(ihat, [1,1],255);
maxpadded = padarray(ihat, [1,1],0);

for row = 1:size(ihat, 1)
    for col = 1:size(ihat, 2)
       
        P0 = ihat(row,col);
        
        minneighbors = minpadded(row:row+2,col:col+2);
        minneighbors(2,2) = 255;
        maxneighbors = maxpadded(row:row+2,col:col+2);
        maxneighbors(2,2) = 0;
        
        minarr = min(minneighbors(:));
        maxarr = max(maxneighbors(:));
        
        range = maxarr - minarr;
        
        if(range > minrange)
            T = (double(minarr+maxarr))/2;
        else
            T = maxarr - minrange/2;
        end
        
        if(P0 > T)
            Q0(row,col) = 0;
        else
            Q0(row,col) = 255;
        end
    end
end

figure;
imshow(Q0);

Q00 = Q0;

%Q0 = Q0(1:end,430:750);
Q0 = Q0(:,750:end);
figure;
imshow(Q0);

%e

[H,T,R] = hough(Q0,'RhoResolution',2.5,'Theta',-60:0);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');

lines = houghlines(Q0,T,R,P,'FillGap',5,'MinLength',7);
figure, imshow(Q00), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

plot(xy_long(:,1)+750,xy_long(:,2),'LineWidth',2,'Color','cyan');
