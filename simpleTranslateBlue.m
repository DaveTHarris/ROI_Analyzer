function [ handles ] = simpleTranslateBlue( handles,xTrans,yTrans )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
 
 A=handles.imgdata2(:,:,T,Z);
%assignin('base','moving',moving);
A = imtranslate(A,[xTrans yTrans]);

handles.imgdata2(:,:,T,Z)=A;

end

