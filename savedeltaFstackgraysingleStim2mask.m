function  savedeltaFstackgraysingleStim2mask( handles )
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
Images = handles.imgdata2;
%Images2 = handles.imgdata2;
%nuclearData = handles.nuclearData;
%nuclearData = uint8(nuclearData./256);
rgb=uint16(zeros(512,512,3));
%rgbdeltaF=uint8(zeros(512,512,3,size(nuclearData,3)));
% range1 = [2 7];
% range2 = [8 14];
% range3 = [15 20];
mask = zeros(512,512);
for k = minZ:maxZ
%     meanImage1=uint16(round(mean(Images(:,:,minT:maxT,k),3)));
%     meanImage2=uint16(round(mean(Images2(:,:,minT:maxT,k),3)));
    A=handles.totalROIdataSlice{k,1};
    B=handles.totalROIdataSlice2{k,1};
    if ~isempty(A)
        Asub = cell2mat(A(:,5));
        Bsub = cell2mat(B(:,5));
        Asub = Asub == 2;
        Bsub = Bsub == 2;

        if sum(Asub) > 0 || sum(Bsub) > 0
            A=A(Asub | Bsub,:);

            for j = 1:size(A,1)
                masktemp(:,:,j)=circle2mask([A{j,1} A{j,2}],A{j,3}+11,512);
            end
            mask =squeeze(max(masktemp,[],3));
        else
            mask=zeros(512,512);
        end
        clear A;
        clear B;


        for i = minDf:maxDf

            %deltaFimage(:,:,i,k)=(Images(:,:,i,k)-Images(:,:,2,k))./Images(:,:,2,k);
             %deltaFimage(:,:,i,k)=Images(:,:,i,k)-Images(:,:,relFrame,k);
    %          assignin('base','minDf',minDf);
    %          assignin('base','i',i);
    %          assignin('base','k',k);
    %          assignin('base','minZ',minZ);
             A=handles.deltaFimagedata(:,:,i,k);
             B=handles.deltaFimagedata2(:,:,i,k);
            % assignin('base','A',A);
             %deltaFimage(:,:,i-minDf+1,k-minZ+1)=immultiply(A,uint16(mask));
             deltaFimage2(:,:,i-minDf+1,k-minZ+1)=immultiply(B,uint16(mask));

        end
    end
end
%assignin('base','deltaFimage',deltaFimage);
%assignin('base','mask',mask);
deltaFimage=squeeze(max(deltaFimage,[],3));
deltaFimage=squeeze(max(deltaFimage,[],3));
%deltaFimage2=squeeze(max(deltaFimage2,[],3));
%deltaFimage2=squeeze(max(deltaFimage2,[],3));





deltaFimage = imadjust(deltaFimage,[slidervalLow sliderval], [0 1]);
deltaFimage = fijiGaussian(deltaFimage,1); 
%deltaFimage2 = imadjust(deltaFimage2,[slidervalLow sliderval], [0 1]);
%deltaFimage2 = fijiGaussian(deltaFimage2,1);
%assignin('base','deltaFimage',deltaFimage);
%assignin('base','deltaFimage2',deltaFimage2);
        
        
         
        
%         rgb(:,:,1)=deltaFimage2;
%         rgb(:,:,2)=deltaFimage;
%         rgb(:,:,3)=uint16(zeros(512, 512));
        
        %rgbArray{i}=rgb;
       
        
ZZZ=fullfile(foldername,'DeltaFStim2mask\');
%assignin('base','ZZZ',ZZZ);
if ~exist(ZZZ,'dir')
    
    mkdir(foldername,'DeltaFStim2mask');
    
end
    

     %rgb = uint16(round(rgb*255*255));
     
     %rgb = imrotate(rgb,90);
     
     %rgbdeltaF(:,:,:,i)=rgb;   
    
    
    filename=fullfile(foldername,'DeltaFStim2mask',sprintf('%03d-%03d.tiff',minZ,maxZ));
    
    
    %assignin('base','filename',filename);
    
   % assignin('base','foldername',foldername);
    %options.color=true;
    %assignin('base','rgb',rgb);
    saveastiff(deltaFimage,filename,options);
    
    
    
    
    
    
end
    
     
         
        
   
    
    
    






   
    





