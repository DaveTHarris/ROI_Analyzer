function [handles dfoff dfoffblue] = calcRoi2Stim(handles, plotType)
% Computes matrix of DF/F over time for every ROI in the current Z section
% Inputs: handles structure, plotType (1 for DF/F, 2 for intensity, 3 for
% DF), useDFOpts (true/false) tells whether to use options from "Image
% DF/F" panel, or just to use entire
% Outputs: handles structure, Duration x numActiveRoi matrix of DF/F values
%  where duration = length(minT:maxT)
[T Z] = getTZ(handles);
minThresh =str2double(get(handles.minAxis, 'String'));
maxThresh = str2double(get(handles.maxAxis, 'String'));

% minThresh = handles.minThresh;
% maxThresh = handles.maxThresh;
[minZ maxZ] = getZLim(handles);
%assignin('base','handles',handles);
stdevMultiplier=str2double(get(handles.stDevmultiplier,'string'));

Duration = str2double(get(handles.maxTText, 'String'));
numActiveRoi = size(handles.totalROIdataSlice{Z,1},1);


fluor = zeros(Duration, numActiveRoi);
fluorblue = zeros(Duration, numActiveRoi);
[minT maxT] = getTLim(handles);


for i=1:numActiveRoi
    %if handles.showRoi{Z}(i)
                centerX=handles.totalROIdataSlice{Z,1}{i,1};
                centerY=handles.totalROIdataSlice{Z,1}{i,2};
                radius=handles.totalROIdataSlice{Z,1}{i,3};
                if radius < 7
                    radius = 7;
                end
                 
        thismask = circle2mask([centerX centerY], radius,512)==1;
        middlemask = circle2mask([centerX centerY], radius + 2,512)==1;
        largermask = circle2mask([centerX centerY], radius + 15,512)==1;
        largermask(middlemask)=0;
%         assignin('base','largermask',largermask);
%         assignin('base','thismask',thismask);
         for t=1:Duration
            temp = handles.imgdata(:,:,t,Z);
            temp2 = handles.imgdata2(:,:,t,Z);
            A = temp(thismask);
            %Amed=median(A);
           % A(A>Amed)=NaN;
            B = temp2(thismask);
            %Bmed=median(B);
            %B(B>Bmed)=NaN;
            AA=temp(largermask);
            BB=temp2(largermask);
%             B = median(A);
%             BB=median(AA);
%             C = A;
%             CC = AA;
%             C(C>B)= NaN;
%             CC(CC>BB)=NaN;
            %fluor(t,kk) = mean(temp(thismask));
            fluor(t,i) = nanmean(A);
            fluorblue(t,i) = nanmean(B);
            fluor2(t,i)= mean(AA);
            fluorblue2(t,i)=mean(BB);
        end
%         kk = kk + 1;
    %end
end

dfoff = zeros(size(fluor));
dfoffblue = zeros(size(fluor));
dfoffhalo = zeros(size(fluor2));
dfoffhaloblue = zeros(size(fluor2));
% if making DF/F plot, compute DF/F; otherwise, just use intensity

dfminT = str2double(get(handles.dfofMinTEdit, 'String'));
dfmaxT = str2double(get(handles.dfofMaxTEdit, 'String'));
f0Range = dfminT:dfmaxT;
mF = mean(fluor(f0Range, :));
mF2 = mean(fluor2(f0Range, :));
mF2blue = mean(fluorblue2(f0Range, :));

% DF/F
if plotType == 1
    %dfoff = bsxfun(@rdivide, fluor3(minT:maxT,:), mF) - 1;
    dfhalo= bsxfun(@minus, fluor2, mF2);
    %dfhalo(dfhalo<0)=0;
    dfhaloblue=bsxfun(@minus,fluorblue2,mF2blue);
    %dfhaloblue(dfhaloblue<0)=0;
    assignin('base','dfhalo',dfhalo);
   % if dfhalo > 0
    
    fluorfinal=fluor-dfhalo;
    %else
      %  fluorfinal=fluor;
    %end
    fluorfinalblue=fluorblue-dfhaloblue;
    
    mfluorfinal=mean(fluorfinal(f0Range,:));
    mfluorfinalblue=mean(fluorfinalblue(f0Range,:));
    
    assignin('base','mfluorfinal',mfluorfinal);
    assignin('base','fluorfinal',fluorfinal);
    dfoff = bsxfun(@rdivide, fluorfinal(minT:maxT,:), mfluorfinal) - 1;
    dfoffblue = bsxfun(@rdivide, fluorfinalblue(minT:maxT,:), mfluorfinalblue) - 1;
    %dfoffhalo=bsxfun(@rdivide, fluor2(minT:maxT,:), mF) - 1;
    
    %dfoff=dfoff-dfoffhalo;
    % intensity
