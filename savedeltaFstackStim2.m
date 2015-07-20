function  savedeltaFstackStim2( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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


imageStack=uint8(zeros(512,512,size(Images,4)));
for k = 1:size(Images,4)
    for i = 2:size(Images,3)
        
        %deltaFimage(:,:,i,k)=(Images(:,:,i,k)-Images(:,:,2,k))./Images(:,:,2,k);
         deltaFimage(:,:,i,k)=Images(:,:,i,k)-Images(:,:,relFrame,k);
    

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


    mkdir(foldername,'DelFoverTStim2');
    fullpathname = sprintf('%s/DelFoverTStim2',foldername);

   
  for j = 1:size(imageArray,2)
    tic;
     for i = 1:size(imageArray,1)
     Z = imageArray{i,j};
     
     %Z = uint16(round(Z*255*255));
     
     %Z = imrotate(Z,90);
     
     imageStack(:,:,i)=Z;   
    
    
    end
    
    filename =sprintf('%s/%03d.tiff',fullpathname,j);
    
    %options.color=true;
    %assignin('base','rgbdeltaF',rgbdeltaF);
    %assignin('base','imageStack',imageStack);
    saveastiff(imageStack,filename);
    
    toc;
     
    
end
    
       
    
    
end






   
    





