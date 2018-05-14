%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                            *   
% > Author: Mathias Silva da Rosa   
% > Purpose: Training of SVM Classifier     
% > Usage: Create de SVM.mat file for after test   
% > Notes: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

clear;
close all;
clc;

% INITIAL SETTINGS
%% Getting HOG methods
addpath(genpath('./HOG/'));
pathToTrainedSVMs = '../../Results/TrainedSVMs/';

%% Getting training files      			 
trainingDatasetPath = '../../../Dataset/Training/';
trainingFiles = dir(trainingDatasetPath);
filesIndex = find(vertcat(trainingFiles.isdir));
trainingClasses = trainingFiles(filesIndex);
trainingClasses = trainingClasses(3:end); % Removing '.' and '..' links 

%% Getting HOG descriptor size
imageSize = [64 128];
cellsSize = 8;
blocksSize = 16;
histogramBins = 9;
HOGFeatureSize = getHOGDescriptorSize(imageSize,cellsSize,blocksSize,histogramBins);

%% Getting descriptors and labels

for class = 1:size(trainingClasses,1)
    
    pathToImages= strcat(trainingDatasetPath,trainingClasses(class).name,'/Images/Union/*.ppm');
    images = dir(pathToImages);
    
    descriptorsData = zeros(size(images,1),HOGFeatureSize);
    descriptorsLabels = cell(size(images,1),1);  
    
    for image = 1:size(images,1)
        imagePath = strcat(trainingDatasetPath,trainingClasses(class).name,'/Images/Union/',images(image).name);
        imageVector = imread(imagePath);                          
        imageResized = imresize(imageVector,imageSize);               
        grayImage = rgb2gray(imageResized);                                                    
        featureVector = getHOGDescriptor(grayImage,[cellsSize cellsSize], histogramBins, 0); 
        descriptorsData(image,:) = featureVector;                 
        descriptorsLabels(image) = cellstr(images(image).name(end-4));
    end
    
    SVMModel = fitcsvm(descriptorsData,descriptorsLabels);
    
    name = strcat('SVM_',trainingClasses(class).name,'.mat');
    mkdir(strcat(pathToTrainedSVMs,trainingClasses(class).name,'/'));
    pathToSVM = strcat(pathToTrainedSVMs,trainingClasses(class).name,'/',name);
    save(pathToSVM,'SVMModel');
    
end



