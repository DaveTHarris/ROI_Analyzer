function [ blurImage ] = fijiGaussian( image, sigma )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
G = fspecial('gaussian',[5 5],sigma);
blurImage = imfilter(image,G);

end

