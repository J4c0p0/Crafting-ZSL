
function [imdbTrainSeen,imdbTestSeen] = generalizedZSL_data_loader(imdbSeen,TrainFileNames)
%% Exemplar input to run
%clear; close all; clc;
%imdb = imageDatastore('J:\ZSL_datasets\FLO','IncludeSubfolders',true,'LabelSource','foldernames');    
%UnseenClasses = importdata('./double_check_data_loading/FLO_unseen_classes.txt');
%imdbSeen = ZSL_data_loader(imdb,UnseenClasses);
%splits = importdata('./double_check_data_loading/FLO_splits.xls');
%TrainFileNames = splits.train_seen(:,2);

complete_path_to_images = imdbSeen.Files;
whr_ = contains(complete_path_to_images,TrainFileNames);

imdbTrainSeen = subset(imdbSeen,whr_);
imdbTestSeen = subset(imdbSeen,~whr_);