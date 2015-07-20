function  savedeltaFstackgraysingleStim2( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[tMin tMax]=getTLim(handles);
[zMin zMax]=getZLim(handles);

%For Gaussian
sigma = 1;

%For background Thresholding
bgThreshold = get(handles.dfofBgThreshSlider, 'Value');

%For Foregound Thresholding
fgThreshold = get(handles.dfofFgThreshSlider, 'Value');
%relFrame = str2num(get(handles.dfofMinTEdit,'String'));
relFrame = 2;
foldername = handles.foldername;
Images = handles.imgdata2;


for k = 1:size(Images,4)
    for i = 2:size(Images,3)
        
        %deltaFimage(:,:,i,k)=(Images(:,:,i,k)-Images(:,:,2,k))./Images(:,:,2,k);
         deltaFimage(:,:,i,k)=Images(:,:,i,k)-Images(:,:,i-1,k);
    

    end
end

imageArray=cell(size(deltaFimage,4),size(deltaFimage,3));
GaussianFiltdeltaF = zeros(512,512,size(deltaFimage,3),size(deltaFimage,4));
GaussianFiltdeltaFind = uint8(zeros(512,512,size(deltaFimage,3),size(deltaFimage,4)));
%rgbArray=cell(size(deltaFimage,4),size(deltaFimage,3));


maxDeltaF = double(max(deltaFimage(:)));
minDeltaF = double(min(deltaFimage(:)));
dfofRange = maxDeltaF - minDeltaF;
cmax = minDeltaF + (fgThreshold * dfofRange);
cmin = minDeltaF + (bgThreshold * cmax);
        


for i = 1:size(deltaFimage,4)
    for j = 1:size(deltaFimage,3)
        A = deltaFimage(:,:,j,i);
        
        
        G = fspecial('gaussian',[4 4],sigma);
        blurImage = imfilter(A,G);
         
        
        blurImage(blurImage > cmax) = cmax;
        %blurImage(blurImage < cmin) = cmin;
        blurImage(blurImage < cmin) = 0;
          
        blurImagegray=mat2gray(blurImage);
        blurImageIndx=gray2ind(blurImagegray,256);
        
        A = blurImageIndx;
        BW =  im2bw(A,0.1);
        BW2 = bwareaopen(BW,15);
        AA = immultiply(A,BW2);
        %sizeFiltdeltaF(:,:,j,i) = AA;
        AA = imfilter(AA,G);
        
        %GaussianFiltdeltaF(:,:,j,i) = blurImage;
        GaussianFiltdeltaFind(:,:,j,i) =AA;
        
        imageArray{i,j}=AA;
       
        
    end
end
%GaussianFiltdeltaF = mat2gray(GaussianFiltdeltaF);
%GaussianFiltdeltaF = gray2ind(GaussianFiltdeltaF,256);
adder1 = 1;
for i = tMin:tMax
    adder2=1;
    for j = zMin:zMax
        
        finalImg(:,:,adder1,adder2)=imageArray{j,i};
        adder2 = adder2+1;
    end
    adder1=adder1+1;
end


    mkdir(foldername,'singleDeltaFStim2');
    fullpathname = sprintf('%s/singleDeltaFStim2',foldername);
    finalImg=max(finalImg,[],4);
    finalImg=max(squeeze(finalImg),[],3);
        
    filename =sprintf('%s/t%03d-%03d_z%03d-%03d.tiff',fullpathname,tMin,tMax,zMin,zMax);
    
    saveastiff(finalImg,filename);
        
    
end
    
     
         
        
   
    
    
    







   
    





