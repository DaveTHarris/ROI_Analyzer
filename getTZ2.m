function [T Z T2 Z2] = getTZ2( handles )
%GETTZ Get current T and Z values from gui
T = str2double(get(handles.currTText, 'String'));
Z = str2double(get(handles.currZText, 'String'));
T2= str2double(get(handles.currTText2, 'String'));
Z2 = str2double(get(handles.currZText2, 'String'));

end

