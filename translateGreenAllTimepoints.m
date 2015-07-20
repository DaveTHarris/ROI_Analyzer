function [ handles ] = translateGreenAllTimepoints( handles,xTrans,yTrans )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
for i = 1:size(handles.imgdata,3) 
    A=handles.imgdata(:,:,i,Z);
    %assignin('base','moving',moving);
    A = imtranslate(A,[xTrans yTrans]);

    handles.imgdata(:,:,i,Z)=A;
end

end

