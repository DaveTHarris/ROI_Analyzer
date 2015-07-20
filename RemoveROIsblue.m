function handles = RemoveROIsblue( handles )
    [T Z] = getTZ(handles);
   
    axes(handles.imAxes);
    axis image;
    hold on;
A = handles.totalROIdataSlice{Z,1}; 
if handles.stimNum == 2
    B = handles.totalROIdataSlice2{Z,1};
end
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
    remROIs(n,1) = xi;
    remROIs(n,2) = yi;
    
end
for i = 1:size(remROIs)
    point1 = [round(remROIs(i,1)),round(remROIs(i,2))];
    assignin('base','point1',point1);
        for j = 1:size(roiList,1)
           point2 = [round(roiList{j,1}),round(roiList{j,2})];
           distance(j)=norm(point1-point2);
        end
        [m,I]=min(distance);
   inDex(i)=I;
end
   assignin('base','inDex',inDex);
   assignin('base','A',A); 
   A(inDex,:)=[]; 
%     Anew=A;
%     assignin('base','Anew',Anew);
  

handles.totalROIdataSlice{Z,1}=A;
if handles.stimNum == 2
    B(inDex,:)=[];
    handles.totalROIdataSlice2{Z,1}=B;
end