function handles = updDataAx1Stim( handles, h)
% update axis with fluorescence time course of each ROI in current
% Z-section
[T, Z] = getTZ(handles);
if nargin < 2 || isempty(h)
    h = handles.dataAxes;
    axes(handles.dataAxes);
else
    axes(h);
end

cla;
hold on;

%[xx,yy] = meshgrid(1:512, 1:512,-1:1);
[minT, maxT] = getTLim(handles);
[minZ, maxZ] = getZLim(handles);
duration = length(minT:maxT);


%dfof = zeros(size(fluor,1)-3,size(fluor,2));
plotType = getCurrentPlotType(handles);

[handles] = calcRoi( handles, plotType);
dfoff = zeros(minT:maxT,size(handles.totalROIdataSlice{Z,1},1));
    for i = 1:size(handles.totalROIdataSlice{Z,1},1)
        for j = minT:maxT
           % assignin('base','testhandles',handles);
            dfoff(j,i)=handles.totalROIdataSlice{Z,1}{i,4}(j);    
        end

    end
dfoff = dfoff';

% use same colors as ROIs seen on screen
 clrs = handles.colors{Z}';
 clrs = clrs + (1 - clrs).*.25;
 set(h, 'ColorOrder', clrs);

% plot the values per ROI
%dfof = filter(3, [1 3-1], dfof);
%assignin('base', 'dfoff', dfoff);
plot(minT:maxT, dfoff, 'Parent', h);
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
   
axis tight;

%set(gca, 'YLim', [yMinlimit yMaxlimit]);

end





