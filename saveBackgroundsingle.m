function  saveBackgroundsingle( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% [tMin tMax]=getTLim(handles);
[zMin zMax]=getZLim(handles);
minDf = str2double(get(handles.minAxis,'String'));
maxDf = str2double(get(handles.maxAxis,'String'));

foldername = handles.foldername;
Images = handles.imgdata;


finalImg=Images(:,:,minDf:maxDf,zMin:zMax);
ZZZ=fullfile(foldername,'Backgrounds');
if ~exist(ZZZ,'dir')
    mkdir(foldername,'Backgrounds');
end
fullpathname = ZZZ;
finalImg=max(finalImg,[],4);
finalImg=max(squeeze(finalImg),[],3);
    
 
    
    filename =fullfile(fullpathname,sprintf('%03d-%03d.tiff',zMin,zMax));
    
    %options.color=true;
    %assignin('base','rgbdeltaF',rgbdeltaF);
    saveastiff(finalImg,filename);
    
    
    
    
    
    
end
    
     
         
        
   
    
    
    







   
    





