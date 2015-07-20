function [ handles ] = shiftAligndown( handles )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


image2=handles.nuclearData;
image3=handles.alignData;
zslices2=size(image2,3);

%assignin('base','image2',image2);

    image4(:,:,1)=uint16(zeros(512,512));    
    image5(:,:,1)=uint16(zeros(512,512));
    
   for j = 2:zslices2
     
       image4(:,:,j-1)=image2(:,:,j);
       image5(:,:,j-1)=image3(:,:,j);
       image4(:,:,j)=uint16(zeros(512,512));
       image5(:,:,j)=uint16(zeros(512,512));
   end
    %image3(:,:,i,:)=image3(:,:,i,1:duration);
    
    

assignin('base','image3',image3);

handles.nuclearData=image4;
handles.alignData=image5;
end

