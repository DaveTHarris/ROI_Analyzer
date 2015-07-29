function varargout = ROI_Analyzer(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_Analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_Analyzer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ROI_Analyzer is made visible.
function ROI_Analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROICalc (see VARARGIN)

    % Choose default command line output for ROICalc
    currpath = pwd;

    addpath(genpath('saveastiff'));
    addpath(genpath('export_fig'));
    cd(currpath);
    %This utilizes parallel processing. In some cases it can increase
    %performance
    matlabpool('open',4);
    handles.output = hObject;
    set(handles.figure1, 'CloseRequestFcn', @closeGui);
    set(handles.figure1, 'WindowButtonUpFcn', @mouseFunction);
    have_KeyPressFcn = findobj('KeyPressFcn', '');
    for i = 1:length(have_KeyPressFcn)
        set(have_KeyPressFcn(i), 'KeyPressFcn', @keyFunction);
    end    
     
    % init all variables 
    handles.dfofotImage(1:6)={zeros(512,512,3)};     
    set(handles.imAxes, 'Visible', 'off');    
    set(handles.maxZText, 'String', num2str(1));
    set(handles.maxTText, 'String', num2str(1));
    set(handles.tSlider, 'Max', 1);
    set(handles.tSlider, 'Min', 0);
    set(handles.tSlider, 'Value', 1);
    set(handles.currTText, 'String', '1');
    set(handles.dfofMinTEdit, 'String', '1');
    set(handles.minTEdit, 'String', '1');
    set(handles.maxTEdit, 'String', num2str(1));
    set(handles.dfofMaxTEdit, 'String', '1');
    set(handles.minZEdit, 'String', '1');
    set(handles.maxZEdit, 'String', num2str(1));
    set(handles.zSlider, 'Max', 1);    
    set(handles.zSlider, 'Min', 0);
    set(handles.zSlider, 'Value', 1);
    set(handles.senseSlider,'Max',1);
    set(handles.threshSlider,'Max',1);
    set(handles.senseSlider,'Min',0);
    set(handles.threshSlider,'Min',0);
   
    %Default Values for nucleus detection
    set(handles.senseSlider,'Value',.98);
    set(handles.threshSlider,'Value',.04);
    
    set(handles.bluechannel,'Enable','off');
    set(handles.traB,'Value',0);
    set(handles.traB,'Enable','off');
    set(handles.greenVsBlue,'Enable','off');
    set(handles.currZText, 'String', '1');
    set(handles.numROISlice, 'String','0');
    set(handles.numROItotal, 'String','0');
    set(handles.imAxes, 'Units', 'Normalized');
    set(handles.dfofMinTEdit, 'Enable', 'on');
    set(handles.dfofMaxTEdit, 'Enable', 'on');          
    handles.rgbcolor = [1 0 0];
    handles.savepath = '';
    handles.savename = '';
    handles.currzdfofimg = zeros(512,512);   
    set(handles.col_Active,'Value',1);
    set(handles.col_Matched,'Value',0);
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_Analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function closeGui(hObject, eventdata)
    matlabpool close;
    handles = guidata(hObject);
    delete(handles.figure1);

function mouseFunction(hObject, eventdata)

function keyFunction(hObject, eventdata)
%This function establish key bindings for moving up and down through
% the z stack and back and forward through time    
handles = guidata(hObject);
    k = eventdata.Key;
    switch k
        case 'j' % slide z down
            
            hObject = handles.zSlider;
            sliderVal = get(handles.zSlider, 'Value');
            if (sliderVal-1) >= get(handles.zSlider, 'Min')
                set(handles.zSlider, 'Value', sliderVal-1);
                zSlider_Callback(hObject, [], handles);
            end
        case 'k' % slide z up
            
            hObject = handles.zSlider;
            sliderVal = get(handles.zSlider, 'Value');
            if (sliderVal+1) <= get(handles.zSlider, 'Max')
                set(handles.zSlider, 'Value', sliderVal+1);
                zSlider_Callback(hObject, [], handles);
            end
        case 'h' % slide t left
            hObject = handles.tSlider;
            sliderVal = get(handles.tSlider, 'Value');
            if (sliderVal-1) >= get(handles.tSlider, 'Min')
                set(handles.tSlider, 'Value', sliderVal-1);
                tSlider_Callback(hObject, [], handles);
            end
        case 'l' % slide t right
            hObject = handles.tSlider;
            sliderVal = get(handles.tSlider, 'Value');
            if (sliderVal+1) <= get(handles.tSlider, 'Max')
                set(handles.tSlider, 'Value', sliderVal+1);
                tSlider_Callback(hObject, [], handles);
            end
        case 'q'
            closeGui = handles.figure1;
            close(closeGui);
        otherwise
    end
    
    
% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % Construct a questdlg with two options. One stim is the default.
    choice = questdlg('How many stims?', ...
	'Number of Stimulations', ...
	'One','Two','One');

    % Handle response
    switch choice
        case 'One'
            stimNum = 1;
        case 'Two'
            stimNum = 2;
    end
    %This code allows the user to choose a directory for their
    %stimulations.
    if stimNum == 1;
        foldername = uigetdir('Pick directory of Stim 1 Images');
    end
    if stimNum == 2;
        foldername = uigetdir('Pick directory of Stim 2 Images');
        foldername2 = uigetdir(foldername,'Pick directory of Stim 2 Images');
    end
    handles.stimNum = stimNum;
    nuclearfolder=uigetdir(foldername,'Pick directory of Alignment Images');
    fullnuclearname = strcat(nuclearfolder,'\C561.tiff');
    fullalignname = strcat(nuclearfolder,'\C488.tiff');
    if foldername == 0
        return;
    end
    if ispc
        temp = regexp(foldername, '\', 'split');
    else
        temp = regexp(foldername, '/', 'split');
    end
    dirname = temp(end);
    handles.dirname = dirname;
    handles.foldername = foldername;
    handles.savename = '';
    if stimNum == 2
        handles.foldername2 = foldername2;
    end
    handles.nuclearfolder = nuclearfolder;
    [~, zslices, width, height, duration] = stackinfo(foldername, true);
    handles.width = width;
    handles.height = height;
    
    % set all the UI elements
    % general setup stuff
    set(handles.imAxes, 'Visible', 'on');
    set(handles.zSlider, 'Visible', 'on');
    set(handles.greenchan, 'Value', 1);
    set(handles.redchannel, 'Value', 1);
    %We only want the blue radio button available if there are two stims.
    if stimNum == 2
        set(handles.bluechannel,'Enable','on');
        set(handles.traB,'Enable','on');
        set(handles.greenVsBlue,'Enable','on');
        set(handles.bluechannel, 'Value', 1);
        set(handles.col_Matched, 'Enable','off');
        
    end
    set(handles.deltafRadio, 'Value',0);
    set(handles.showROIbut,'Value',1); 
    set(handles.showActiveROIs,'Value',0);
  

    % setup max Z and T fields (Read-Only)
    set(handles.maxZText, 'String', num2str(zslices));
    set(handles.maxTText, 'String', num2str(duration));
    
    % setup T slider and min/max T
    set(handles.tSlider, 'Max', duration);
    set(handles.tSlider, 'Min', 1);
    set(handles.tSlider, 'Value', 1);
    set(handles.currTText, 'String', '1');
    set(handles.minTEdit, 'String', '1');
    set(handles.dfofMinTEdit, 'String', '2');
   
    set(handles.maxTEdit, 'String', num2str(duration));
    set(handles.dfofMaxTEdit, 'String', '4');
    

    % setup Z slider and min/max Z
    set(handles.zSlider, 'Max', zslices);    
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', 1);
    set(handles.currZText, 'String', '1');
    set(handles.minZEdit, 'Enable', 'on');
    set(handles.maxZEdit', 'Enable', 'on');
     
    set(handles.upButton, 'Enable', 'on');
    set(handles.downButton, 'Enable', 'on');

    set(handles.minZEdit, 'String', '1');
    set(handles.maxZEdit, 'String', num2str(zslices));
    
    set(handles.minAxis, 'String', 5);
    set(handles.maxAxis, 'String', 6);
    set(handles.stDevmultiplier, 'String', 10);
    
    % setup main axes
    set(handles.imAxes, 'XLim', [1 handles.width]);
    set(handles.imAxes, 'YLim', [1 handles.height]);
    

    % load images
    fnames = dir(strcat(foldername,'/*.tiff'));
    if isempty(fnames)
        fnames = dir(strcat(foldername,'/*.tif'));
    end
    imname = strcat(foldername,'/',fnames(1).name);   
    
    info = imfinfo(imname);

    Width = info(1).Width;
    Height = info(1).Height;
    ZSlices = numel(info);
    Duration = numel(fnames);
    %assignin('base','foldername',foldername);
    Images = uint16(zeros(Width, Height, Duration, ZSlices));
    nuclearData = uint16(zeros(Width,Height,ZSlices));
    alignData = uint16(zeros(Width,Height,ZSlices));
       
    % This code loads the images     
    parfor i=1:Duration    
        fprintf('Loading slice T=%d\n',i);
        fullname = strcat(foldername,'/', fnames(i).name);
        Images(:,:,i,:) = double(loadtiff(fullname));    

    end
    % This is the field that holds the image data for stim 1
    handles.imgdata = Images;

    nuclearData=loadtiff(fullnuclearname);
    alignData=loadtiff(fullalignname);
    % assignin('base','nuclearData',nuclearData);
    
    % This is the field that holds the image data for the Nuclei
    handles.nuclearData = nuclearData(:,:,:);
    % This is the field that holds the image data for the Green channel of
    % the alignment images
    handles.alignData = alignData(:,:,:);

    % This is the field that holds all of the ROI data for stim 1
    handles.totalROIdataSlice=cell(ZSlices,7);
    
    if stimNum == 2
        % This is the field that holds all of the ROI data for stim 2
        handles.totalROIdataSlice2=cell(ZSlices,7);
        
    end
    handles.markerROI=cell(ZSlices,6);

      
    
    %If there are two stimulations then this section of code loads the
    %second stimulation.
    if stimNum == 2
      
        fnames2 = dir(strcat(foldername2,'/*.tiff'));
        if isempty(fnames2)
            fnames2 = dir(strcat(foldername2,'/*.tif'));
        end
        imname2 = strcat(foldername2,'/',fnames2(1).name);   

        info = imfinfo(imname2);

        Width = info(1).Width;
        Height = info(1).Height;
        ZSlices = numel(info);
        Duration2 = numel(fnames2);
        %assignin('base','foldername2',foldername2);
        Images2 = uint16(zeros(Width, Height, Duration, ZSlices));
        %assignin('base','Images2',Images2);

   
        parfor i=1:Duration2    
            fprintf('Loading slice T=%d\n',i);
            fullname2 = strcat(foldername2,'/', fnames2(i).name);
            Images2(:,:,i,:) = double(loadtiff(fullname2));    

        end
        if Duration2 < Duration
           for i = Duration2:Duration 
           Images2(:,:,i,:)=Images2(:,:,Duration2,:); 
           end
        end
        % This is the field that holds the image data for stim 2
        handles.imgdata2 = Images2;
    
    end
     
    
   
    
    % setup mask data structure
    handles.masks = cell(ZSlices,1);
    handles.numMasks = zeros(ZSlices,1);
    handles.xPoints = cell(ZSlices,1);
    handles.yPoints = cell(ZSlices,1);
    handles.colors = cell(ZSlices,1);
    handles.showRoi = cell(ZSlices,1);
    for i=1:ZSlices
        handles.colors{i} = [1;0;0];
        handles.showRoi{i} = [];
       
    end
    
    tSlider_Callback(hObject, [], handles);
    zSlider_Callback(hObject, [], handles);
    
    % Setup new ellipse ROI data structure
    handles.newROICenterX = cell(ZSlices,1);
    handles.newROICenterY = cell(ZSlices,1);
    handles.newROIRad = cell(ZSlices,1);
    
    guidata(hObject, handles);

% checks if the string 
function [numberq, val] = checkNumeric(h)
    val = str2double(get(h, 'String'));
    if ~isnan(val)
        numberq = true;
    else
        numberq = false;
    end
    
% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    sliderVal = get(handles.tSlider, 'Value');
    sliderVal = round(sliderVal);
    set(handles.currTText, 'String', num2str(sliderVal));  
    
    handles = image_redraw(handles);
    % This following code is deprecated. It was used when allowing freehand
    % drawn ROIs. The current version uses only ellipses for cell bodies%
    % handles = drawroicallback(handles);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    sliderVal = get(handles.zSlider, 'Value');
    sliderVal = round(sliderVal);
    set(handles.currZText, 'String', num2str(sliderVal));
    
    handles = image_redraw(handles);
   % This sets the handle to the plotting window.
    h = handles.dataAxes;
    axes(handles.dataAxes);
    cla;
    %handles = drawroicallback(handles);
    [T Z] = getTZ(handles);
    [minT, maxT] = getTLim(handles);
    A=handles.totalROIdataSlice;
    if handles.stimNum == 2
        B=handles.totalROIdataSlice2;
    end
    %assignin('base', 'handles', handles);
    if ~isempty(A{Z,1})

        plotType = getCurrentPlotType(handles);
        dfoff = zeros(minT:maxT,size(handles.totalROIdataSlice{Z,1},1));
        for i = 1:size(handles.totalROIdataSlice{Z,1},1)
            for j = minT:maxT
               % assignin('base','testhandles',handles);
                dfoff(j,i)=handles.totalROIdataSlice{Z,1}{i,4}(j);    
            end

        end
        dfoff = dfoff';

        % use same colors as ROIs seen on screen
        %assignin('base','handles',handles); 
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
        
    
    
    
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function zSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function [res, handles] = checkTZBound(handles)
    % This function checks to make sure that the values in the timepoint
    % and z slice sections are allowed.
     [miz, minZ] = checkNumeric(handles.minZEdit);
     [maz, maxZ] = checkNumeric(handles.maxZEdit);
     absMaxZ = str2double(get(handles.maxZText, 'String'));
     res = true;
    if minZ > absMaxZ || minZ < 1 || maxZ > absMaxZ || maxZ < 1 ...
            || ~miz || ~maz
        msgbox('Value is < 1 or > maxZ', '', 'error');
        uiwait;
        set(handles.minZEdit, 'String', '1');
        set(handles.maxZEdit, 'String', num2str(absMaxZ));
        res = false;
    end
    %minT = str2double(get(handles.minTEdit, 'String'));
    %maxT = str2double(get(handles.maxTEdit, 'String'));
    [mit, minT] = checkNumeric(handles.minTEdit);
    [mat, maxT] = checkNumeric(handles.maxTEdit);
    absMaxT = str2double(get(handles.maxTText, 'String'));
    if minT > absMaxT || minT < 1 ||  maxT > absMaxT ||maxT < 1 ...
            || ~mit || ~mat
        msgbox('Value is < 1 or > maxT', '', 'error');
        uiwait;
        set(handles.minTEdit, 'String', '1');        
        set(handles.maxTEdit, 'String', num2str(absMaxT));
        res = false;
    end
    
    
    
function minZEdit_Callback(hObject, eventdata, handles)
% This function executes on changing the data in the Z axis window.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    [res, handles] = checkTZBound(handles);
    if res
        val = str2double(get(handles.minZEdit, 'String'));
        set(handles.zSlider, 'Min', val);
        set(handles.zSlider, 'Value', val);
        zSlider_Callback(hObject,[],handles);
    end
    guidata(hObject, handles);
    

% --- Executes during object creation, after setting all properties.
function minZEdit_CreateFcn(hObject, eventdata, handles)
% This function executes on changing the data in the Z axis window.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minTEdit_Callback(hObject, eventdata, handles)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

    [res, handles] = checkTZBound(handles);
    if res
        val = str2double(get(handles.minTEdit, 'String'));
        set(handles.tSlider, 'Min', val);
        set(handles.tSlider, 'Value', val);
        tSlider_Callback(hObject,[],handles);
        set(handles.dfofMinTEdit, 'String', get(handles.minTEdit, 'String'));
    end
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function minTEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxZEdit_Callback(hObject, eventdata, handles)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
   
    [res, handles] = checkTZBound(handles);
    if res
        val = str2double(get(handles.maxZEdit, 'String'));
        set(handles.zSlider, 'Max', val);
        set(handles.zSlider, 'Value', get(handles.zSlider, 'Min'));
        zSlider_Callback(hObject,[],handles);
    end
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function maxZEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxTEdit_Callback(hObject, eventdata, handles)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    [res, handles] = checkTZBound(handles);
    if res
        val = str2double(get(handles.maxTEdit, 'String'));
        set(handles.tSlider, 'Max', val);
        set(handles.tSlider, 'Value', get(handles.tSlider, 'Min'));
        tSlider_Callback(hObject,[],handles);     
        
        set(handles.dfofMaxTEdit, 'String', get(handles.maxTEdit, 'String'));
    end
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function maxTEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in undoRoiButton.
function undoRoiButton_Callback(hObject, eventdata, handles)
% While the tag for this function is "undoROIButton", this function
% actually is for adding multiple ROIs. It was repurposed.

handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
if handles.stimNum == 2
    handles = AddROIsblue(handles);
else
    handles = AddROIs(handles);
end
[T Z] = getTZ(handles);
if ~isempty(handles.totalROIdataSlice{Z,1});
    if handles.stimNum == 2
        handles = updDataAx2Stim(handles);
    else
        handles = updDataAx1Stim(handles);
    end
end
handles = image_redraw(handles);
guidata(hObject, handles);


    


% --- Executes when selected object is changed in plotOptionsGroup.
function plotOptionsGroup_SelectionChangeFcn(hObject, eventdata, handles)
% This function re-calculates the data for individual ROIs for plotting in
% the data window.
    if handles.stimNum == 2
        handles = updDataAx2Stim(handles);
    else
        handles = updDataAx1Stim(handles);
    end
    guidata(hObject, handles);


% --- Executes on button press in roiShowNumberCheck.
function roiShowNumberCheck_Callback(hObject, eventdata, handles)
% This function turns the ROI numbers on or off.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    handles = image_redraw(handles);
    % handles = drawroicallback(handles);
    if handles.stimNum == 2
        handles = updDataAx2Stim(handles);
    else
        handles = updDataAx1Stim(handles);
    end
    guidata(hObject, handles);



function dfofMinTEdit_Callback(hObject, eventdata, handles)
% This function is called when the edit box that controls the minimum value
% for F initial is edited. This sets the first timepoint with which to
% calculate f initial.
    [mit, minT] = checkNumeric(handles.dfofMinTEdit);
    minUseT = str2double(get(handles.minTEdit, 'String'));
    if ~mit 
        msgbox('Min T not numeric', '', 'error');
        set(handles.dfofMinTEdit, 'String', get(handles.minTEdit, 'String'));
        guidata(hObject, handles);
        return;
    end
    handles.minThresh = str2num(get(handles.minAxis,'string'));
    handles.maxThresh = str2num(get(handles.maxAxis,'string'));
    
    if handles.stimNum == 2
        handles = updDataAx2Stim(handles);
    else
        handles = updDataAx1Stim(handles);
    end
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function dfofMinTEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dfofMaxTEdit_Callback(hObject, eventdata, handles)
% This function is called when the edit box that controls the maximum value
% for F initial is edited. This sets the last timepoint with which to
% calculate f initial.
    [mat, maxT] = checkNumeric(handles.dfofMaxTEdit);
    maxUseT = str2double(get(handles.maxTEdit, 'String'));
    if ~mat 
        msgbox('Max T not numeric', '', 'error');
        set(handles.dfofMinTEdit, 'String', get(handles.minTEdit, 'String'));
        guidata(hObject, handles);
        return;
    end
    handles.minThresh = str2num(get(handles.minAxis,'string'));
    handles.maxThresh = str2num(get(handles.maxAxis,'string'));
    
    if handles.stimNum == 2
        handles = updDataAx2Stim(handles);
    else
        handles = updDataAx1Stim(handles);
    end
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dfofMaxTEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    

% --- Executes on slider movement.
function dfofFgThreshSlider_Callback(hObject, eventdata, handles)
% Nothing actually executes when the slider is changed. The value of the
% slider is only grabbed from other functions when updating the image in
% the main axis.

% --- Executes during object creation, after setting all properties.
function dfofFgThreshSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% The below code is deprecated
% --- Executes on button press in deleteAllRoiButton.
% function deleteAllRoiButton_Callback(hObject, eventdata, handles)
% % This function deletes all of the ROIs
% handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
% handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
%     
%     if isZProj(handles)
%         ZSlices = 1;
%     else
%         ZSlices = str2double(get(handles.maxZText,'String'));
%     end
%     for i=1:ZSlices
%         handles.masks{i} = [];
%         handles.numMasks(i) = 0;
%         handles.xPoints{i} = [];
%         handles.yPoints{i} = [];
%         handles.colors{i} = [];
%         handles.showRoi{i} = [];
%     end
%     handles = updateroitable(handles);
%     handles = image_redraw(handles);
%     handles = drawroicallback(handles);
%     if handles.stimNum == 2
%         handles = updDataAx2Stim(handles);
%     else
%         handles = updDataAx1Stim(handles);
%     end
%     guidata(hObject, handles);
        




% --- Executes on button press in Button.
function toggleRoisButton_Callback(hObject, eventdata, handles)
% This function allows the user to draw a polygon in order to remove
% multiple masks at once. The button is "Mask ROIs"
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    [T Z] = getTZ(handles);
    axes(handles.imAxes);
    BW=roipoly;

    counter = 1;
    for i = 1:size(handles.totalROIdataSlice{Z,1},1)
       if BW(round(handles.totalROIdataSlice{Z,1}{i,2}),round(handles.totalROIdataSlice{Z,1}{i,1}))== 0
           handles.totalROIdataSlice{Z,1}{counter,1}=handles.totalROIdataSlice{Z,1}{i,1};
           handles.totalROIdataSlice{Z,1}{counter,2}=handles.totalROIdataSlice{Z,1}{i,2};
           handles.totalROIdataSlice{Z,1}{counter,3}=handles.totalROIdataSlice{Z,1}{i,3};
           handles.totalROIdataSlice{Z,1}{counter,4}=handles.totalROIdataSlice{Z,1}{i,4};
           handles.totalROIdataSlice{Z,1}{counter,5}=handles.totalROIdataSlice{Z,1}{i,5};
           counter = counter +1;
       end
       
    end
    handles.totalROIdataSlice{Z,1}=handles.totalROIdataSlice{Z,1}(1:counter,:);
    counter = 1;
    if handles.stimNum == 2
        for i = 1:size(handles.totalROIdataSlice2{Z,1},1)
           if BW(round(handles.totalROIdataSlice2{Z,1}{i,2}),round(handles.totalROIdataSlice2{Z,1}{i,1}))== 0
               handles.totalROIdataSlice2{Z,1}{counter,1}=handles.totalROIdataSlice2{Z,1}{i,1};
               handles.totalROIdataSlice2{Z,1}{counter,2}=handles.totalROIdataSlice2{Z,1}{i,2};
               handles.totalROIdataSlice2{Z,1}{counter,3}=handles.totalROIdataSlice2{Z,1}{i,3};
               handles.totalROIdataSlice2{Z,1}{counter,4}=handles.totalROIdataSlice2{Z,1}{i,4};
               handles.totalROIdataSlice2{Z,1}{counter,5}=handles.totalROIdataSlice2{Z,1}{i,5};
               counter = counter +1;
           end
       
        end
        handles.totalROIdataSlice2{Z,1}=handles.totalROIdataSlice2{Z,1}(1:counter,:);
    end
    
    if (get(handles.updData,'Value') == get(handles.updData,'Max'))
        if handles.stimNum == 2
            handles = updDataAx2Stim(handles);
        else
            handles = updDataAx1Stim(handles);
        end
    end
    handles = image_redraw(handles);
    guidata(hObject, handles);


% % --- Executes when selected object is changed in colorPanel.
% function colorPanel_SelectionChangeFcn(hObject, eventdata, handles)
% handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
% handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
%     
%     
% ZSlices = str2double(get(handles.maxZText,'String'));
%     
%    for i=1:ZSlices
%        handles.colors{i} = [];
%    end
%    switch get(eventdata.NewValue,'Tag')
%        case 'random'
%            for i=1:ZSlices
%                for j=1:handles.numMasks(i)
%                    handles.colors{i} = add_random_colors(handles.colors{i}, 0.4);
%                end
%            end
%        case 'depth'
%            for i=1:ZSlices
%                for j=1:handles.numMasks(i)
%                    handles.colors{i} = add_z_colors(handles.colors{i}, i, ZSlices);
%                end
%            end
%        case 'fixed'
%            
%             rgb = uisetcolor;
%             if rgb == 0
%                 fprintf('No color chosen...setting color to red\n');
%                 rgb = [1 0 0];
%             end
%             handles.rgbcolor = rgb;
%                        
%            for i=1:ZSlices
%                for j=1:handles.numMasks(i)
%                     handles.colors{i} = add_fixed_colors(handles.colors{i}, handles.rgbcolor);
%                end
%            end
%        otherwise
%    end
%    
%    handles = updateroitable(handles);
%    handles = image_redraw(handles);
%   % handles = drawroicallback(handles);
%    if handles.stimNum == 2
%         handles = updDataAx2Stim(handles);
%    else
%         handles = updDataAx1Stim(handles);
%    end
%    guidata(hObject, handles);

 

% --- Executes on button press in upButton.
function upButton_Callback(hObject, eventdata, handles)
    eventdata.Key = 'k';
    keyFunction(hObject, eventdata)
    guidata(hObject, handles);
    
% --- Executes on button press in downButton.
function downButton_Callback(hObject, eventdata, handles)
    eventdata.Key = 'j';
    keyFunction(hObject, eventdata)
    guidata(hObject, handles);

% --- Executes on button press in leftButton.
function leftButton_Callback(hObject, eventdata, handles)
    eventdata.Key = 'h';
    keyFunction(hObject, eventdata)
    guidata(hObject, handles);

% --- Executes on button press in rightButton.
function rightButton_Callback(hObject, eventdata, handles)
    eventdata.Key = 'l';
    keyFunction(hObject, eventdata)
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function colorPanel_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in addEllipseRoiButton.
function addEllipseRoiButton_Callback(hObject, eventdata, handles)
% This function adds ellipse ROIs to the window. It then calls functions to
% process the data within the ROI.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
    [T Z] = getTZ(handles);
    [minZ maxZ] = getZLim(handles);
    
    h = imellipse(handles.imAxes);
    h.setFixedAspectRatioMode( '1' );
    circlepos = getPosition(h);
    roiPos = getPosition(h);
    roiCenter = [round(roiPos(1)+.5*roiPos(3)) round(roiPos(2)+.5*roiPos(4))];
    roiRadius = round(.5*roiPos(3));
    newROICenterX = round(circlepos(1,1))+round(.5*circlepos(1,3));
    newROICenterY = round(circlepos(1,2))+round(.5*circlepos(1,4));
    newROIRad = round(.5*circlepos(1,3));
    slice = Z;
    
    roiNum = size(handles.totalROIdataSlice{slice,1},1) + 1;
    handles.totalROIdataSlice{slice,1}{roiNum,1}=roiCenter(1);
    handles.totalROIdataSlice{slice,1}{roiNum,2}=roiCenter(2);
    handles.totalROIdataSlice{slice,1}{roiNum,3}=roiRadius;
   
    if handles.stimNum == 2
        handles.totalROIdataSlice2{slice,1}{roiNum,1}=roiCenter(1);
        handles.totalROIdataSlice2{slice,1}{roiNum,2}=roiCenter(2);
        handles.totalROIdataSlice2{slice,1}{roiNum,3}=roiRadius;
    end
     pos = wait(h);        
     xi = pos(:,1);
     yi = pos(:,2);
        
    if (get(handles.updData,'Value') == get(handles.updData,'Max'))
        if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
        else
            handles = updDataAx1Stim ( handles );
        end
    end
    handles = image_redraw(handles);
    guidata(hObject, handles);



function maxAxis_Callback(hObject, eventdata, handles)
% hObject    handle to maxAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAxis as text
%        str2double(get(hObject,'String')) returns contents of maxAxis as a double
    %handles=updDataAx2Stim( handles, gca);



% --- Executes during object creation, after setting all properties.
function maxAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function minAxis_Callback(hObject, eventdata, handles)
% hObject    handle to minAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minAxis as text
%        str2double(get(hObject,'String')) returns contents of minAxis as a double

    %handles=updDataAx2Stim( handles, gca);


% --- Executes during object creation, after setting all properties.
function minAxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function roiName_Callback(hObject, eventdata, handles)
% hObject    handle to roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roiName as text
%        str2double(get(hObject,'String')) returns contents of roiName as a double


% --- Executes during object creation, after setting all properties.
function roiName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
       set(hObject,'BackgroundColor','white');
    end



% --- Executes on button press in greenchan.
function greenchan_Callback(hObject, eventdata, handles)
% This function toggles the green channel on or off.

% Hint: get(hObject,'Value') returns toggle state of greenchan
handles = image_redraw(handles);
guidata(hObject, handles);



% --- Executes on button press in redchannel.
function redchannel_Callback(hObject, eventdata, handles)
% This function toggles the red channel on or off.
handles = image_redraw(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of redchannel



% --- Executes on button press in deltafRadio.
function deltafRadio_Callback(hObject, eventdata, handles)
% This function toggles "Delta F" Mode. This mode shows the DeltaF image
% data instead of the Raw data. The delta F image is the current frame data
% minus the average of the image data as defined in the DeltaF min and max
% windows. When this function is called, the deltaF data are calculated for
% all slices.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

Images = handles.imgdata;
if handles.stimNum == 2
    Images2 = handles.imgdata2;
end
[minT maxT]=getdfofRange(handles);

for k = 1:size(Images,4)
    for i = 1:size(Images,3)
       
        meanImage=uint16(round(mean(Images(:,:,minT:maxT,k),3)));
        deltaFimage(:,:,i,k)=(Images(:,:,i,k)-meanImage);
        deltaFoFimage(:,:,i,k)=double(deltaFimage(:,:,i,k))./double(meanImage);
        if handles.stimNum == 2
            meanImage2=uint16(round(mean(Images2(:,:,minT:maxT,k),3)));
            deltaFimage2(:,:,i,k)=(Images2(:,:,i,k)-meanImage2);
            deltaFoFimage2(:,:,i,k)=double(deltaFimage2(:,:,i,k))./double(meanImage2);
        end
     
    end
end

% The Delta F data are saved in the handles object below.
handles.deltaFimagedata = deltaFimage;
handles.deltaFoFimagedata = deltaFoFimage;
if handles.stimNum == 2
    handles.deltaFimagedata2 = deltaFimage2;
    handles.deltaFoFimagedata2 = deltaFoFimage2;
end
handles = image_redraw(handles);
guidata(hObject, handles);



% --- Executes on button press in detectNuclei.
function detectNuclei_Callback(hObject, eventdata, handles)
% This function detects the nuclei using the red channel in the image.
% Circles are detected using a Hough circle finding algorithm. The settings
% for this algorithm are changeable using a slider. There are also steps
% taken to prevent overlapping ROIs.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles.minThresh = str2num(get(handles.minAxis,'string'));
handles.maxThresh = str2num(get(handles.maxAxis,'string'));
handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));

handles = nucDetect(handles);

set(handles.showActiveROIs,'Value',0);
set(handles.showROIbut,'Value',1);
 if (get(handles.updData,'Value') == get(handles.updData,'Max'))
    if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
    else
            handles = updDataAx1Stim ( handles );
    end
 end
handles = image_redraw(handles);

guidata(hObject, handles);

% --- Executes on slider movement.
function senseSlider_Callback(hObject, eventdata, handles)
% This function changes the sensitivity used in the nucleus detection. It
% alters one of the parameters of the hough transform.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

handles = nucDetect(handles);
if (get(handles.updData,'Value') == get(handles.updData,'Max'))
    if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
    else
            handles = updDataAx1Stim ( handles );
    end
end
set(handles.showROIbut,'Value',1);
handles = image_redraw(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function senseSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function threshSlider_Callback(hObject, eventdata, handles)
% This function changes the threshold used in the nucleus detection. It
% alters one of the parameters of the hough transform.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

handles = nucDetect(handles);
if (get(handles.updData,'Value') == get(handles.updData,'Max'))
    if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
    else
            handles = updDataAx1Stim ( handles );
    end
end
set(handles.showROIbut,'Value',1);
handles = image_redraw(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function threshSlider_CreateFcn(hObject, eventdata, handles)
% This function changes the threshold used in the nucleus detection. It
% alters one of the parameters of the hough transform.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in defaultButton.
function defaultButton_Callback(hObject, eventdata, handles)
% This function resets the default values to the nuclei detection function.
    
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

set(handles.senseSlider,'Value',.96);
set(handles.threshSlider,'Value',.09);
handles = nucDetect(handles);
handles = image_redraw(handles);
guidata(hObject, handles);
    


% --- Executes on button press in showROIbut.
function showROIbut_Callback(hObject, eventdata, handles)
% This function toggles whether or not to show ROIs in the main figure
% window.
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
handles = image_redraw(handles);
    guidata(hObject, handles);
    



% --- Executes on button press in showActiveROIs.
function showActiveROIs_Callback(hObject, eventdata, handles)
% This function toggles showing the ROIs that satisfy the criteria to be
% "Active"

handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    
%set(handles.showROIbut,'Value',0);

handles = image_redraw(handles);
guidata(hObject, handles);


function stDevmultiplier_Callback(hObject, eventdata, handles)
% This function was removed. But I will change it to set the "Active"
% criterion.
if (handles.stimNum == 2)
    handles = updDataAx2Stim(handles);
else
    handles = updDataAx1Stim(handles);
end

handles = image_redraw(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stDevmultiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stDevmultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exprtActiveMark.
function exprtActiveMark_Callback(hObject, eventdata, handles)
% hObject    handle to exprtActiveMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
foldername = handles.foldername;
totalROIdataSlice = handles.totalROIdataSlice;
totalROIdataSlice2 = handles.totalROIdataSlice2;
pathname=sprintf('%s/Markers',foldername);
if ~exist(pathname,'dir')
   mkdir(foldername,'Markers'); 
end
adder = 1;
if handles.stimNum == 1
    for i = 1:size(totalROIdataSlice,1);
        z=i;

        for j = 1:size(totalROIdataSlice{i,1},1)
            if totalROIdataSlice{i,1}{j,5}==2
                x = totalROIdataSlice{i,1}{j,1};
                y = totalROIdataSlice{i,1}{j,2};
                marker{adder,1}=x;
                marker{adder,2}=y;
                marker{adder,3}=z;
                marker{adder,4}=10;
                marker{adder,5}=2;
                marker{adder,6}=adder;
                marker{adder,7}='Stim 1';
               
                adder = adder+1;
            end
        end

    end
end
if handles.stimNum == 2
    for i = 1:size(totalROIdataSlice2,1);
    z=i;
        for j = 1:size(totalROIdataSlice2{i,1},1)
            if totalROIdataSlice2{i,1}{j,5}==2 & totalROIdataSlice{i,1}{j,5}==2
                x = totalROIdataSlice2{i,1}{j,1};
                y = totalROIdataSlice2{i,1}{j,2};
                marker{adder,1}=x;
                marker{adder,2}=y;
                marker{adder,3}=z;
                marker{adder,4}=10;
                marker{adder,5}=2;
                marker{adder,6}=adder;
                marker{adder,7}= 'Both';
                
                adder = adder+1;
            elseif totalROIdataSlice2{i,1}{j,5}==2
                x = totalROIdataSlice2{i,1}{j,1};
                y = totalROIdataSlice2{i,1}{j,2};
                marker{adder,1}=x;
                marker{adder,2}=y;
                marker{adder,3}=z;
                marker{adder,4}=10;
                marker{adder,5}=2;
                marker{adder,6}=adder;
                marker{adder,7}='Stim 2';
                
                adder = adder+1;
            elseif totalROIdataSlice{i,1}{j,5}==2 
                x = totalROIdataSlice2{i,1}{j,1};
                y = totalROIdataSlice2{i,1}{j,2};
                marker{adder,1}=x;
                marker{adder,2}=y;
                marker{adder,3}=z;
                marker{adder,4}=10;
                marker{adder,5}=2;
                marker{adder,6}=adder;
                marker{adder,7}='Stim 1';
                
                adder = adder+1;
                
            end
        end

    end
end

fullpathname=sprintf('%s/Markers/ActiveROIS.marker',foldername);
%assignin('base','fullpathname',fullpathname);
%assignin('base','marker',marker);
cell2csv(fullpathname,marker);

% --- Executes on button press in exprtAllMark.
function exprtAllMark_Callback(hObject, eventdata, handles)
% hObject    handle to exprtAllMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%The .marker file format is ##x,y,z,radius,shape,name,comment, color_r,color_g,color_b 
foldername = handles.foldername;
totalROIdataSlice = handles.totalROIdataSlice;
pathname=sprintf('%s/Markers',foldername);
if ~exist(pathname,'dir')
   mkdir(foldername,'Markers'); 
end

adder = 0;
%assignin('base','handles',handles);
for i = 1:size(totalROIdataSlice,1);
    z=i;
    
    for j = 1:size(totalROIdataSlice{i,1},1)
        adder = adder+1;
        x = totalROIdataSlice{i,1}{j,1};
        y = totalROIdataSlice{i,1}{j,2};
        marker{adder,1}=x;
        marker{adder,2}=y;
        marker{adder,3}=z;
        marker{adder,4}=10;
        marker{adder,5}=2;
        marker{adder,6}=[];
        marker{adder,7}=[];
        
        
    end

end
if handles.stimNum == 2
    for i = 1:size(totalROIdataSlice2,1);
    z=i;
        for j = 1:size(totalROIdataSlice2{i,1},1)
        adder = adder+1;
        x = totalROIdataSlice2{i,1}{j,1};
        y = totalROIdataSlice2{i,1}{j,2};
        marker{adder,1}=x;
        marker{adder,2}=y;
        marker{adder,3}=z;
        marker{adder,4}=10;
        marker{adder,5}=2;
        marker{adder,6}=[];
        marker{adder,7}=[]; 
        end

    end
end 

%assignin('base','foldername',foldername);
%assignin('base','pathname',pathname);
%assignin('base','marker',marker);
fullpathname=sprintf('%s/Markers/AllROIS.marker',foldername);
%assignin('base','fullpathname',fullpathname);

cell2csv(fullpathname,marker);


% --- Executes on button press in saveDeltaFstack.
function saveDeltaFstack_Callback(hObject, eventdata, handles)
% hObject    handle to saveDeltaFstack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.stimNum == 2
     
    if get(handles.traG,'Value') == get(handles.traG,'Max') && get(handles.traB,'Value') == get(handles.traB,'Max')    
        if get(handles.showROIbut,'Value') == get(handles.showROIbut,'Max')
            savedeltaFstackBlue( handles );
        else
            savedeltaFstackBluenomask( handles );
        end
    elseif get(handles.traG,'Value') == get(handles.traG,'Max') && get(handles.traB,'Value') == get(handles.traB,'Min')
            savedeltaFstackStim1 ( handles );   
    elseif get(handles.traG,'Value') == get(handles.traG,'Min') && get(handles.traB,'Value') == get(handles.traB,'Max')
            savedeltaFstackStim2 ( handles );   
    end
    
    
end

savedeltaFstackStim1 ( handles );

    

% % --- Executes on button press in saveDeltaFOverlay.
% function saveDeltaFOverlay_Callback(hObject, eventdata, handles)
% % hObject    handle to saveDeltaFOverlay (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%     
%     saveColorizeddeltaFstack( handles );



% --- Executes on button press in showColorized.
function showColorized_Callback(hObject, eventdata, handles)
% hObject    handle to showColorized (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = image_redraw(handles);
guidata(hObject, handles);


% Hint: get(hObject,'Value') returns toggle state of showColorized


% --- Executes on button press in importTotalROIButton.
function importTotalROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to importTotalROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));
handles.minThresh = str2num(get(handles.minAxis,'string'));
handles.maxThresh = str2num(get(handles.maxAxis,'string'));
[filename pathname]=uigetfile('.mat','Load Stim 1 Data');
fullfilename=fullfile(pathname,filename);

if handles.stimNum == 2
            [filename2 pathname2]=uigetfile(pathname,'Load Stim 2 Data');
            fullfilename2=fullfile(pathname2,filename2);
end
clear handles.totalROIdataSlice;
clear handles.totalROIdataSlice2;

load(fullfilename);

handles.totalROIdataSlice=totalROIdataSlice;

if handles.stimNum == 2
    load(fullfilename2);
    
    handles.totalROIdataSlice2=totalROIdataSlice2;
    
            
end

handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in exportTotalROI.
function exportTotalROI_Callback(hObject, eventdata, handles)
% hObject    handle to exportTotalROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
totalROIdataSlice=handles.totalROIdataSlice;
if handles.stimNum == 2
    totalROIdataSlice2=handles.totalROIdataSlice2;
end
basefoldername=handles.foldername(1:end-5);
foregroundthresh= get(handles.dfofFgThreshSlider, 'Value');
backgroundthresh= get(handles.dfofBgThreshSlider, 'Value');
minforActive=str2num(get(handles.minAxis,'string'));
maxforActive=str2num(get(handles.maxAxis,'string'));
stdDevforActive=str2num(get(handles.stDevmultiplier,'string'));
f0min=str2double(get(handles.dfofMinTEdit, 'String'));
f0max=str2double(get(handles.dfofMaxTEdit, 'String'));

ROIfoldername=strcat(basefoldername,'ROI_Data/');

if ~exist(ROIfoldername, 'dir')
  mkdir(ROIfoldername);
end

%mkdir(ROIfoldername);
ROIfilename=strcat(ROIfoldername,'totalROIdataGreen.mat');
save(ROIfilename,'totalROIdataSlice');
if handles.stimNum == 2
    ROIfilename2=strcat(ROIfoldername,'totalROIdataBlue.mat');
    save(ROIfilename2,'totalROIdataSlice2');
end

ROIDatafilename=strcat(ROIfoldername,'ROI_info.mat');
save(ROIDatafilename,'foregroundthresh','minforActive','maxforActive','stdDevforActive','f0min','f0max');


% --- Executes on button press in singleDeltaFbutton.
function singleDeltaFbutton_Callback(hObject, eventdata, handles)
% hObject    handle to singleDeltaFbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.stimNum == 2
     
    if get(handles.traG,'Value') == get(handles.traG,'Max') && get(handles.traB,'Value') == get(handles.traB,'Max')    
        if get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max')
            savedeltaFstackBlueSingle( handles );
        else
            savedeltaFstackBlueSinglenomask( handles );
        end
    elseif get(handles.traG,'Value') == get(handles.traG,'Max') && get(handles.traB,'Value') == get(handles.traB,'Min')
        if get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max')
            savedeltaFstackgraysingleStim1mask ( handles );
        else
            savedeltaFstackgraysingleStim1 ( handles );
        end
        
    elseif get(handles.traG,'Value') == get(handles.traG,'Min') && get(handles.traB,'Value') == get(handles.traB,'Max')
        
        if get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max')
            savedeltaFstackgraysingleStim2mask ( handles );
        else
            savedeltaFstackgraysingleStim2 ( handles );
        end   
    
    
    end
    
else    
    if get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max')
            savedeltaFstackgraysingleStim1mask ( handles );
    else
            savedeltaFstackgraysingleStim1 ( handles );
    end
    
    
end


% --- Executes on button press in saveSingleBackground.
function saveSingleBackground_Callback(hObject, eventdata, handles)
% hObject    handle to saveSingleBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveBackgroundsingle ( handles );


% --- Executes on button press in snapshot.
function snapshot_Callback(hObject, eventdata, handles)
% hObject    handle to snapshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

F=getframe(handles.imAxes);
[file,path] = uiputfile(fullfile(handles.foldername,'*.tiff'),'Save Snapshot As');
FileName=fullfile(path,file);
options.color=true;
saveastiff(F.cdata,FileName,options);
guidata(hObject, handles);


% --- Executes on button press in import_Markers.
function import_Markers_Callback(hObject, eventdata, handles)
% hObject    handle to import_Markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));
[T Z] = getTZ(handles);
[minZ maxZ] = getZLim(handles);
old_Z = Z;
[filename, pathname] = uigetfile('.marker','Please select marker file');
fullmarkerPath = fullfile(pathname,filename);
temp_marker=loadMarkers(fullmarkerPath);
handles.markerLocations=temp_marker;    
%handles = calculateMarkerdfof(handles);
    roiNum = 1;
    slice = [];
    
    for i = 1:size(temp_marker,1)    
        roiCenter = [temp_marker(i,1) temp_marker(i,2)];
        roiRadius = 7;
        newROICenterX = temp_marker(i,1);
        newROICenterY = temp_marker(i,2);
        newROIRad = 7;
        slice = temp_marker(i,3);
        if i<size(temp_marker,1)
            nextslice = temp_marker(i+1,3);  
        end    
            
        handles.totalROIdataSlice{slice,1}{roiNum,1}=roiCenter(1);
        handles.totalROIdataSlice{slice,1}{roiNum,2}=roiCenter(2);
        handles.totalROIdataSlice{slice,1}{roiNum,3}=roiRadius;
        roiNum=size(handles.totalROIdataSlice{nextslice,1},1)+1;
    end
    
    if handles.stimNum == 2
        handles.totalROIdataSlice2 = handles.totalROIdataSlice;
    end
    
for i = minZ : maxZ
    set(handles.currZText, 'String', num2str(i));
    if isempty(handles.totalROIdataSlice{i,1})
        if handles.stimNum == 2
             handles = updDataAx2Stim( handles );
        else
             handles = updDataAx1Stim ( handles );
        end
    end
end
    
    
    %assignin('base','handles',handles);
    %handles = updateroitable( handles );
   
    %handles = drawroicallback(handles);
    set(handles.showActiveROIs,'Value',0);
    set(handles.showROIbut,'Value',1);
    set(handles.currZText, 'String', num2str(old_Z));
    if handles.stimNum == 2
         handles = updDataAx2Stim( handles );
    else
         handles = updDataAx1Stim ( handles );
    end
    handles = image_redraw(handles);
    guidata(hObject, handles);


% --- Executes on button press in bulkDetection.
function bulkDetection_Callback(hObject, eventdata, handles)
% hObject    handle to bulkDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = detectResponders(handles);   
handles = BulkDetection(handles);
if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
else
            handles = updDataAx1Stim ( handles );
end
handles = image_redraw(handles);

guidata(hObject, handles);
    
    
 


% --- Executes on button press in clearROIdata.
function clearROIdata_Callback(hObject, eventdata, handles)
% hObject    handle to clearROIdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[T Z] = getTZ(handles);
%handles=rmfield(handles,'totalROIdataSlice');
handles.totalROIdataSlice(Z,:)={[]};
handles.totalROIdataSlice2(Z,:)={[]};
handles.colors{Z}=[1;0;0];
handles = image_redraw(handles);
%Z = size(handles.imgdata,4);
%handles.totalROIdataSlice = cell(Z,6);
guidata(hObject, handles);



function numROISlice_Callback(hObject, eventdata, handles)
% hObject    handle to numROISlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numROISlice as text
%        str2double(get(hObject,'String')) returns contents of numROISlice as a double


% --- Executes during object creation, after setting all properties.
function numROISlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numROISlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numROItotal_Callback(hObject, eventdata, handles)
% hObject    handle to numROItotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numROItotal as text
%        str2double(get(hObject,'String')) returns contents of numROItotal as a double


% --- Executes during object creation, after setting all properties.
function numROItotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numROItotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function dfofBgThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to dfofBgThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function dfofBgThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dfofBgThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in exportActive.
function exportActive_Callback(hObject, eventdata, handles)
% hObject    handle to exportActive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.minThresh = str2num(get(handles.minAxis,'string'));
handles.maxThresh = str2num(get(handles.maxAxis,'string'));
handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));
handles = exportActiveDH(handles);
guidata(hObject, handles);
% --- Executes on button press in exportOthers.
function exportOthers_Callback(hObject, eventdata, handles)
% hObject    handle to exportOthers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = exportOthersDH(handles);
guidata(hObject, handles);

% --- Executes on button press in exportBoth.
function exportBoth_Callback(hObject, eventdata, handles)
% hObject    handle to exportBoth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = exportBothDH(handles);
guidata(hObject, handles);


% --- Executes on button press in remROIs.
function remROIs_Callback(hObject, eventdata, handles)
% hObject    handle to remROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles = RemoveROIsblue(handles);
[T Z] = getTZ(handles);
if ~isempty(handles.totalROIdataSlice{Z,1});

    if (get(handles.updData,'Value') == get(handles.updData,'Max'))
        if handles.stimNum == 2
            handles = updDataAx2Stim( handles );
        else
            handles = updDataAx1Stim ( handles );
        end
    end
end
handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in bluechannel.
function bluechannel_Callback(hObject, eventdata, handles)
% hObject    handle to bluechannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles = image_redraw(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of bluechannel


% --- Executes on button press in upBlue.
function upBlue_Callback(hObject, eventdata, handles)
% hObject    handle to upBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.traR,'Value')== get(handles.traR,'Max'))
    handles = shiftAlignup(handles);
