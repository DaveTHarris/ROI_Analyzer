function [ Markers] = loadMarkers( file )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
try
A = importdata(file);
%Markers = A.data;
Markers = A.data;
for i = 1:size(Markers,1)
   Markers(i,2)=512-Markers(i,2); 
    
end
assignin('base','markers',Markers);
catch
end
end

