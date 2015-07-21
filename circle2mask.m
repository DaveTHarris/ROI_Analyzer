function [ circleMask ] = circle2mask( center, radius, imageSize )


%# circle params
t = linspace(0, 2*pi, radius);   %# approximate circle with 50 points

%# get circular mask
BW = poly2mask(radius*cos(t)+center(1), radius*sin(t)+center(2), imageSize, imageSize);

circleMask = BW;

end

