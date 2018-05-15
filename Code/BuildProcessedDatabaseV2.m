% This will determine the brain area (grey+white matter+ventricles
% Author: Swathi M. Mula
% Date Created:   May 12, 2018
% Last Modififed: May 14, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format long
clear all; clc

current_folder = pwd;

% Folder to import the masked axial brain slices
import_folder = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Training/MFiles/Crosssection/masked';

% Folder to import the excel file of MRI subjects (age, gender info)
import_excel = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/NormalDatabase.xlsx';

% Folder to export the data structure to store the calculated brain area
export_excel = '/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Results/ProcessedDatabase3.csv';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loading the subject information (Subject ID, age, gender)
[subject_num,txt,raw] = xlsread(import_excel);
T1_YN = char(txt(2:end,5));
index = find(char(T1_YN) == 'Y');

%Subject ID
subject_ID = subject_num(index,1);
subject_ID = subject_ID(2:end);

%Subject Gender
subject_gender = char(txt(2:end,3)); 
subject_gender = subject_gender(index,1);
subject_gender = subject_gender(2:end);

%Subject Age
subject_age = subject_num(index,2);
subject_age = subject_age(2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Determing the brain area in the characteristic slice
count = 0;
for subject = 1:length(T1_YN);
    count = count+1;
    
    % Loading the masked axial brain slices for each subject
    try
        
        cd(import_folder)
        section = load(strcat('CS',num2str(subject,'%03d'),'.mat')); 
        masked_image(count,:,:) = section.masked_image;        

    catch
        
        count = count-1;
        disp(strcat('Subject not found is', num2str(subject)));
        
        continue;
        
    end
   
end

cd(current_folder)

%Determining the maximum color intensity of each subject
for i = 1:count
    max_I2(i) = max(max(squeeze(masked_image(i,:,:))));    
end

x = 1:size(masked_image,2);
z = 1:size(masked_image,3);

% Spatial coordinates/dimensions of the 2D slice
[X,Z] = meshgrid(z,x);

%Searching for the grey and white matter and the brain area
for s = 1:count;

    %Color screen for the white matter
    col_m2 = max_I2(s)*0.76;

    %Color screen for the grey matter
    col_m1 = max_I2(s)*0.76*0.80;

    %Extracting the grey matter
    grey_matter = roicolor(squeeze(masked_image(s,:,:)),col_m1,col_m2);
    
    %Area of the grey matter
    G_area(s) = length(find(grey_matter == 1));

    %Extracting the white matter
    white_matter = roicolor(squeeze(masked_image(s,:,:)),0,col_m2);
    W_area(s) = length(find(white_matter == 0));

    %Area of the grey + white matter
    GW_area(s) = G_area(s)+ W_area(s);

    %Reshaping the X and Z dimensions
    xtemp = reshape(X,[size(X,1)*size(X,2),1]);
    ztemp = reshape(Z,[size(Z,1)*size(Z,2),1]);
    
    %Finding indices of grey_matter and white_matter locations
    tindex = find(grey_matter+1-white_matter ~= 0); 

    %Finding an ellipse to the brain that is seperated from scalp and
    %surrounding vault
    test(:,1) = xtemp(tindex);
    test(:,2) = ztemp(tindex);
    [exy] = ellipse(test,3.4);
    [z, a, b, alpha] = fitellipse(exy'); 
    
    %Brain Area
    T_area(s) = pi*a*b;

    clear test
end

%Female Subjects
findex = find(subject_gender == 'F');

%Male Subjects
mindex = find(subject_gender == 'M');

%Subject age in cell format
Age = num2cell(subject_age);

%Subject gender in cell format
Gender = num2cell(subject_gender);

%Brain area in cell format
BrainArea = reshape(num2cell(T_area), [length(T_area) 1]);

%Table of Age, Gender and BrainArea columns
T = table(Age, Gender, BrainArea);
T.Properties.Description = 'Subject data including age, gender, BrainArea';

%Exporting the table to a csv file
writetable(T,export_excel); 


