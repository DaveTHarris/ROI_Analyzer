function handles = nucDetect( handles )
%This function finds ROIs based on the location of nuclei

sensitivity = get(handles.senseSlider,'Value');
edgeThresh = get(handles.threshSlider,'Value');
[T sliceNumber]=getTZ(handles);
rawimg = handles.nuclearData;
rawimg=rawimg(:,:,sliceNumber);
imageSize=512;
%allROIs = handles.allROIs;
%imgfltrd=rawimg;
%assignin('base','handles',handles);
%fullStack = handles.filteredImg;
%handles.totalROIdataSlice{sliceNumber,1}=[];

handles.totalROIdataSlice{sliceNumber,2}=sensitivity;
handles.totalROIdataSlice{sliceNumber,3}=edgeThresh;

    
%rawimg = rawimg(:,:,sliceNumber);
 
%     IM2 = imerode(rawimg,SE);
%     IM2 = imdilate(IM2,SE);
%     rawimg = imsubtract(rawimg,IM2);
%         
 
 
 
 fltr4img = [1 1 1 1 1; 1 2 2 2 1; 1 2 4 2 1; 1 2 2 2 1; 1 1 1 1 1];
 fltr4img = fltr4img / sum(fltr4img(:));
 imgfltrd = filter2( fltr4img , rawimg );
 tic;
 
 
 [circen, cirrad, metric] = imfindcircles(imgfltrd, [3 5],'Sensitivity',sensitivity,'EdgeThreshold',edgeThresh);
 toc;
 %The imfindcircles function will order the ROIs with respect to the metric which is
 %an indicator of how likely the actual spot is a circle. The following
 %code goes through and 
 for i = 1:size(circen,1)-1
     for j = i + 1:size(circen,1)
        dist = sqrt((circen(i,1)-circen(j,1))^2 + (circen(i,2) + circen(j,2))^2);
        if dist < cirrad(j)
            circen(j,:)=NaN;
            cirrad(j)=NaN; 
        end
     end
 end
 circen=circen(~any(isnan(circen),2),:);
 
    if ~isempty(handles.totalROIdataSlice{sliceNumber,1})
        adder = size(handles.totalROIdataSlice{sliceNumber,1},1);
    else
        adder = 0;
    end


        for j = 1:size(circen,1)
            if (circen(j,1)>20) && (circen(j,1)<imageSize-20) && (circen(j,2)>20) && (circen(j,2)<imageSize-20)
            
                adder = adder + 1;
                
                handles.totalROIdataSlice{sliceNumber,1}{adder,1} = circen(j,1);
                handles.totalROIdataSlice2{sliceNumber,1}{adder,1} = circen(j,1);
                handles.totalROIdataSlice{sliceNumber,1}{adder,2} = circen(j,2);
                handles.totalROIdataSlice2{sliceNumber,1}{adder,2} = circen(j,2);
                handles.totalROIdataSlice{sliceNumber,1}{adder,3} = cirrad(j,1);
                handles.totalROIdataSlice2{sliceNumber,1}{adder,3} = cirrad(j,1)+4;
%                 handles.totalROIdataSlice{sliceNumber,1}{adder,6} = 0;
%                 handles.totalROIdataSlice2{sliceNumber,1}{adder,6}=0;
                handles.totalROIdataSlice{sliceNumber,1}{adder,5} = 0;
                handles.totalROIdataSlice2{sliceNumber,1}{adder,5} = 0;
                
            end
        end
    


%totalROIs = length(totalROIdata);













