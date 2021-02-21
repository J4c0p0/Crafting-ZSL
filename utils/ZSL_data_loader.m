
function [imdbSeen, imdbUnseen] = ZSL_data_loader(imdb,UnseenClasses)
%% Exemplar input to run
%clear; close all; clc;
%imdb = imageDatastore('J:\ZSL_datasets\FLO','IncludeSubfolders',true,'LabelSource','foldernames');    
%UnseenClasses = importdata('./double_check_data_loading/FLO_unseen_classes.txt');

complete_path_to_images = imdb.Files;
whr_ = contains(complete_path_to_images,UnseenClasses);

imdbUnseen = subset(imdb,whr_);
imdbSeen = subset(imdb,~whr_);