function [ handles ] = exportActiveDH( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% update axis with fluorescence time course of each ROI in current
% Z-section
[T, Z] = getTZ(handles);

   
figHandle=figure('Position', [100,100,1024,512]);
%FigHandle = figure('Position', [100, 100, 1049, 895]);
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
   if handles.totalROIdataSlice{Z,1}{i,5}==2
       counter = counter+1;
        for j = minT:maxT
        dfoff(j,counter)=handles.totalROIdataSlice{Z,1}{i,4}(j);    
        end
   end
end
    dfoff=dfoff(:,1:counter);
    assignin('base','dfoff',dfoff);
if size(dfoff,1) > 30
    dfoff=smooth(dfoff(:));
    dfoff=reshape(dfoff,maxT-minT+1,counter);
end
    dfoff = dfoff';

    % use same colors as ROIs seen on screen
clrs = handles.colors{Z}';
%set(h, 'ColorOrder', clrs);

set(gca, 'ColorOrder', clrs, 'NextPlot', 'replacechildren');

% plot the values per ROI
%dfof = filter(3, [1 3-1], dfof);
%figure(figHandle);
plot(minT:maxT, dfoff, 'LineWidth',1);
%save(gr66aroi, dfof,'-append');
if plotType == 1
    ylabel('\Delta F/F','FontWeight','bold','FontSize',14);
elseif plotType == 3
    ylabel('\Delta F','FontWeight','bold','FontSize',14);
elseif plotType == 2
    ylabel('Intensity','FontWeight','bold','FontSize',14);
elseif plotType == 4
    ylabel('Z-Score','FontWeight','bold', 'FontSize',14);
end
xlabel('Frame','FontWeight','bold', 'FontSize',14);
set(gca,'fontWeight','bold');

%set(gca, 'XLimMode', 'manual');
set(gca, 'LineWidth',1);
set(gca, 'XTick', minT:maxT);
%set(gca, 'XTickLabel', minT:maxT);
set(gca, 'XLim', [minT maxT]);
%line([5 7],[-.8 -.8],'Color','g','LineWidth',10);
    
% yMaxlimit = str2double(get(handles.maxAxis, 'String'));
% yMinlimit = str2double(get(handles.minAxis, 'String'));
% set(gca, 'YLim', [yMinlimit yMaxlimit]);

axis tight;
oldFolder = pwd;
foldername = handles.foldername;
pathname=sprintf('%s/Plots',foldername);
[minT maxT] = getTLim(handles)
if ~exist(pathname,'dir')
    mkdir(foldername,'Plots'); 
end
%
cd(pathname);
% fullpathname=sprintf('%s/Plots/ActiveROIs.pdf',foldername);
%export_fig fullpathname
export_fig ActiveROIs.pdf
%
cd(oldFolder);
end













