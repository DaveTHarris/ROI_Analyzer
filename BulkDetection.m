function [ handles ] = BulkDetection( handles  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    handles.xLimits = get(gca,'XLim');  %# Get the range of the x axis
    handles.yLimits = get(gca,'YLim');  %# Get the range of the y axis
    handles.stdDevmultiplier=str2num(get(handles.stDevmultiplier,'string'));
    [T Z] = getTZ(handles);
    [minZ maxZ] = getZLim(handles);    
   
    totalROIdataSlice=handles.totalROIdataSlice;
    totalROIdataSlice2=handles.totalROIdataSlice2;
    for i = 1:size(totalROIdataSlice,1)
     set(handles.currZText, 'String', num2str(i));
     
     
     
     handles = nucleiDetectionSliceDHblue(handles);
     handles = updatedataaxisDHBlue(handles);
     
    
    
    end

end




