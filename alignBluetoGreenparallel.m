function [ handles ] = alignBluetoGreenparallel( handles )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [~, Z] = getTZ(handles);
    axes(handles.imAxes);

    image=handles.imgdata;
    if handles.stimNum == 2
        image2=handles.imgdata2;
    end
    alignData=handles.alignData;
    nuclearData=handles.nuclearData;
    %matlabpool('open',4);
    if (get(handles.traG,'Value')== get(handles.traG,'Max'))


    %    zslices=size(image,4);
            duration=size(image,3);
    %     newGreen=image;    
     %   imagestack1=squeeze(image(:,:,1,:));    
            alignedGreen=zeros(512,512,duration);

            optimizer = registration.optimizer.RegularStepGradientDescent;
            optimizer.MaximumIterations = 100;
            optimizer.MinimumStepLength = 1e-7;
            metric = registration.metric.MeanSquares(); 

            %tic
    %         [optimizer,metric] = imregconfig('monomodal');
            fixedimage=image(:,:,1,Z);
            parfor j=1:duration
            alignedGreen(:,:,j) = imregister(image(:,:,j,Z),fixedimage,'translation',optimizer,metric);

           % toc
            end


        image(:,:,:,Z)=alignedGreen;

        handles.imgdata=image;

    end


    if handles.stimNum == 2
        if (get(handles.traB,'Value')== get(handles.traB,'Max'))
            %zslices2=size(image2,4);
            duration2=size(image2,3);

            alignedBlue = zeros(512,512,duration2);


            optimizer = registration.optimizer.RegularStepGradientDescent;
            optimizer.MaximumIterations = 100;
            optimizer.MinimumStepLength = 1e-7;
            metric = registration.metric.MeanSquares(); 

            fixedImage=image(:,:,1,Z);   
            tic
            parfor j = 1:duration2
                alignedBlue(:,:,j) = imregister(image2(:,:,j,Z),fixedImage,'translation',optimizer,metric);
            end
            toc
            image2(:,:,:,Z)=alignedBlue;
            handles.imgdata2=image2;    

        end 
    end
    if (get(handles.traR,'Value')== get(handles.traR,'Max'))
         %zslices2=size(image2,4);


       % alignedRed = zeros(512,512,zslices2);


            optimizer = registration.optimizer.RegularStepGradientDescent;
            optimizer.MaximumIterations = 100;
            optimizer.MinimumStepLength = 5e-3;
            metric = registration.metric.MeanSquares(); 

            fixedImage=image(:,:,1,Z);   
        tic
            Rfixed = imref2d(size(alignData(:,:,Z)));
            tform = imregtform(alignData(:,:,Z),fixedImage,'rigid',optimizer,metric);
            alignedData = imwarp(alignData(:,:,Z),tform,'OutputView',Rfixed);
            alignednuclearData = imwarp(nuclearData(:,:,Z),tform,'OutputView',Rfixed);
            assignin('base','alignedData',alignedData);
            alignData(:,:,Z)=alignedData;
            nuclearData(:,:,Z)=alignednuclearData;
        toc


        handles.alignData=alignData;
        handles.nuclearData=nuclearData;    

    end 


end

