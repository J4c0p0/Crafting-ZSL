clear; close all; clc;

% Implementing the idea of crafting a convnet, imposing fixed classification
% rules that, since defined upon class embeddings (or inferred visual prototypes)
% will generalize, by design, towards classes unseen at training time. By doing so, 
% we cast a "vanilla" convnect into a zero-shot learner
%
% Expected Results:
% Semantic Crafting + AlexNet: 0.40/0.43 on T1 (ZSL unseen top-1 classification score)
%
% Copyright (c) 2021 Jacopo Cavazza
%
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without
% restriction, including without limitation the rights to use,
% copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following
% conditions:
%
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
% HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
% WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
% OTHER DEALINGS IN THE SOFTWARE.

%% Hyper-params

dataset_name_ = 'AWA2';
flag_ZSL = true;
flag_semantic_craft = true; %Set it to false for visual crafting

solver_name_ = 'adam';
MiniBatchSize_ = 256;
MaxEpochs_ = 5;
InitialLearnRate_ = 1e-4;
path2ckp_ = '.\ckp';

% Ideally, no changes hereafter
%-------------------------------------------------------------------------
%% Path importer and setter

addpath('.\utils\')


%% Setting directory to save checkpoints

if flag_semantic_craft
    path2ckp_ = [path2ckp_ '\alexnet\semantic'];
else
    path2ckp_ = [path2ckp_ '\alexnet\visual'];
end
path2ckp_ = [path2ckp_ '\' solver_name_ '_Batch' sprintf('%d',MiniBatchSize_) '_Epochs' sprintf('%d',MaxEpochs_) '_lr' sprintf('%1.0e',InitialLearnRate_)];
if exist(path2ckp_,'dir')
    warning('Experiment already run!')
    str_ = input('Overwrite? [Y/n]');
    if strcmpi(str_,'n')
        return
    else
        clc;
        delete([path2ckp_ '\*']);
    end
else
    mkdir(path2ckp_);
end

%% Loading data

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

%Permuting attributes to match order in AllClasses
load('./splits/class_embeddings_Xian.mat')
tmp_data = nan(size(class_embeddings.(dataset_name_).data));
for i = 1 : length(AllClasses)
    [~,pos] = ismember(AllClasses{i},class_embeddings.(dataset_name_).classes);
    tmp_data(i,:) = class_embeddings.(dataset_name_).data(pos,:);
end
if ismember(1,unique(isnan(tmp_data(:))))
    error('Some attributes where not correclty written');
end
class_embeddings.AWA2.data = tmp_data;
class_embeddings.AWA2.classes = AllClasses;
save('./splits/class_embeddings_Xian.mat','class_embeddings');

%% Load AlexNet (and related spec)
net = alexnet;
cut_at_layer_name = 'fc7';
layers_cut = net_cutter(net,cut_at_layer_name);
size_ = net.Layers(1).InputSize;

%% Data augmentation (optional, here only reshaping dimension and grayscale to RGB conversion)
[augimdbTrain, TrainLabels] = augment_imdb(imdbTrain,size_,dataset_name_);
[augimdbTestUnseen, TestUnseenLabels] = augment_imdb(imdbTestUnseen,size_,dataset_name_);
if ~flag_ZSL
    [augimdbTestSeen, TestSeenLabels] = augment_imdb(imdbTestSeen,size_,dataset_name_);
end

if ~flag_semantic_craft
    compute_protos(net,dataset_name_,augimdbTrain,TrainLabels,cut_at_layer_name )
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
crafted_layers(end-2).BiasLearnRateFactor = 1e-9;
crafted_layers(end-2).WeightLearnRateFactor = 1e-9;

tic;

fprintf('Training the network ..')
[crafted_net, info] = trainNetwork(augimdbTrain,crafted_layers,options);
fprintf(' done!\n');

save([path2ckp_ '\training_info.mat'],'info');

%% Clear all checkpoints but the last
list_of_ckps = dir([path2ckp_ '\net_checkpoint*.mat']);
iteration_number = nan(length(list_of_ckps),1);
for d = 1 : length(list_of_ckps)
    where_slash_in_ckp_name = strfind(list_of_ckps(d).name,'_'); %net_checkpoint__X...
    iteration_number(d,1) = str2double(list_of_ckps(d).name(where_slash_in_ckp_name(3)+1 : where_slash_in_ckp_name(4)-1));
end
[iteration_number,idx_] = sort(iteration_number);
for d = 1 : length(list_of_ckps)
  delete([list_of_ckps(d).folder '\' list_of_ckps(d).name]);
end

%% Checking Training Accuracy

fprintf('Computing training accuracy ..')
% attSeen = single(class_embeddings.(dataset_name_).data');
% attSeen(:,ismember(class_embeddings.AWA2.classes,UnseenClasses)) = NaN;
% 
% featuresTrain = squeeze(activations(crafted_net,augimdbTrain,'relu_2'));
% scoresSeen = transpose(attSeen)*featuresTrain;
% [~,pos] = max(scoresSeen,[],1);
PredTrainLabels = classify(crafted_net,augimdbTrain);
% 
TrainAcc = mean(PredTrainLabels == TrainLabels);
fprintf('done!\n')

%% Checking Top-1 Testing Accuracy over Unseen Classes (Zero-Shot Learning)
load('./splits/class_embeddings_Xian.mat','class_embeddings')
attUnseen = single(class_embeddings.(dataset_name_).data');
attUnseen(:,~ismember(AllClasses,UnseenClasses)) = NaN;

fprintf('Computing testing accuracy ..')
featuresTest = squeeze(activations(crafted_net,augimdbTestUnseen,'relu_2'));
scoresUnseen = transpose(attUnseen)*featuresTest;
[~,pos] = max(scoresUnseen,[],1);
PredTestUnseenLabels = categorical(AllClasses(pos));
fprintf('done!\n');
    
T1 = mean(PredTestUnseenLabels == TestUnseenLabels); 

fprintf(['ZSL top-1 classification accuracy over unseen classes: T1 = %2.2f%%\n'...
'Elapsed time = %f seconds (I am not considering the time to download and unzip) \n'],T1*100,toc);
