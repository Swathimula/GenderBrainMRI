% This will extract the characteristic axial section (of brain), which has
% lateral ventricles
% Author: Swathi M. Mula
% Date Created:   April 4, 2018
% Last Modififed: May 14, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; clc
format long
current_folder = pwd;

% Folder to import the 3D MAT files of T1 weighted MRI
import_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/Volume';

% Folder to export the characteristic 2D brain slice 
save_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/Crosssection/unmasked';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for subject = 1:100;
    
    % Loading the T1 weighted MRI of each subject
    try
        cd(import_folder)
        T1Mat = load(strcat('T1array',num2str(subject,'%03d'),'.mat'));
        T1 = T1Mat.T1array;

    catch
        continue;
    end
    
    % Applying median filter to the 3D image to filter noise 
    for i = 1:size(T1,1)
        TM1(i,:,:) = medfilt2(squeeze(T1(i,:,:)),[8 8]);
    end

     
    y = 1:size(TM1,1);
    x = 1:size(TM1,2);
    z = 1:size(TM1,3);

    % Spatial coordinates/dimensions of the 3D image
    [X,Y,Z] = meshgrid(x,y,z);

    % The coronal plane where the lateral ventricles are located
    index_x = size(TM1,2);
    
    % Searching the lateral ventricles 
    if(size(TM1,1) == 176 || size(TM1,1) == 160)
    
        %Index screening in the coronal plane
        ix11 = 80;   ix12 = 115;
        ix21 = 75;   ix22 = 115;
    
        %Color screening in the coronal plane
        c_x1 = 20; c_x2 = 50; 
    
        %Index screening in the axial plane
        iy11 = 85;   iy12 = 170;
        iy21 = 50;   iy22 = 120;
    
        %Color screening in the axial plane
        c_y1 = 20; c_y2 = 40; 
        
        %Color screens for subjectID > 84 that different intensity rages
        if(subject > 84)
            
            %Color screening in the coronal plane
            c_x1 = 75; c_x2 = 110; 
            
            %Color screening in the axial plane
            c_y1 = 75; c_y2 = 100;      
        end
        
        %Extracting the lateral ventricles in the coronal plane
        section_x = squeeze(TM1(:,index_x/2,:));
        color_section_x = roicolor(section_x,c_x1,c_x2);
        
        %Visualizing the above extracted coronal plane
        %figure; subplot(1,2,1); imagesc(section_x); axis equal; hold on;
        %subplot(1,2,2); imagesc(color_section_x); axis equal; hold on;   
    
        %Extracting the mean location/index of lateral ventricles in the coronal plane
        Y_sub = squeeze(Y(ix11:ix12,index_x/2,ix21:ix22));
        Y_sub = reshape(Y_sub,[size(Y_sub,1)*size(Y_sub,2) 1]);    
        color_section_x2 = reshape(color_section_x(ix11:ix12,ix21:ix22), [size(Y_sub,1)*size(Y_sub,2) 1]);
        index = find(color_section_x2 == 1);
        
        %Mean location of the lateral ventricles in Y coordinate
        index_y = round(mean(Y_sub(index)));
    
        %Searching the axial section that best captures the ventricles 
        count = 0;                
        for j = index_y-5:index_y+5           
            count = count+1;           
            section_y = squeeze(TM1(j,:,:));        
            color_section_y = medfilt2(roicolor(section_y,c_y1,c_y2),[8 8]);    
            color_section_y = color_section_y(iy11:iy12,iy21:iy22)        
            area_ventricle(count) = sum(sum(color_section_y)); 
        end
        
        %Extracting the axial section that best captures the ventricles
        index_y2 = find(area_ventricle == max(area_ventricle))-1+ index_y-5;
    
        %Visualizing the above extracted axial plane that best captures
        %ventricles
        %figure; imagesc(squeeze(TM1(index_y2,:,:))); axis equal;
        %title(strcat('Subject is ',num2str(subject)));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Exporting the characteristic axial brain section
        save_fname = strcat('CS',num2str(subject,'%03d'),'.mat');
        Section.index = index_y2; 
        Section.image = squeeze(TM1(index_y2,:,:));
        cd(save_folder)
        save(save_fname, '-struct', 'Section');
        
    end   
    
    clear TM1 area_ventricle Section
        
end

cd(current_folder)