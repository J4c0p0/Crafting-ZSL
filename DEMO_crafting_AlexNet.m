clear; close all; clc;

%% Hyper-params

dataset_name_ = 'AWA2';
flag_semantic_craft = true; %Set it to false for visual crafting

solver_name_ = 'adam';
MiniBatchSize_ = 256;
MaxEpochs_ = 10;
InitialLearnRate_ = 1e-4;
path2ckp_ = '.\ckp';

% Ideally, no changes hereafter
%-------------------------------------------------------------------------
%% Path importer and setter

addpath('.\utils\')

%% Setting directory to save checkpoints
path2ckp_ = [path2ckp_ '\alexnet\' dataset_name_ '\' solver_name_ '_Batch' sprintf('%d',MiniBatchSize_) '_Epochs' sprintf('%d',MaxEpochs_) '_lr' sprintf('%1.0e',InitialLearnRate_)];
if exist(path2ckp_,'dir')
    error('Experiment already run!')
else
    mkdir(path2ckp_);
end

%% Loading data

if ~ismember(dataset_name_,{'AWA2','CUB','SUN','FLO'})
    error('Unsupported dataset: must be either AWA2, CUB, SUN or FLO');
end

[imdbTrain, imdbTestUnseen, imdbTestSeen, UnseenClasses] =  full_data_loader(dataset_name_,true);

AllClasses = categories(imdbTrain.Labels);
numClasses = numel(AllClasses);
%Note that, I am always working with image databases spanning the *whole
%set of classes* but *only* formally! In fact, I am still allocating all
%the possible class labels, while storing effective data only for
%seen/unseen classes according to the necessity. Therefore, we are not
%breaking the ZSL assumption: when using "imdbTrain" for training, data
%will always be relative to the correct seen classes. I am simply
%allocating unused bins in the softmax classifier, and these bins will not
%really optimized by gradient descent - since no labels from the unseen
%classe are there.

%% Load AlexNet (and related spec)
net = alexnet;
cut_at_layer_name = 'fc7';
layers_cut = net_cutter(net,cut_at_layer_name);
size_ = net.Layers(1).InputSize;

%% Data augmentation (optional, here only reshaping dimension and grayscale to RGB conversion)
[augimdbTrain, TrainLabels] = augment_imdb(imdbTrain,size_);
[augimdbTestUnseen, TestUnseenLabels] = augment_imdb(imdbTestUnseen,size_);
if ~flag_ZSL
    [augimdbTestSeen, TestSeenLabels] = augment_imdb(imdbTestSeen,size_);
end

%% Training the crafted network
crafted_layers = crafting_net(layers_cut,dataset_name_,flag_semantic_craft);
options = trainingOptions(solver_name_, ...
    'MiniBatchSize',MiniBatchSize_, ...
    'MaxEpochs',MaxEpochs_, ...
    'InitialLearnRate',InitialLearnRate_, ...
    'Verbose',false, ...
    'CheckpointPath',path2ckp_, ...
    'Plots','training-progress');
[crafted_net, info] = trainNetwork(augimdbTrain,crafted_layers,options);
save([path2ckp_ '\training_info.mat'],'info');

%% Clear all checkpoints but the last
list_of_ckps = dir([path2ckp_ '\net_checkpoint*.mat]);
for d = 1 : length(list_of_ckps)
    where_slash_in_ckp_name = strfind(list_of_ckps(d).name,'_'); %net_checkpoint__X...
    iteration_number(d,1) = str2double(list_of_ckps(d).name(where_slash_in_ckp_name(3)+1 : where_slash_in_ckp_name(4)-1));
end
[iteration_number,idx_] = sort(iteration_number);
for d = 1 : lengt(list_of_ckps)
  delete([list_of_ckps(d).folder '\' list_of_ckps(d).name]);
end

%% Checking Training Accuracy
load('./splits/class_embeddings_Xian.mat','class_embeddings')
attSeen = single(class_embeddings.(dataset_name_).data');
attSeen(:,ismember(class_embeddings.FLO.classes,UnseenClasses)) = NaN;

featuresTrain = squeeze(activations(crafted_net,imdbTrain,'relu_2'));
DISTmat = pdist2(featuresTrain',attSeen','cosine');
[~,pos] = min(DISTmat,[],2);
PredTrainLabels = AllClasses(pos);

TrainAcc = mean(PredTrainLabels == TrainLabels);

%% Checking Top-1 Testing Accuracy over Unseen Classes (Zero-Shot Learning)
attUnseen = single(class_embeddings.(dataset_name_).data');
attUnseen(:,~ismember(class_embeddings.FLO.classes,UnseenClasses)) = NaN;

featuresTest = squeeze(activations(net,imdbTestUnseen,'relu_2'));
DISTmat = pdist2(featuresTest',attUnseen');
[~,pos] = min(DISTmat,[],2);
PredTestUnseenLabels = AllClasses(pos);
    
T1 = mean(PredTestUnseenLabels == TestUnseenLabels);   
