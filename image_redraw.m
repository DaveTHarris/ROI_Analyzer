function handles = image_redraw( handles )
    [T Z] = getTZ(handles);
    axes(handles.imAxes);
    colorOrder = get(0,'defaultAxesColorOrder');
    handles.colorOrder = colorOrder;
    stimNum = handles.stimNum;
    cla; 
    hold on;
    if stimNum == 2
            %No DeltaF, just green channel
                if (get(handles.deltafRadio,'Value')== get(handles.deltafRadio,'Min'))
                    if (get(handles.greenchan,'Value') == get(handles.greenchan,'Max'))
                        image=handles.imgdata(:,:,T,Z);
                        image = im2double(image);
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        slidervalLowmult = min(min(image));
                        slidervalmult = max(max(image));
                        actuallow=slidervalLowmult*slidervalLow;
                        actualhigh=slidervalmult*sliderval;
                        adjimage = imadjust(image,[actuallow actualhigh], [0 1]);
                        out(:,:,2)=adjimage;
                        %out(:,:,2)=handles.imgdata(:,:,T,Z);
                    else
                        out(:,:,2)=zeros(512,512);
                    end
%                   This determines which Anatomy image is
%                   displayed. For whole brain imaging, the "nuc" image would be the
%                   nuclear image. For sparse lines, "nuc" button would be the
%                   actual neuronal anatomy image.
                    if (get(handles.redchannel,'Value') == get(handles.redchannel,'Max'))
                        if (get(handles.nucButton,'Value')==get(handles.nucButton,'Max'))
                            out(:,:,1)=im2double(handles.nuclearData(:,:,Z));
                        else
                            out(:,:,1)=im2double(handles.alignData(:,:,Z));
                        end
                    else
                        out(:,:,1)=uint16(zeros(512,512));
                        out(:,:,1)=zeros(512,512);
                    end
                    if (get(handles.bluechannel,'Value') == get(handles.bluechannel,'Max'))
                        image2 = handles.imgdata2(:,:,T,Z);
                        image2 = im2double(image2);
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        slidervalLowmult = min(min(image2));
                        slidervalmult = max(max(image2));
                        actuallow=slidervalLowmult*slidervalLow;
                        actualhigh=slidervalmult*sliderval;
                        if actuallow ~= actualhigh
                            adjimage2 = imadjust(image2,[actuallow actualhigh], [0 1]);
                            out(:,:,3)=adjimage2;
                        else
                            out(:,:,3)=image2;
                        end
                    else
                        out(:,:,3)=uint16(zeros(512,512));
                    end
                else
                    if (get(handles.greenchan,'Value')==get(handles.greenchan,'Max'))
                        image=handles.deltaFimagedata(:,:,T,Z);
                        dfofimage=handles.deltaFoFimagedata(:,:,T,Z);
                        %This statement should directly change the lower cutoff
                        %value for the dfofimage. This should be adjustable by
                        %the user. The slidervalLow variable does the same
                        %thing in a modifiable way.
                        image(dfofimage<.02)=0;
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        adjimage = imadjust(image,[slidervalLow sliderval], [0 1]);
                        adjimage = fijiGaussian(adjimage,1);    
                        out(:,:,2)=adjimage;
                    else
                        out(:,:,2)=uint16(zeros(512,512));
                    end
                    if (get(handles.redchannel,'Value') == get(handles.redchannel,'Max'))
                        if (get(handles.nucButton,'Value')==get(handles.nucButton,'Max'))
                            out(:,:,1)=handles.nuclearData(:,:,Z);
                        else
                            out(:,:,1)=handles.alignData(:,:,Z);
                        end
                    else
                        out(:,:,1)=uint16(zeros(512,512));
                    end
                    if (get(handles.bluechannel,'Value')==get(handles.bluechannel,'Max'))
                        image2=handles.deltaFimagedata2(:,:,T,Z);
                        dfofimage2=handles.deltaFoFimagedata2(:,:,T,Z);
                        image2(dfofimage2<.02)=0;
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        adjimage2 = imadjust(image2,[slidervalLow sliderval], [0 1]);
                        adjimage2 = fijiGaussian(adjimage2,1);    
                        out(:,:,3)=adjimage2;
                    else
                        out(:,:,3)=uint16(zeros(512,512));
                    end
                        assignin('base','out',out);

                end
            
            imagesc(out, 'Parent', handles.imAxes);

            hold on;
        
            if (get(handles.showROIbut,'Value') == get(handles.showROIbut,'Max'))

               if ~isempty(handles.totalROIdataSlice{Z,1}) 
                counter=0;
                for j=1:Z-1
                   if ~isempty(handles.totalROIdataSlice{j,1})
                       A=size(handles.totalROIdataSlice{j,1},1);
                       counter=counter+A;
                   end    
                end
                
                centerX=cell2mat(handles.totalROIdataSlice{Z,1}(:,1));
                centerY=cell2mat(handles.totalROIdataSlice{Z,1}(:,2));
                radius=cell2mat(handles.totalROIdataSlice{Z,1}(:,3));
                viscircles([centerX centerY],radius, 'EdgeColor', 'w','LineWidth',.0005);
                if (get(handles.roiShowNumberCheck,'Value') == get(handles.roiShowNumberCheck,'Max'))
                      h=text(centerX, centerY ,sprintf('%d',[counter : counter + size(centerX)]),'Color','w','HorizontalAlignment','center');
                end
