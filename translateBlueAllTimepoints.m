function [ handles ] = translateBlueAllTimepoints( handles,xTrans,yTrans )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
for i = 1:size(handles.imgdata2,3) 
    A=handles.imgdata2(:,:,i,Z);
    %assignin('base','moving',moving);
    A = imtranslate(A,[xTrans yTrans]);

    handles.imgdata2(:,:,i,Z)=A;
end

end