elseif plotType == 2
    dfhalo= bsxfun(@minus, fluor2, mF2);
    assignin('base','dfhalo',dfhalo);
    
    dfhaloblue=bsxfun(@minus,fluorblue2,mF2blue);
    assignin('base','fluor',fluor);
   
    fluorfinal = fluor-dfhalo;
    assignin('base','fluorfinal',fluorfinal);
    fluorfinalblue = fluorblue-dfhaloblue;
    %dfoff = fluor(minT:maxT,:);
    dfoff = fluorfinal(minT:maxT,:);
    dfoffblue = fluorfinalblue(minT:maxT,:);
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
       %handles.totalROIdataSlice{Z,7}={[]};
handles.totalROIdataSlice{Z,1}(:,5)={0};
handles.totalROIdataSlice2{Z,1}(:,5)={0};
   for j = 1:numActiveRoi
      assignin('base','dfoff',dfoff);
      %assignin('base','handles',handles);
      dfminT = str2double(get(handles.dfofMinTEdit, 'String'));
      dfmaxT = str2double(get(handles.dfofMaxTEdit, 'String'));
      handles.totalROIdataSlice{Z,1}{j,4}= dfoff(:,j);
       handles.totalROIdataSlice2{Z,1}{j,4}=dfoffblue(:,j);
       
       %A=dfoff(:,j);
       A=dfoff(dfminT:dfmaxT,j);
       B=dfoffblue(dfminT:dfmaxT,j);
       assignin('base','B',B);
       %A(minThresh:maxThresh,:)=[];
       meanDf=nanmean(A);
       meanblueDf=nanmean(B);
       stdDf=nanstd(A);
       stdDfblue=nanstd(B);
       handles.totalROIdataSlice{Z,1}{j,4}(1,2)=meanDf;
       handles.totalROIdataSlice{Z,1}{j,4}(2,2)=stdDf;
       handles.totalROIdataSlice2{Z,1}{j,4}(1,2)=meanblueDf;
       handles.totalROIdataSlice2{Z,1}{j,4}(2,2)=stdDfblue;
       
       for i = 1:size(handles.totalROIdataSlice{Z,1}{j,4},1)
          handles.totalROIdataSlice{Z,1}{j,4}(i,3)=(handles.totalROIdataSlice{Z,1}{j,4}(i,1)-handles.totalROIdataSlice{Z,1}{j,4}(1,2))/handles.totalROIdataSlice{Z,1}{j,4}(2,2);
          handles.totalROIdataSlice2{Z,1}{j,4}(i,3)=(handles.totalROIdataSlice2{Z,1}{j,4}(i,1)-handles.totalROIdataSlice2{Z,1}{j,4}(1,2))/handles.totalROIdataSlice2{Z,1}{j,4}(2,2);
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
            if i >= minThresh & i <= maxThresh & handles.totalROIdataSlice2{Z,1}{j,4}(i,3) > stdevMultiplier & handles.totalROIdataSlice2{Z,1}{j,4}(i,1) > .08
          %if i >= minThresh & i <= maxThresh & handles.totalROIdataSlice{Z,1}{j,4}(i,1) > stdevMultiplier
              if handles.totalROIdataSlice2{Z,1}{j,5}~= 2 
                    handles.totalROIdataSlice2{Z,1}(j,5)={2}; 
                    handles.colors{Z} = add_random_colors(handles.colors{Z},.4);
                    counter = counter + 1;

                    roiData{counter,1} = colText(num2str(counter), makeRgbString(handles.colors{Z}(:,counter)));

                    temp = handles.totalROIdataSlice2{Z,1}{j,4};
                    temp = temp(minThresh:maxThresh,1);
         
                    roiData{counter,2} = max(temp);
                   
               end
             %assignin('base','handles',handles);      
          end
       
       end
   end
   if exist('roiData','var')
        handles.totalROIdataSlice{Z,7}=roiData;
        set(handles.roiTable, 'Data', roiData);
         drawnow;
         
   end


    %assignin('base','handles',handles);   
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