end
if (get(handles.traB,'Value')== get(handles.traB,'Max'))
    handles = shiftBlueup(handles);
end
guidata(hObject, handles);

% --- Executes on button press in downBlue.
function downBlue_Callback(hObject, eventdata, handles)
% hObject    handle to downBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.traR,'Value')== get(handles.traR,'Max'))
    handles = shiftAligndown(handles);
end
if (get(handles.traB,'Value')==get(handles.traB,'Max'))
    handles = shiftBluedown(handles);
end
guidata(hObject, handles);


% --- Executes on button press in align.
function align_Callback(hObject, eventdata, handles)
% hObject    handle to align (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.alignStack,'Value')== get(handles.alignStack,'Max'))
    handles = alignBluetoGreenparallelstack(handles); 
else
    handles = alignBluetoGreenparallel(handles);   
end

handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in greenVsBlue.
function greenVsBlue_Callback(hObject, eventdata, handles)
% hObject    handle to greenVsBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = updDataAx2Stim( handles );
handles = plotGreenVsBlue(handles);
guidata(hObject, handles);


% --- Executes on button press in exportAligned.
function exportAligned_Callback(hObject, eventdata, handles)
% hObject    handle to exportAligned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles= exportAlignedBlue(handles);
guidata(hObject, handles);


