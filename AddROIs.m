function handles = AddROIs( handles )
    [T Z] = getTZ(handles);
   
    axes(handles.imAxes);
    axis image;
    hold on;
A = handles.totalROIdataSlice{Z,1}; 

roiList=A(:,1:2);   
    % Initially, the list of points is empty.
x = [];
y = [];
n = 0;

% Loop, picking up the points.
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    scatter(xi,yi,4,'blue','filled');
    n = n+1;
    addROIs(n,1) = xi;
    addROIs(n,2) = yi;
    %assignin('base','addROIs',addROIs);
end
sze=size(handles.totalROIdataSlice{Z,1},1);
for i = 1:size(addROIs,1)
   handles.totalROIdataSlice{Z,1}{sze+i,1}=addROIs(i,1);
 
   handles.totalROIdataSlice{Z,1}{sze+i,2}=addROIs(i,2);
  
   handles.totalROIdataSlice{Z,1}{sze+i,3}=6;

end
   assignin('base','handles',handles);