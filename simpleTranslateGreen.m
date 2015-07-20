function [ handles ] = simpleTranslateGreen( handles,xTrans,yTrans )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 [T Z] = getTZ(handles);
 
A=handles.imgdata(:,:,T,Z);
%assignin('base','moving',moving);
A = imtranslate(A,[xTrans yTrans]);

handles.imgdata(:,:,T,Z)=A;

end

