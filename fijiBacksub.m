function [ backsubImage, background ] = fijiBacksub( image, radius )



%This function mimics the fiji background subtraction method using a
%rolling ball radius method.

h = fspecial('disk', radius);
%h = strel('ball',radius,10,4);
% nhood = h.getnhood;
%nhood = double(nhood);
background = imfilter(image, h);
backsubImage = image-background;
%nhood = fspecial('disk',radius)>0;
% stdDevimage=stdfilt(image,nhood);
% assignin('base','backsubImage',backsubImage);
% assignin('base','stdDevimage',stdDevimage);
%backsubImage=backsubImage./background;
% backsubImage2=backsubImage;
% assignin('base','backsubImage2',backsubImage2);
end

