function [handles dfoff] = calcRoi(handles, plotType)
% Computes matrix of DF/F over time for every ROI in the current Z section
% Inputs: handles structure, plotType (1 for DF/F, 2 for intensity, 3 for
% DF), useDFOpts (true/false) tells whether to use options from "Image
% DF/F" panel, or just to use entire
% Outputs: handles structure, Duration x numActiveRoi matrix of DF/F values
%  where duration = length(minT:maxT)
[T Z] = getTZ(handles);
minThresh =str2double(get(handles.minAxis, 'String'));
maxThresh = str2double(get(handles.maxAxis, 'String'));
stdevMultiplier =str2double(get(handles.stDevmultiplier,'string'));

Duration = str2double(get(handles.maxTText, 'String'));
numActiveRoi = size(handles.totalROIdataSlice{Z,1},1);

fluor = zeros(Duration, numActiveRoi);
fluor2= zeros (Duration,numActiveRoi);
[minT maxT] = getTLim(handles);


for i=1:numActiveRoi
    %if handles.showRoi{Z}(i)
                centerX=handles.totalROIdataSlice{Z,1}{i,1};
                centerY=handles.totalROIdataSlice{Z,1}{i,2};
                radius=handles.totalROIdataSlice{Z,1}{i,3};
                if radius < 7
                    radius = 7;
                end
       %assignin('base','radius',radius);         
       %assignin('base','centerX',centerX);
       %assignin('base','centerY',centerY);
        thismask = circle2mask([centerX centerY], radius,512)==1;
        middlemask = circle2mask([centerX centerY], radius + 2,512)==1;
        largermask = circle2mask([centerX centerY], radius + 15,512)==1;
        largermask(middlemask)=0;
        %assignin('base','largermask',largermask);
        %assignin('base','thismask',thismask);
         for t=1:Duration
            temp = handles.imgdata(:,:,t,Z);
            A = temp(thismask);
            B = quantile(A,.75);
            %assignin('base','B',B);
            A = A(A <= B);
            AA=temp(largermask);

            fluor(t,i) = nanmean(A);
            fluor2(t,i)= mean(AA);
        end
        %kk = kk + 1;
    %end
end

dfoff = zeros(size(fluor));
dfoffhalo = zeros(size(fluor2));
% if making DF/F plot, compute DF/F; otherwise, just use intensity
dfminT = str2double(get(handles.dfofMinTEdit, 'String'));
dfmaxT = str2double(get(handles.dfofMaxTEdit, 'String'));
f0Range = dfminT:dfmaxT;
mF = mean(fluor(f0Range, :));
mF2 = mean(fluor2(f0Range, :));

% DF/F
if plotType == 1
    %dfoff = bsxfun(@rdivide, fluor3(minT:maxT,:), mF) - 1;
    dfhalo= bsxfun(@minus, fluor2, mF2);
    %assignin('base','dfhalo',dfhalo);
    
    fluorfinal=fluor-dfhalo;
    mfluorfinal=mean(fluorfinal(f0Range,:));
    %assignin('base','mfluorfinal',mfluorfinal);
    %ssignin('base','fluorfinal',fluorfinal);
    dfoff = bsxfun(@rdivide, fluorfinal(minT:maxT,:), mfluorfinal) - 1;
    %dfoffhalo=bsxfun(@rdivide, fluor2(minT:maxT,:), mF) - 1;
    
    %dfoff=dfoff-dfoffhalo;
    % intensity
elseif plotType == 2
    dfhalo= bsxfun(@minus, fluor2, mF2);
    fluorfinal = fluor-dfhalo;
    dfoff = fluor(minT:maxT,:);
    %dfoffhalo = fluor2(minT:maxT,:);
    %dfoff=dfoff-dfoffhalo;
    % DF
elseif plotType == 3
    dfoff = bsxfun(@minus, fluor(minT:maxT,:), mF);
    %dfoffhalo = bsxfun(@minus, fluor2(minT:maxT,:), mF);
    %dfoff=dfoff-dfoffhalo;
elseif plotType == 4
    dfoff = bsxfun(@minus,fluor(minT:maxT,:),mean(fluor(minT:maxT,:),1));
    %dfoff = bsxfun(@rdivide,dfoff,max(1e-20,std(dfoff,0,1)));
    dfoff = bsxfun(@rdivide,dfoff,std(fluor(minT:maxT,:)));
end
counter = 0;
       
