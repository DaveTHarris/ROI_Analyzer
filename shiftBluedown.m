function [ handles ] = shiftBluedown( handles )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
image=handles.imgdata;
zslices=size(image,4);
duration=size(image,3);


image2=handles.imgdata2;
assignin('base','image2',image2);
zslices2=size(image2,4);
duration2=size(image2,3);
image3=image2;
for i = 1:duration2
   for j = 2:zslices2
     
       image3(:,:,i,j-1)=image2(:,:,i,j);
       
    
    image3(:,:,i,j)=uint16(zeros(512,512));
   end
   % image3(:,:,i,:)=image3(:,:,i,1:duration);
    
    
end
assignin('base','image3',image3);
handles.imgdata2=image3;

end

