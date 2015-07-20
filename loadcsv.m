function [ Markers] = loadcsv( file )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
try
A = importdata(file);
%Markers = A.data;
Markers = A.data;

assignin('base','markers',Markers);
catch
end
end

