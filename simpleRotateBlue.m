function [ handles ] = simpleRotateBlue( handles,rot )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
 
 A=handles.imgdata2(:,:,T,Z);
%assignin('base','moving',moving);
A = imrotate(A,rot,'nearest','crop');

handles.imgdata2(:,:,T,Z)=A;

end