%                    for i=1:size(handles.totalROIdataSlice{Z,1},1)
%                         centerX=handles.totalROIdataSlice{Z,1}{i,1};
%                         centerY=handles.totalROIdataSlice{Z,1}{i,2};
%                         radius=handles.totalROIdataSlice{Z,1}{i,3};
%                         viscircles([centerX centerY],radius, 'EdgeColor', 'w','LineWidth',.0005);
%                         if (get(handles.roiShowNumberCheck,'Value') == get(handles.roiShowNumberCheck,'Max'))
%                             h=text(centerX, centerY ,sprintf('%d',i+counter),'Color','w','HorizontalAlignment','center');
%                         end
%                     end
               end
            hold off;
            end
            if (get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max'))
               if ~isempty(handles.totalROIdataSlice{Z,1}) 
                     
                centerX=cell2mat(handles.totalROIdataSlice{Z,1}(:,1));
                centerY=cell2mat(handles.totalROIdataSlice{Z,1}(:,2));
                radius=cell2mat(handles.totalROIdataSlice{Z,1}(:,3));
                disp=cell2mat(handles.totalROIdataSlice{Z,1}(:,5));                        


                centerXb=cell2mat(handles.totalROIdataSlice2{Z,1}(:,1));
                centerYb=cell2mat(handles.totalROIdataSlice2{Z,1}(:,2));
                radiusb=cell2mat(handles.totalROIdataSlice2{Z,1}(:,3));
                dispb=cell2mat(handles.totalROIdataSlice2{Z,1}(:,5));


                assignin('base','centerX',centerX);
                assignin('base','centerY',centerY);
                assignin('base','disp',disp);
                assignin('base','dispb',dispb);
                
                 
                viscircles([centerX(disp==2 & dispb==2) centerY(disp==2 & dispb==2)],radius(disp==2 & dispb==2), 'EdgeColor', 'y','LineWidth',.005);
                viscircles([centerX(disp==2 & dispb~=2) centerY(disp==2 & dispb~=2)],radius(disp==2 & dispb~=2), 'EdgeColor', 'g','LineWidth',.005);
                viscircles([centerX(disp~=2 & dispb==2) centerY(disp~=2 & dispb==2)],radius(disp~=2 & dispb==2), 'EdgeColor', 'y','LineWidth',.005);
                    
               end
               hold off;
            %set(handles.imAxes, 'CData', out);
            end
            %assignin('base','handles',handles);
            set(handles.numROISlice, 'String', num2str(size(handles.totalROIdataSlice{Z,1},1)));
            maxZ=str2double(get(handles.maxZText, 'String'));
            %This section of code updates the ROI counter on the GUI. It
            %keeps a running total of all of the ROIs
            totalROIs = 0;
            for i = 1:maxZ
                tempROIs=size(handles.totalROIdataSlice{i,1},1);
                totalROIs=totalROIs + tempROIs;
            end
            set(handles.numROItotal, 'String', num2str(totalROIs));
            assignin('base','handles',handles);
    else
        
        %No DeltaF, just green channel
                if (get(handles.deltafRadio,'Value')== get(handles.deltafRadio,'Min'))
                    if (get(handles.greenchan,'Value') == get(handles.greenchan,'Max'))
                        image=handles.imgdata(:,:,T,Z);
                        image = im2double(image);
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        slidervalLowmult = min(min(image));
                        slidervalmult = max(max(image));
                        actuallow=slidervalLowmult*slidervalLow;
                        actualhigh=slidervalmult*sliderval;
                        adjimage = imadjust(image,[actuallow actualhigh], [0 1]);
                        out(:,:,2)=adjimage;
                        %out(:,:,2)=handles.imgdata(:,:,T,Z);
                    else
                        out(:,:,2)=zeros(512,512);
                    end
%                   This determines which Anatomy image is
%                   displayed. For whole brain imaging, the "nuc" image would be the
%                   nuclear image. For sparse lines, "nuc" button would be the
%                   actual neuronal anatomy image.
                    if (get(handles.redchannel,'Value') == get(handles.redchannel,'Max'))
                        if (get(handles.nucButton,'Value')==get(handles.nucButton,'Max'))
                            out(:,:,1)=im2double(handles.nuclearData(:,:,Z));
                        else
                            out(:,:,1)=im2double(handles.alignData(:,:,Z));
                        end
                    else
                        out(:,:,1)=uint16(zeros(512,512));
                        out(:,:,1)=zeros(512,512);
                    end
                        out(:,:,3)=uint16(zeros(512,512));
                else
                    if (get(handles.greenchan,'Value')==get(handles.greenchan,'Max'))
                        image=handles.deltaFimagedata(:,:,T,Z);
                        dfofimage=handles.deltaFoFimagedata(:,:,T,Z);
                        %This statement should directly change the lower cutoff
                        %value for the dfofimage. This should be adjustable by
                        %the user. The slidervalLow variable does the same
                        %thing in a modifiable way.
                        image(dfofimage<.02)=0;
                        sliderval = get(handles.dfofFgThreshSlider, 'Value');
                        slidervalLow = get(handles.dfofBgThreshSlider, 'Value');
                        adjimage = imadjust(image,[slidervalLow sliderval], [0 1]);
                        adjimage = fijiGaussian(adjimage,1);    
                        out(:,:,2)=adjimage;
                    else
                        out(:,:,2)=uint16(zeros(512,512));
                    end
                    if (get(handles.redchannel,'Value') == get(handles.redchannel,'Max'))
                        if (get(handles.nucButton,'Value')==get(handles.nucButton,'Max'))
                            out(:,:,1)=handles.nuclearData(:,:,Z);
                        else
                            out(:,:,1)=handles.alignData(:,:,Z);
                        end
                    else
                    out(:,:,1)=uint16(zeros(512,512));
                    end
                    out(:,:,3)=uint16(zeros(512,512));
                    assignin('base','out',out);
                end
                imagesc(out, 'Parent', handles.imAxes);
            hold on;
        %assignin('base','totesROIs',handles.totalROIdata);
            if (get(handles.showROIbut,'Value') == get(handles.showROIbut,'Max'))
                               
                if (get(handles.showActiveROIs,'Value') == get(handles.showActiveROIs,'Max'))
                   if ~isempty(handles.totalROIdataSlice{Z,1}) 
                            temp = handles.totalROIdataSlice;
                            tempb = cell2mat(temp{Z,1}(:,5))==2;
                            
                            assignin('base','temp',temp);
                            assignin('base','tempb',tempb);
                            centerX=cell2mat(temp{Z,1}(tempb,1));
                            centerY=cell2mat(temp{Z,1}(tempb,2));
                            radius=cell2mat(temp{Z,1}(tempb,3));
                            assignin('base','handles',handles);
                            disp=cell2mat(temp{Z,1}(tempb,5));                        
                            a=handles.colors{Z}';
%                             temp = handles.totalROIdataSlice;
%                             centerX=cell2mat(handles.totalROIdataSlice{Z,1}(:,1));
%                             centerY=cell2mat(handles.totalROIdataSlice{Z,1}(:,2));
%                             radius=cell2mat(handles.totalROIdataSlice{Z,1}(:,3));
%                             assignin('base','handles',handles);
%                             disp=cell2mat(handles.totalROIdataSlice{Z,1}(:,5));                        
%                             a=handles.colors{Z}';
                            assignin('base','a',a);
                            %assignin('base','b',b);
                            assignin('base','centerX',centerX)
                            assignin('base','centerY',centerY);
                            b = a(1:length(centerX),:);
                            
                            b = b + (1 - b).*.25;
                            
                            if (get(handles.col_Matched,'Value') == get(handles.col_Matched,'Max'))
                                scatter(centerX,centerY,pi*radius.^2,b,'LineWidth',2);
                            else
                                viscircles([centerX(disp==2) centerY(disp==2)],radius(disp==2), 'EdgeColor', 'g','LineWidth',.005); 
                            end
                   end
                   hold off;

            %set(handles.imAxes, 'CData', out);
                else
                
                    if ~isempty(handles.totalROIdataSlice{Z,1}) 
                        counter=0;
                        for j=1:Z-1
                            if ~isempty(handles.totalROIdataSlice{j,1})
                               A=size(handles.totalROIdataSlice{j,1},1);
                               counter=counter+A;
                            end    
                        end

                            centerX=cell2mat(handles.totalROIdataSlice{Z,1}(:,1));
                            centerY=cell2mat(handles.totalROIdataSlice{Z,1}(:,2));
                            radius=cell2mat(handles.totalROIdataSlice{Z,1}(:,3));

                            viscircles([centerX centerY],radius, 'EdgeColor', 'w','LineWidth',.0005);
                            if (get(handles.roiShowNumberCheck,'Value') == get(handles.roiShowNumberCheck,'Max'))
                                h=text(centerX, centerY ,sprintf('%d',[counter : counter + size(centerX)]),'Color','w','HorizontalAlignment','center');
                            end

                   end
            hold off;
            end
            
        %assignin('base','handles',handles);
        set(handles.numROISlice, 'String', num2str(size(handles.totalROIdataSlice{Z,1},1)));
        maxZ=str2double(get(handles.maxZText, 'String'));

        totalROIs = 0;
        for i = 1:maxZ
            tempROIs=size(handles.totalROIdataSlice{i,1},1);

            totalROIs=totalROIs + tempROIs;

        end
        set(handles.numROItotal, 'String', num2str(totalROIs));
        assignin('base','handles',handles);  
         
        
    end
end    