% --- Executes on button press in transformImage.
function transformImage_Callback(hObject, eventdata, handles)
% hObject    handle to transformImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

if (get(handles.traG,'Value')== get(handles.traG,'Max'))
    if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min'))
        yTrans = str2double(get(handles.translateX, 'String'));
        xTrans = str2double(get(handles.translateY, 'String'));
    
        handles = simpleTranslateGreen(handles,xTrans,yTrans);
    else
        yTrans = str2double(get(handles.translateX, 'String'));
        xTrans = str2double(get(handles.translateY, 'String'));
        
        handles = translateGreenAllTimepoints(handles,xTrans,yTrans);
    end
    
end
if (get(handles.traB,'Value')== get(handles.traB,'Max'))  
     if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min'))
        yTrans = str2double(get(handles.translateX, 'String'));
        xTrans = str2double(get(handles.translateY, 'String'));
    
        handles = simpleTranslateBlue(handles,xTrans,yTrans);
     else
        yTrans = str2double(get(handles.translateX, 'String'));
        xTrans = str2double(get(handles.translateY, 'String'));
        
        handles = translateBlueAllTimepoints(handles,xTrans,yTrans);
     end
end
        
    

handles = image_redraw(handles);
guidata(hObject, handles);




function translateX_Callback(hObject, eventdata, handles)
% hObject    handle to translateX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% Hints: get(hObject,'String') returns contents of translateX as text
%        str2double(get(hObject,'String')) returns contents of translateX as a double


