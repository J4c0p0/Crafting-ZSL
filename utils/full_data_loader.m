function [imdbTrain, imdbTestUnseen, imdbTestSeen] =  full_data_loader(dataset_name_,UnseenClasses,TrainFileNames)
%% Exemplar input to run
%clear; close all;
%dataset_name_ = 'FLO';
%UnseenClasses = importdata(['../splits/' dataset_name_ '_unseen_classes.txt']);
%splits = importdata(['../splits/' dataset_name_ '_splits.xls']);
%TrainFileNames = splits.train_seen(:,2);
%clear splits;

paths = pather();

if isempty(TrainFileNames) %We're in standard, inductive ZSL
    imdb = imageDatastore(paths.(dataset_name_),'IncludeSubfolders',true,...
        'LabelSource','foldernames');
    [imdbTrain, imdbTestUnseen] = ZSL_data_loader(imdb,UnseenClasses);
    imdbTestSeen = [];
else
    imdb = imageDatastore(paths.(dataset_name_),'IncludeSubfolders',true,...
        'LabelSource','foldernames');
    [imdbAllSeen, imdbTestUnseen] = ZSL_data_loader(imdb,UnseenClasses);
    [imdbTrain,imdbTestSeen] = generalizedZSL_data_loader(imdbAllSeen,TrainFileNames);
end

