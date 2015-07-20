function [ handles ] = alignBluetoGreenparallelstack( handles )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 
 axes(handles.imAxes);

image=handles.imgdata;
if handles.stimNum == 2
    image2=handles.imgdata2;
    zslices2=size(image2,4);
    duration2=size(image2,3);
    alignedBlue = zeros(512,512,duration2);
end
%matlabpool('open',4);
zslices=size(image,4);
duration=size(image,3);
alignedGreen=zeros(512,512,duration);
optimizer = registration.optimizer.RegularStepGradientDescent;
optimizer.MaximumIterations = 100;
optimizer.MinimumStepLength = 5e-3;
metric = registration.metric.MeanSquares(); 
alignData=handles.alignData;
nuclearData=handles.nuclearData;

if (get(handles.traG,'Value')== get(handles.traG,'Max'))
    
    for i = 1:zslices

        fixedimage=image(:,:,1,i);
        tic
        for j=1:duration
        alignedGreen(:,:,j) = imregister(image(:,:,j,i),fixedimage,'rigid',optimizer,metric);
        
        end
       toc

    handles.imgdata(:,:,:,i)=alignedGreen;
    end
end


if handles.stimNum == 2
    if (get(handles.traB,'Value')== get(handles.traB,'Max'))

       for i = 1:zslices2 
         fixedImage=image(:,:,1,i);   
         tic
         for j = 1:duration2

            alignedBlue(:,:,j) = imregister(image2(:,:,j,i),fixedImage,'rigid',optimizer,metric);


         end
         toc


         handles.imgdata2(:,:,:,i)=alignedBlue;    
       end
    end 
end
if (get(handles.traR,'Value')== get(handles.traR,'Max'))       
    
     for i = 1:zslices 
            fixedImage=image(:,:,1,i);   
            tic
            Rfixed = imref2d(size(fixedImage));
            tform = imregtform(alignData(:,:,i),fixedImage,'rigid',optimizer,metric);
            alignData(:,:,i) = imwarp(alignData(:,:,i),tform,'OutputView',Rfixed);
            nuclearData(:,:,i) = imwarp(nuclearData(:,:,i),tform,'OutputView',Rfixed);
            toc
     end
    handles.alignData=alignData;
    handles.nuclearData=nuclearData;
 
end 
 

end