% --- Executes during object creation, after setting all properties.
function translateX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translateX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function translateY_Callback(hObject, eventdata, handles)
% hObject    handle to translateY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translateY as text
%        str2double(get(hObject,'String')) returns contents of translateY as a double


% --- Executes during object creation, after setting all properties.
function translateY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translateY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function translateBlueX_Callback(hObject, eventdata, handles)
% hObject    handle to translateBlueX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translateBlueX as text
%        str2double(get(hObject,'String')) returns contents of translateBlueX as a double


% --- Executes during object creation, after setting all properties.
function translateBlueX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translateBlueX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate as text
%        str2double(get(hObject,'String')) returns contents of rotate as a double


% --- Executes during object creation, after setting all properties.
function rotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in traG.
function traG_Callback(hObject, eventdata, handles)
% hObject    handle to traG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of traG


% --- Executes on button press in traB.
function traB_Callback(hObject, eventdata, handles)
% hObject    handle to traB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of traB


% --- Executes on button press in rotateImage.
function rotateImage_Callback(hObject, eventdata, handles)
% hObject    handle to rotateImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

if (get(handles.traG,'Value')== get(handles.traG,'Max'))
    if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min'))
        rot = str2double(get(handles.rotate, 'String'));
        handles = simpleRotateGreen(handles,rot);
    else
        rot = str2double(get(handles.rotate, 'String'));
        handles = rotateAllTimepointsGreen(handles,rot);
    end
    
