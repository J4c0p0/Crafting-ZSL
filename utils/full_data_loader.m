function [imdbTrain, imdbTestUnseen, imdbTestSeen, UnseenClasses] =  full_data_loader(dataset_name_,flag_ZSL)

path_ = pather();

if isnan(path_) && strcmpi(dataset_name_,'AWA2')
    addpath('./splits/')
    path_ = emergency_AWA2_downloader();
else
    error('Please specify the path for the current dataset, inside pather.m')
end

if exist(['./splits/' dataset_name_ '_unseen_classes.txt'],'file')
    UnseenClasses = importdata(['./splits/' dataset_name_ '_unseen_classes.txt']);
else
    if exist(['./splits/create_txt_files_data_' dataset_name_ '.m'],'file')
        run(['./splits/create_txt_files_data_' dataset_name_ '.m']);
        UnseenClasses = importdata(['./splits/' dataset_name_ '_unseen_classes.txt']);
    else
        error('xls and txt files for (G)ZSL splits are needed!');
    end
end

if flag_ZSL
    imdb = imageDatastore(path_.(dataset_name_),'IncludeSubfolders',true,...
        'LabelSource','foldernames');
    [imdbTrain, imdbTestUnseen] = ZSL_data_loader(imdb,UnseenClasses);
    imdbTestSeen = [];
else
    imdb = imageDatastore(path_.(dataset_name_),'IncludeSubfolders',true,...
        'LabelSource','foldernames');
    [imdbAllSeen, imdbTestUnseen] = ZSL_data_loader(imdb,UnseenClasses);
    
    splits = importdata(['./splits/' dataset_name_ '_splits.xls']);
    TrainFileNames = splits.train_seen(:,2);
    clear splits;
    
    [imdbTrain,imdbTestSeen] = generalizedZSL_data_loader(imdbAllSeen,TrainFileNames);
end
