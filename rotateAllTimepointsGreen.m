function [ handles ] = rotateAllTimepointsGreen( handles,rot )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
 for i = 1:size(handles.imgdata,3)
    A=handles.imgdata(:,:,i,Z);
    %assignin('base','moving',moving);
    A = imrotate(A,rot,'nearest','crop');
 
    handles.imgdata(:,:,i,Z)=A;
 end
end