end
if (get(handles.traB,'Value')== get(handles.traB,'Max'))  
    if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min')) 
        rot = str2double(get(handles.rotate, 'String'));
        handles = simpleRotateBlue(handles,rot);
    else
        rot = str2double(get(handles.rotate, 'String'));
        handles = rotateAllTimepointsBlue(handles,rot);
        
    end
end
        
    

handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in alignStack.
function alignStack_Callback(hObject, eventdata, handles)
% hObject    handle to alignStack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alignStack


% --- Executes on button press in traR.
function traR_Callback(hObject, eventdata, handles)
% hObject    handle to traR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.traG, 'Value', 0);
set(handles.traB, 'Value', 0);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of traR


% --- Executes on button press in nucButton.
function nucButton_Callback(hObject, eventdata, handles)
% hObject    handle to nucButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles = image_redraw(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of nucButton


% % --- Executes on slider movement.
% function respondToContSlideCallback(hObject, eventdata, handles)
% % hObject    handle to slider1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% 
% % Hints: get(hObject,'Value') returns position of slider
% %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% 
% % first we need the handles structure which we can get from hObject
% 
% handles = slidercallbackdrawimageslicergblue(handles);
% % test to display the current value along the slider
% guidata(hObject, handles);


% --- Executes on button press in updData.
function updData_Callback(hObject, eventdata, handles)
% hObject    handle to updData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of updData


% --- Executes on button press in saveROIasCSV.
function saveROIasCSV_Callback(hObject, eventdata, handles)
% hObject    handle to saveROIasCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
foldername = handles.foldername;
totalROIdataSlice = handles.totalROIdataSlice;
pathname=sprintf('%s/ROIcsv',foldername);
[minT maxT] = getTLim(handles)
if ~exist(pathname,'dir')
   mkdir(foldername,'ROIcsv'); 
end
adder = 1;
for i = 1:size(totalROIdataSlice,1);
    z=i;   
    if get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max')
        for j = 1:size(totalROIdataSlice{i,1},1)
             if totalROIdataSlice{i,1}{j,5}==2 
                x = totalROIdataSlice{i,1}{j,1};
                y = totalROIdataSlice{i,1}{j,2};
                marker{adder,1}='stim 1';
                marker{adder,2}=x;
                marker{adder,3}=y;
                marker{adder,4}=z;
                %assignin('base','marker',marker);
                %assignin('base','totalROIdataSlice',totalROIdataSlice);
                marker(adder,5:maxT - minT + 5) = num2cell(totalROIdataSlice{i,1}{j,4}(:,1));
                adder = adder+1;
             end
                          
        end   
    else
         for j = 1:size(totalROIdataSlice{i,1},1)
               x = totalROIdataSlice{i,1}{j,1};
               y = totalROIdataSlice{i,1}{j,2};
               marker{adder,1}='stim 1';
               marker{adder,2}=x;
               marker{adder,3}=y;
               marker{adder,4}=z;
               %assignin('base','marker',marker);
               %assignin('base','totalROIdataSlice',totalROIdataSlice);
               marker(adder,5:maxT - minT + 5) = num2cell(totalROIdataSlice{i,1}{j,4}(:,1));
               adder = adder+1;   
         end
     end
end
if handles.stimNum == 2
    for i = 1:size(totalROIdataSlice2,1);
    z=i;
        for j = 1:size(totalROIdataSlice2{i,1},1)
            if totalROIdataSlice2{i,1}{j,5}==2
                x = totalROIdataSlice2{i,1}{j,1};
                y = totalROIdataSlice2{i,1}{j,2};
                marker{adder,1}='stim 2';
                marker{adder,2}=x;
                marker{adder,3}=y;
                marker{adder,4}=z;
                marker(adder,5:maxT - minT + 5) = num2cell(totalROIdataSlice2{i,1}{j,4}(:,1));
                adder = adder+1;
            end
        end

    end
end

fullpathname=sprintf('%s/ROIcsv/ActiveROIs.csv',foldername);
cell2csv(fullpathname,marker);

% --- Executes during object creation, after setting all properties.
function maxTText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in clickToMove.
function clickToMove_Callback(hObject, eventdata, handles)
% hObject    handle to clickToMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis

if (get(handles.traG,'Value')== get(handles.traG,'Max'))
    if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min'))
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        zoom off; % to escape the zoom mode
        for i = 1:2
            [xi,yi,but] = ginput(1);
            hold on
            scatter(xi,yi,4,'blue','filled');
            pts(i,1) = xi;
            pts(i,2) = yi;
        end
        zoom out; % go to the original size of your image
        xTrans = pts(2,2)-pts(1,2);
        yTrans = pts(2,1)-pts(1,1);
        handles = simpleTranslateGreen(handles,xTrans,yTrans);
    else
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        zoom off; % to escape the zoom mode
        for i = 1:2
            [xi,yi,but] = ginput(1);
            hold on
            scatter(xi,yi,4,'blue','filled');
            pts(i,1) = xi;
            pts(i,2) = yi;
        end
        zoom out; % go to the original size of your image
        xTrans = pts(2,2)-pts(1,2);
        yTrans = pts(2,1)-pts(1,1);
        
        handles = translateGreenAllTimepoints(handles,xTrans,yTrans);
    end
    
end
if (get(handles.traB,'Value')== get(handles.traB,'Max'))  
     if (get(handles.alignStack,'Value')== get(handles.alignStack,'Min'))
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        zoom off; % to escape the zoom mode
        for i = 1:2
            [xi,yi,but] = ginput(1);
            hold on
            scatter(xi,yi,4,'blue','filled');
            pts(i,1) = xi;
            pts(i,2) = yi;
        end
        zoom out; % go to the original size of your image
        xTrans = pts(2,2)-pts(1,2);
        yTrans = pts(2,1)-pts(1,1);
    
        handles = simpleTranslateBlue(handles,xTrans,yTrans);
     else
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        zoom off; % to escape the zoom mode
        for i = 1:2
            [xi,yi,but] = ginput(1);
            hold on
            scatter(xi,yi,4,'blue','filled');
            pts(i,1) = xi;
            pts(i,2) = yi;
        end
        zoom out; % go to the original size of your image
        xTrans = pts(2,2)-pts(1,2);
        yTrans = pts(2,1)-pts(1,1);
        
        handles = translateBlueAllTimepoints(handles,xTrans,yTrans);
     end
end
handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in loadROIasCSV.
function loadROIasCSV_Callback(hObject, eventdata, handles)
% hObject    handle to loadROIasCSV (see GCBO)
handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));
[T Z] = getTZ(handles);
[minZ maxZ] = getZLim(handles);
old_Z = Z;
[filename, pathname] = uigetfile('.csv','Please select .csv file');
fullmarkerPath = fullfile(pathname,filename);
temp_marker=loadcsv(fullmarkerPath);
handles.markerLocations=temp_marker;    
%handles = calculateMarkerdfof(handles);
% assignin('base','temp_marker',temp_marker);
    roiNum = 1;
    slice = [];
    
    for i = 1:size(temp_marker,1)    
        roiCenter = [temp_marker(i,1) temp_marker(i,2)];
        roiRadius = 7;
        newROICenterX = temp_marker(i,1);
        newROICenterY = temp_marker(i,2);
        newROIRad = 7;
        slice = temp_marker(i,3);
        if i<size(temp_marker,1)
            nextslice = temp_marker(i+1,3);  
        end    
