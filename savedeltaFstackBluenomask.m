function  savedeltaFstackBluenomask( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
minZ = str2double(get(handles.maxZEdit,'String'));
maxZ = str2double(get(handles.minZEdit,'String'));
%For Gaussian
sigma = 1;
[minT, maxT]=getdfofRange(handles);
minDf = get(handles.minAxis,'Value');
maxDf = get(handles.maxAxis,'Value');
%For background Thresholding
bgThreshold = get(handles.dfofBgThreshSlider, 'Value');

%For Foregound Thresholding
fgThreshold = get(handles.dfofFgThreshSlider, 'Value');
%relFrame = str2num(get(handles.dfofMinTEdit,'String'));
%relFrame = 2;
foldername = handles.foldername;
Images = handles.imgdata;
Images2 = handles.imgdata2;
nuclearData = handles.nuclearData;
nuclearData = uint8(nuclearData./256);
rgb=uint8(zeros(512,512,3));
rgbdeltaF=uint8(zeros(512,512,3,size(nuclearData,3)));
% range1 = [2 7];
% range2 = [8 14];
% range3 = [15 20];

for k = minZ-minZ+1:maxZ-minZ
    meanImage1=uint16(round(mean(Images(:,:,minT:maxT,k),3)));
    meanImage2=uint16(round(mean(Images2(:,:,minT:maxT,k),3)));
      
    
    for i = minAxis-minAxis+1:maxAxis-minAxis
        
        %deltaFimage(:,:,i,k)=(Images(:,:,i,k)-Images(:,:,2,k))./Images(:,:,2,k);
         %deltaFimage(:,:,i,k)=Images(:,:,i,k)-Images(:,:,relFrame,k);
         A=Images(:,:,i,k)-meanImage1;
         B=Images2(:,:,i,k)-meanImage2;
         deltaFimage(:,:,i,k)=A;
         deltaFimage2(:,:,i,k)=B;
    end
end

deltaFimage=squeeze(max(deltaFimage,[],3));
deltaFimage2=squeeze(max(deltaFimage2,[],3));


maxDeltaF = double(max(deltaFimage(:)));
maxDeltaF2= double(max(deltaFimage2(:)));
minDeltaF = double(min(deltaFimage(:)));
minDeltaF2 = double(min(deltaFimage2(:)));
dfofRange = maxDeltaF - minDeltaF;
dfofRange2 = maxDeltaF2 - minDeltaF2;
cmax = minDeltaF + (fgThreshold * dfofRange);
cmax2 = minDeltaF2 + (fgThreshold * dfofRange2);
cmin = minDeltaF + (bgThreshold * cmax);
cmin2 = minDeltaF2 + (bgThreshold * cmax2);       


for i = 1:size(deltaFimage,3)
    
        A = deltaFimage(:,:,i);
        A2 = deltaFimage2(:,:,i);
        
        %G = fspecial('gaussian',[4 4],sigma);
        %blurImage = imfilter(A,G);
        blurImage = A;
        blurImage2 = A2;
         
                        
        blurImage(blurImage > cmax) = cmax;
        blurImage(blurImage < cmin) = cmin;
        blurImage(blurImage < cmin) = 0;
        
        blurImage2(blurImage2 > cmax2) = cmax2;
        blurImage2(blurImage2 < cmin2) = cmin2;
        blurImage2(blurImage2 < cmin2) = 0;
        
        blurImagegray=mat2gray(blurImage);
        blurImageIndx=gray2ind(blurImagegray,256);
        
        blurImagegray2=mat2gray(blurImage2);
        blurImageIndx2=gray2ind(blurImagegray2,256);
        
        A = blurImageIndx;
        B = blurImageIndx2;
%         BW =  im2bw(A,0.1);
%         BW2 = bwareaopen(BW,15);
%         AA = immultiply(A,BW2);
%         %sizeFiltdeltaF(:,:,j,i) = AA;
%         AA = imfilter(AA,G);
        AA=A;
        BB=B;
        %GaussianFiltdeltaF(:,:,j,i) = blurImage;
%         GaussianFiltdeltaFind(:,:,j,i) =AA;
        
        
        rgb(:,:,1)=BB;
        rgb(:,:,2)=AA;
        rgb(:,:,3)=0;
        
        rgbArray{i}=rgb;
       
        
end



    mkdir(foldername,'DelFoverTbothnomask');
    fullpathname = sprintf('%s/DelFoverTbothnomask',foldername);

    assignin('base','rgbArray',rgbArray);
  for j = 1:size(rgbArray,2)
    for i = 1:size(rgbArray,1)
     Z = rgbArray{i,j};
     
     %Z = uint16(round(Z*255*255));
     
     %Z = imrotate(Z,90);
     
     rgbdeltaF(:,:,:,i)=Z;   
    
    
    end
    
    filename =sprintf('%s/%03d.tiff',fullpathname,j);
    
    options.color=true;
    assignin('base','rgbdeltaF',rgbdeltaF);
    saveastiff(rgbdeltaF,filename,options);
     
    
end
    
     
         
        
   
    
    
    
end






   
    





