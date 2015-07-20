function [ handles ] = exportAlignedBlue( handles )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
A=handles.imgdata;
foldername=handles.foldername;
if (handles.stimNum == 2)
    B=handles.imgdata2;
    foldername2=handles.foldername2;
    Duration2 = size(B,3);
    fullpath2=sprintf('%s\\BlueAligned\\',foldername2);
end
nuclearfolder=handles.nuclearfolder;

%Duration = str2double(get(handles.maxTText, 'String'));
Duration = size(A,3);
fullpath=sprintf('%s\\GreenAligned\\',foldername);
fullpath3=sprintf('%s\\AlignAligned\\',nuclearfolder);

   % fullpath


    %fullpathname
if (get(handles.traG,'Value')== get(handles.traG,'Max'))
    mkdir(fullpath);
    for j=1:Duration
    
        Image=squeeze(A(:,:,j,:));
        %Image2=squeeze(B(:,:,j,:));
        fprintf('Writing slice %d\n', j);
        fullpathname=sprintf('%s\\GreenAligned\\%03d.tiff',foldername,j);
        %fullpathname2=sprintf('%s\\BlueAligned\\%03d.tiff',foldername2,j);
        saveastiff(Image, fullpathname);    
        %saveastiff(Image2, fullpathname2);
    end
end
if (get(handles.traB,'Value')== get(handles.traB,'Max'))
    mkdir(fullpath2);
    for j=1:Duration2
        %Image=squeeze(A(:,:,j,:));
        Image2=squeeze(B(:,:,j,:));
        fprintf('Writing slice %d\n', j);
        %fullpathname=sprintf('%s\\GreenAligned\\%03d.tiff',foldername,j);
        fullpathname2=sprintf('%s\\BlueAligned\\%03d.tiff',foldername2,j);
        %saveastiff(Image, fullpathname);    
        saveastiff(Image2, fullpathname2);
    
    end
end
if (get(handles.traR,'Value')== get(handles.traB,'Max'))
    mkdir(fullpath3);
    
        
        nuclearData=handles.nuclearData;
        alignData=handles.alignData;
        %fprintf('Writing slice %d\n', j);
        %fullpathname=sprintf('%s\\GreenAligned\\%03d.tiff',foldername,j);
        nuclearpathname=sprintf('%s\\AlignAligned\\C561.tiff',nuclearfolder);
        alignpathname=sprintf('%s\\AlignAligned\\C488.tiff',nuclearfolder);
        saveastiff(alignData, alignpathname);    
        saveastiff(nuclearData, nuclearpathname);
    
    
end



end

