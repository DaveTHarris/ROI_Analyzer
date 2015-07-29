function  savedeltaFstackgraysingleStim1( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

maxZ = str2double(get(handles.maxZEdit,'String'));
minZ = str2double(get(handles.minZEdit,'String'));
%assignin('base','minZ',minZ);
%For Gaussian
%sigma = 1;
[minT, maxT]=getdfofRange(handles);
minDf = str2double(get(handles.minAxis,'String'));
maxDf = str2double(get(handles.maxAxis,'String'));
%For Gaussian


%For background Thresholding
bgThreshold = get(handles.dfofBgThreshSlider, 'Value');

%For Foregound Thresholding
fgThreshold = get(handles.dfofFgThreshSlider, 'Value');
%relFrame = str2num(get(handles.dfofMinTEdit,'String'));

foldername = handles.foldername;
Images = handles.imgdata;


image=handles.deltaFimagedata(:,:,minDf:maxDf,minZ:maxZ);
dfofimage=handles.deltaFoFimagedata(:,:,minDf:maxDf,minZ:maxZ);
%This statement should directly change the lower cutoff
%value for the dfofimage. This should be adjustable by
%the user. The slidervalLow variable does the same
%thing in a modifiable way.
image(dfofimage<.02)=0;
sliderval = get(handles.dfofFgThreshSlider, 'Value');
slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
    


for i = 1:size(image,4)
    for j = 1:size(image,3)
        A = image(:,:,j,i);
        A = fijiGaussian(A,1);
        A = imadjust(A,[slidervalLow sliderval], [0 1]);
        adjimage(:,:,j,i)= A;
    end
end


    mkdir(foldername,'singleDeltaFStim1');
    fullpathname = sprintf('%s/singleDeltaFStim1',foldername);
    finalImg=squeeze(max(adjimage,[],4));
    finalImg=squeeze(max(finalImg,[],3));
     
    
    filename =sprintf('%s/t%03d-%03d_z%03d-%03d.tiff',fullpathname,minDf,maxDf,minZ,maxZ);
    
    %options.color=true;
    %assignin('base','rgbdeltaF',rgbdeltaF);
    saveastiff(finalImg,filename);
    
    
    
    
    
    
end
    
     
         
        
   
    
    
    







   
    