%         assignin('base','slice',slice);
%         assignin('base','nextslice',nextslice);
        handles.totalROIdataSlice{slice,1}{roiNum,1}=roiCenter(1);
        handles.totalROIdataSlice{slice,1}{roiNum,2}=roiCenter(2);
        handles.totalROIdataSlice{slice,1}{roiNum,3}=roiRadius;
        roiNum=size(handles.totalROIdataSlice{nextslice,1},1)+1;
    end
    if handles.stimNum == 2
        handles.totalROIdataSlice2 = handles.totalROIdataSlice;
    end
    
    
for i = minZ : maxZ
    set(handles.currZText, 'String', num2str(i));
    if isempty(handles.totalROIdataSlice{i,1})
        if handles.stimNum == 2
             handles = updDataAx2Stim( handles );
        else
             handles = updDataAx1Stim ( handles );
        end
    end
end
    
    
    %assignin('base','handles',handles);
    %handles = updateroitable( handles );
   
    %handles = drawroicallback(handles);
    set(handles.showActiveROIs,'Value',0);
    set(handles.showROIbut,'Value',1);
    set(handles.currZText, 'String', num2str(old_Z));
    if handles.stimNum == 2
         handles = updDataAx2Stim( handles );
    else
         handles = updDataAx1Stim ( handles );
    end
    handles = image_redraw(handles);
    guidata(hObject, handles);

   

% --- Executes on button press in col_Matched.
function col_Matched_Callback(hObject, eventdata, handles)
% hObject    handle to col_Matched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
set(handles.col_Active, 'Value',0);
handles = image_redraw(handles);
guidata(hObject, handles);


% --- Executes on button press in col_Active.
function col_Active_Callback(hObject, eventdata, handles)
% hObject    handle to col_Active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
set(handles.col_Matched, 'Value',0);
handles = image_redraw(handles);
guidata(hObject, handles);
