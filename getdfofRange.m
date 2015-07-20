function [dfofMin dfofMax ] = getdfofRange( handles )
dfofMin = str2double(get(handles.dfofMinTEdit,'String'));
dfofMax = str2double(get(handles.dfofMaxTEdit,'String'));

end

