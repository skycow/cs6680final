% Skyler Cowley
% CS 6680
% Final Project

close all;

%create file handle
v = VideoReader('Road - 1101.mp4');

%read video into a 4-d matrix
vv = v.read();

%part a - roi
cropped = vv(400:700,:,:,70);

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

%part d - adaptive local threshold

minrange = 255/10;

Q0 = ihat;

minpadded = padarray(ihat, [1,1],255);
maxpadded = padarray(ihat, [1,1],0);

for row = 1:size(ihat, 1)
    for col = 1:size(ihat, 2)
       
        P0 = ihat(row,col);
        
        minneighbors = minpadded(row:row+2,col:col+2);
        minneighbors(row,col) = 255;
        maxneighbors = maxpadded(row:row+2,col:col+2);
        maxneighbors(row,col) = 0;
        
        minarr = min(minneighbors(:));
        maxarr = max(maxneighbors(:));
        
        range = maxarr - minarr;
        
        if(range > minrange)
            T = (double(minarr+maxarr))/2;
        else
            T = maxarr - minrange/2;
        end
        
        if(P0 > T)
            Q0(row,col) = 255;
        else
            Q0(row,col) = 0;
        end
    end
end

figure;
imshow(Q0);