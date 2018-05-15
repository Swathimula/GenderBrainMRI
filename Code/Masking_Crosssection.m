% This will seperate/mask the characteristic axial brain slice predominantly
% from the scalp
% Author: Swathi M. Mula
% Date Created:   May 8, 2018
% Last Modififed: May 14, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format long
clear all; clc
format long
current_folder = pwd;

% Folder to import the unmasked axial brain slice
import_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/Crosssection/unmasked';

% Folder to export the masked axial brain slice
save_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/Crosssection/masked';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for subject = 1:100;
    
    % Loading the unmasked brain slice for each subject
    try
        cd(import_folder)
        unmasked = load(strcat('CS',num2str(subject,'%03d'),'.mat'));
        image = unmasked.image;

    catch
        continue;
        print(strcat('Subject',num2str(subject),'not found'));
    end

    cd(current_folder)

    %%Extracting the brain slice with scalp from the surrounding noise
    bn = 1 - medfilt2(roicolor(image,0,10));
    
    if(subject == 37)
        %%Extracting the brain slice with scalp from the surrounding noise
        %%for subjectID 37, which deviated for the above
        %%roicolor ranges
        bn = 1 - medfilt2(roicolor(image,0,25));
    end

    if(subject > 83)
        %%Extracting the brain slice with scalp from the surrounding noise
        %%for subjectID > 87, which had different intensity range
        bn = 1 - medfilt2(roicolor(image,0,40));
    end

    %Fitting an ellipse to the brain with scalp
    bn_temp = reshape(bn,[size(bn,1)*size(bn,2),1]);
    x = 1:size(bn,1);
    z = 1:size(bn,2);
    [X,Z] = meshgrid(z,x);
    xtemp = reshape(X,[size(X,1)*size(X,2),1]);
    ztemp = reshape(Z,[size(Z,1)*size(Z,2),1]);
    index = find(bn_temp ~= 0); 
    test(:,1) = xtemp(index);
    test(:,2) = ztemp(index);
    
    %The paramter k helps seperate brain from scalp
    k = 3.1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Subject exceptions for the above parameter of k
    if(subject == 18)
        k = 3.4;
    end
    
    if(subject == 85)
        k = 3.3;
    end
    
    if(subject == 34)
        k = 2.7;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Fitting an ellipse to brain slice to seperate from scalp based on k
    [exy] = ellipse(test,k);
    [z, a, b, alpha] = fitellipse(exy'); 

    %Visualize to see the brain fit by ellipse
    % figure; contourf(X,Z,image); axis equal
    % hold on; plot(exy(:,1), exy(:,2),'r*')
    % title(strcat('Subject = ', num2str(subject)));

    %%%%Region inside the ellipse
    ellipse_expr = (((X-z(1))*cos(alpha) + (Z-z(2))*sin(alpha))/a).^2 + (((X-z(1))*sin(alpha) - (Z-z(2))*cos(alpha))/b).^2;
    mask = uint16(ellipse_expr < 1);
    
    %%%Final masked image
    masked_image = mask.*image;

    %Exporting the masked image
    save_fname = strcat('CS',num2str(subject,'%03d'),'.mat');
    Section.masked_image = squeeze(masked_image);
    cd(save_folder);
    save(save_fname, '-struct', 'Section');
    
    %Visualize to see the brain seperated from scalp
    % figure; subplot(1,2,1); contourf(X,Z,image); axis equal;
    % hold on; subplot(1,2,2); contourf(X,Z,masked_image); axis equal;
    clear unmasked test Section
end