handles.totalROIdataSlice{Z,1}(:,5)={0};

   for j = 1:numActiveRoi
      %assignin('base','dfoff',dfoff);
      %assignin('base','handles',handles);
      dfminT = str2double(get(handles.dfofMinTEdit, 'String'));
      dfmaxT = str2double(get(handles.dfofMaxTEdit, 'String'));
      handles.totalROIdataSlice{Z,1}{j,4}= dfoff(:,j);
       A=dfoff(dfminT:dfmaxT,j);             
       meanDf=nanmean(A);
       stdDf=nanstd(A);
       handles.totalROIdataSlice{Z,1}{j,4}(1,2)=meanDf;
       handles.totalROIdataSlice{Z,1}{j,4}(2,2)=stdDf;
      
       for i = 1:size(handles.totalROIdataSlice{Z,1}{j,4},1)
          handles.totalROIdataSlice{Z,1}{j,4}(i,3)=(handles.totalROIdataSlice{Z,1}{j,4}(i,1)-handles.totalROIdataSlice{Z,1}{j,4}(1,2))/handles.totalROIdataSlice{Z,1}{j,4}(2,2);
            %tic
          if i >= minThresh & i <= maxThresh & handles.totalROIdataSlice{Z,1}{j,4}(i,3) > stdevMultiplier & handles.totalROIdataSlice{Z,1}{j,4}(i,1) > .08
          %if i >= minThresh & i <= maxThresh & handles.totalROIdataSlice{Z,1}{j,4}(i,1) > stdevMultiplier
              
                if handles.totalROIdataSlice{Z,1}{j,5}~= 2 
                    
                  handles.totalROIdataSlice{Z,1}(j,5)={2};
                    
                   handles.colors{Z} = add_random_colors(handles.colors{Z},.4);
                    counter = counter + 1;
                    roiData{counter,1} = colText(num2str(counter), makeRgbString(handles.colors{Z}(:,counter)));
                    temp = handles.totalROIdataSlice{Z,1}{j,4};
                    temp = temp(minThresh:maxThresh,1);
                    roiData{counter,2} = max(temp); 
                    
               end
                
          end
          
       
       end
%        if handles.totalROIdataSlice{Z,1}{j,5}==2
%           if ~isempty(handles.totalROIdataSlice{Z-1,1})
%               circen = [handles.totalROIdataSlice{Z,1}{j,1}, handles.totalROIdataSlice{Z,1}{j,2}];
%               for ii = 1:size(handles.totalROIdataSlice{Z-1,1})
%                     circen2 = [handles.totalROIdataSlice{Z-1,1}{ii,1}, handles.totalROIdataSlice{Z-1,1}{ii,2}];
%                      dist = sqrt((circen(1)-circen2(1))^2 + (circen(2) - circen2(2))^2);
%                         if dist < 6 & handles.totalROIdataSlice{Z-1,1}{ii,5} == 2
%                             assignin('base','handles',handles);
%                             assignin('base','ii',ii);
%                             assignin('base','j',j);
%                             a=max(handles.totalROIdataSlice{Z,1}{j,4}(minThresh:maxThresh,3));
%                             assignin('base','a',a);
%                             b= max(handles.totalROIdataSlice{Z-1,1}{ii,4}(minThresh:maxThresh,3));
%                             
%                             
%                             assignin('base','b',b);
%                             if a < b
%                             %if max(handles.totalROIdataSlice{Z,1}{j,4}(:,3))< max(handles.totalROIdataSlice{Z-1,1}{ii,4}(:,3))
%                                 handles.totalROIdataSlice{Z,1}(j,5)={0};
%                             end
%                         elseif dist < 6 & handles.totalROIdataSlice{Z-1,1}{ii,5} == 2
%                             if max(handles.totalROIdataSlice{Z,1}{j,4}(minThresh:maxThresh,3))> max(handles.totalROIdataSlice{Z-1,1}{ii,4}(minThresh:maxThresh,3))
%                                 handles.totalROIdataSlice{Z-1,1}(ii,5)={0};
%                             end
%                         end       
%               end
%           end
%            if ~isempty(handles.totalROIdataSlice{Z+1,1})
%               circen = [handles.totalROIdataSlice{Z,1}{j,1}, handles.totalROIdataSlice{Z,1}{j,2}];
%               for ii = 1:size(handles.totalROIdataSlice{Z+1,1})
%                     circen2 = [handles.totalROIdataSlice{Z+1,1}{ii,1}, handles.totalROIdataSlice{Z+1,1}{ii,2}];
%                      dist = sqrt((circen(1)-circen2(1))^2 + (circen(2) - circen2(2))^2);
%                         if dist < 6 & handles.totalROIdataSlice{Z+1,1}{ii,5} == 2
%                             if max(handles.totalROIdataSlice{Z,1}{j,4}(minThresh:maxThresh,3))< max(handles.totalROIdataSlice{Z+1,1}{ii,4}(minThresh:maxThresh,3))
%                                 handles.totalROIdataSlice{Z,1}(j,5)={0};
%                             end
%                         elseif dist < 6 & handles.totalROIdataSlice{Z+1,1}{ii,5} == 2
%                             if max(handles.totalROIdataSlice{Z,1}{j,4}(minThresh:maxThresh,3))> max(handles.totalROIdataSlice{Z+1,1}{ii,4}(minThresh:maxThresh,3))
%                                 handles.totalROIdataSlice{Z+1,1}(ii,:)={0};
%                             end
%                         end           
%               end
%           end
%            
%            
%        end
       
       
       
       

   end
   
   if exist('roiData','var')
        handles.totalROIdataSlice{Z,7}=roiData;  
        set(handles.roiTable, 'Data', roiData);
         drawnow;
         
   end



end

function str = makeRgbString(rgb)
    str = ['rgb(' num2str(round(255*rgb(1))) ',' num2str(round(255*rgb(2))) ',' num2str(round(255*rgb(3))) ')'];
end

function outHtml = colText(inText, inColor)
    outHtml = ['<html><b><font color="', ...
        inColor, ...
        '">', ...
        inText, ...
        '</font></b></html>'];
end


