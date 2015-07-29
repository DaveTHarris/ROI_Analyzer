function [ handles ] = plotGreenVsBlue( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

minThresh =str2double(get(handles.minAxis, 'String'));
maxThresh = str2double(get(handles.maxAxis, 'String'));
BitterStim=handles.totalROIdataSlice2;
 
SugarStim=handles.totalROIdataSlice;

assignin('base','handles',handles);
counter=0;
for i = 1:size(SugarStim,1)
    
    if ~isempty(SugarStim{i,1})
        A=SugarStim{i,1};
        AA=BitterStim{i,1};
        %B=A(1,1);
%         B=A(:,1:3);
%         B=cell2mat(B);
        
        assignin('base','i',i);
        Asub = cell2mat(A(:,5));
        Asub = Asub == 2;
        AAsub = cell2mat(AA(:,5));
        AAsub = AAsub == 2;
        assignin('base','Asub',Asub);
        assignin('base','AAsub',AAsub);
        if sum(Asub) > 0 || sum(AAsub) > 0
            A=A(Asub | AAsub,:);
            assignin('base','A',A);
            AA=AA(Asub | AAsub ,:);
            for j = 1:size(A,1)
               counter = counter + 1;
    %            assignin('base','handles',handles);
    %            assignin('base','i',i);
    %            assignin('base','j',j);
               %if size(A{j,4},2) == 3
                 
                  B=A{j,4};
                  BB=AA{j,4};
                  C=B(:,1);
                  CC=BB(:,1);
                  SugarData(:,counter)=C;
                  BitterData(:,counter)=CC;
               %else
    %                assignin('base','i',i);
    %                assignin('base','j',j);
    %                SugarData(:,counter)=A{j,4};
               %end
            end
        end
    end
    
      
    
end
%  counter =0;
%  for i = 1:size(BitterStim,1)
%     
%     if ~isempty(BitterStim{i,1})
%         A=BitterStim{i,1};
%         %B=A(1,1);
% %         B=A(:,1:3);
% %         B=cell2mat(B);
%         
%         
%         for j = 1:size(A,1)
%            counter = counter + 1;
% %            assignin('base','counter',counter);
% %            assignin('base','A',A);
% %            assignin('base','j',j);
% %            assignin('base','i',i);
%            if size(A{j,4},2) == 3
%               B=A{j,4};
%               C=B(:,1);
%               BitterData(:,counter)=C;
%            else
%               BitterData(:,counter)=A{j,4};
%            end
%            assignin('base','BitterData',BitterData);
%             
%         end
%     end
%            
%  end

 for i = 1:size(SugarData,2)
    dataforplot(i,1)=max(SugarData(minThresh:maxThresh,i));
    dataforplot(i,2)=max(BitterData(minThresh:maxThresh,i));
     
 end
 
 x=dataforplot(:,1);
 y=dataforplot(:,2);
 figHandle=figure;
 set(gcf,'color','white')
%  assignin('base','x',x);
%  assignin('base','y',y);
 scatter(x,y);
 ylabel('\Delta F/F Stim 2','FontWeight','bold','FontSize',12);
 xlabel('\Delta F/F Stim 1','FontWeight','bold','FontSize',12);
 set(gca, 'LineWidth',1);
 set(gca,'fontWeight','bold');
 set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
 xlim([-.05 1]);
 ylim([-.05 1]);
 %axis equal
 daspect([1,1,1]);
 labels = num2str((1:size(x,1))','%d'); 
 text(x(:,1), y(:,1), labels, 'horizontal','left', 'vertical','bottom');
 
 
%  [idx,C]=kmeans(dataforplot,7);
%  X=dataforplot;
%  figure;
% 
% plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
% hold on
% plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
% hold on
% plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)
% hold on
% plot(X(idx==4,1),X(idx==4,2),'m.','MarkerSize',12)
% hold on
% plot(X(idx==5,1),X(idx==5,2),'c.','MarkerSize',12)
% hold on
% plot(X(idx==6,1),X(idx==6,2),'k.','MarkerSize',12)
% hold on
% plot(X(idx==7,1),X(idx==7,2),'y.','MarkerSize',12)
% plot(C(:,1),C(:,2),'kx',...
%      'MarkerSize',15,'LineWidth',3)
% legend('Cluster 1','Cluster 2','Centroids',...
%        'Location','NW')
% title 'Cluster Assignments and Centroids'
% hold off
% axis equal;
 
end

