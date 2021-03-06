function [ handles ] = exportOthersDH( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[T, Z] = getTZ(handles);
if nargin < 2 || isempty(h)
    h = handles.dataAxes;
    axes(handles.dataAxes);
else
    axes(h);
end
figHandle=figure;
set(gcf,'color','white')
%axes(figHandle);
cla;
hold on;

%[xx,yy] = meshgrid(1:512, 1:512,-1:1);
[minT, maxT] = getTLim(handles);
[minZ, maxZ] = getZLim(handles);
duration = length(minT:maxT);


%dfof = zeros(size(fluor,1)-3,size(fluor,2));
plotType = getCurrentPlotType(handles);
useDFOpts = (get(handles.useDFCheck, 'Value') == 1);

    
 
dfoff = zeros(minT:maxT,size(handles.totalROIdataSlice{Z,1},1));
counter = 0;
for i = 1:size(handles.totalROIdataSlice{Z,1},1)
   if handles.totalROIdataSlice{Z,1}{i,5}==0
       counter = counter+1;
        for j = minT:maxT
        dfoff(j,counter)=handles.totalROIdataSlice{Z,1}{i,4}(j);    
        end
   end
end
dfoff=dfoff(:,1:counter); 
if size(dfoff,1) > 30
         dfoff=smooth(dfoff(:));
         dfoff=reshape(dfoff,maxT-minT+1,counter);
end  
        dfoff = dfoff';
%assignin('base','dfoff',dfoff);    
        % use same colors as ROIs seen on screen
%         clrs = handles.colors{Z}';
%         set(h, 'ColorOrder', clrs(logical(handles.showRoi{Z}),:));


% plot the values per ROI
%dfof = filter(3, [1 3-1], dfof);
%figure(figHandle);
plot(minT:maxT, dfoff, 'k');
%save(gr66aroi, dfof,'-append');
if plotType == 1
    ylabel('\Delta F/F');
elseif plotType == 3
    ylabel('\Delta F');
elseif plotType == 2
    ylabel('Intensity');
elseif plotType == 4
    ylabel('Z-Score');
end
xlabel('Frame');
%set(gca, 'XLimMode', 'manual');

set(gca, 'XTick', minT:maxT);
%set(gca, 'XTickLabel', minT:maxT);
set(gca, 'XLim', [minT maxT]);

    
%yMaxlimit = str2double(get(handles.maxAxis, 'String'));
%yMinlimit = str2double(get(handles.minAxis, 'String'));


axis tight;

export_fig Others.pdf



%set(gca, 'YLim', [yMinlimit yMaxlimit]);

end


