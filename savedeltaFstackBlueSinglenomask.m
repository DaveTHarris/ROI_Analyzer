function  savedeltaFstackBlueSinglenomask( handles )
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
%For background Thresholding
%bgThreshold = get(handles.dfofBgThreshSlider, 'Value');

%For Foregound Thresholding
%fgThreshold = get(handles.dfofFgThreshSlider, 'Value');
sliderval = get(handles.dfofFgThreshSlider, 'Value');
slidervalLow = get(handles.dfofBgThreshSlider, 'Value');

%relFrame = str2num(get(handles.dfofMinTEdit,'String'));
%relFrame = 2;
foldername = handles.foldername;
Images = handles.imgdata;
Images2 = handles.imgdata2;
%nuclearData = handles.nuclearData;
%nuclearData = uint8(nuclearData./256);
rgb=uint16(zeros(512,512,3));

mask = zeros(512,512);
for k = minZ:maxZ

    
    for i = minDf:maxDf
        

         A=handles.deltaFimagedata(:,:,i,k);
         B=handles.deltaFimagedata2(:,:,i,k);
         %assignin('base','A',A);
         deltaFimage(:,:,i-minDf+1,k-minZ+1)=A;
         deltaFimage2(:,:,i-minDf+1,k-minZ+1)=B;
         
    end
end
%assignin('base','deltaFimage',deltaFimage);
%assignin('base','mask',mask);
deltaFimage=squeeze(max(deltaFimage,[],3));
deltaFimage=squeeze(max(deltaFimage,[],3));
deltaFimage2=squeeze(max(deltaFimage2,[],3));
deltaFimage2=squeeze(max(deltaFimage2,[],3));


deltaFimage = imadjust(deltaFimage,[slidervalLow sliderval], [0 1]);
deltaFimage = fijiGaussian(deltaFimage,1); 
deltaFimage2 = imadjust(deltaFimage2,[slidervalLow sliderval], [0 1]);
deltaFimage2 = fijiGaussian(deltaFimage2,1);
assignin('base','deltaFimage',deltaFimage);
assignin('base','deltaFimage2',deltaFimage2);
        
           
        rgb(:,:,1)=deltaFimage2;
        rgb(:,:,2)=deltaFimage;
        rgb(:,:,3)=uint16(zeros(512, 512));
        
        %rgbArray{i}=rgb;
       
        
ZZZ=fullfile(foldername,'DeltaFRGBnomask\');
assignin('base','ZZZ',ZZZ);
if ~exist(ZZZ,'dir')
    
    mkdir(foldername,'DeltaFRGBnomask');
    
end
       
    filename=fullfile(foldername,'DeltaFRGBnomask',sprintf('%03d-%03d.tiff',minZ,maxZ));
   
    options.color=true;
    assignin('base','rgb',rgb);
    saveastiff(rgb,filename,options);
    
end
  
