function [TestUnseenAcc,TrainAcc,iteration_number] = ZSL_evaluate_chekpoints(imdbTrain,TrainLabels,...
    imdbTestUnseen,TestUnseenLabels,...
    path2ckp_,dataset_name_,UnseenClasses,AllClasses)

D = dir([path2ckp_ '\net_checkpoint*.mat']);
path_ = pather();
if ~exist('./splits/class_embeddings_Xian.mat','file')
    addpath('./splits')
    write_class_embeddings(dataset_name_)
else
    load('./splits/class_embeddings_Xian.mat','class_embeddings')
    if ~isfield(class_embeddings,(dataset_name_))
        addpath('./splits')
        write_class_embeddings(dataset_name_)
        load('./splits/class_embeddings_Xian.mat','class_embeddings')
    end
end
attUnseen = single(class_embeddings.(dataset_name_).data');
attUnseen(:,~ismember(class_embeddings.FLO.classes,UnseenClasses)) = NaN;
attSeen = single(class_embeddings.(dataset_name_).data');
attSeen(:,ismember(class_embeddings.FLO.classes,UnseenClasses)) = NaN;

TestUnseenAcc = nan(length(D),1);
TrainAcc = nan(length(D),1);
iteration_number = nan(length(D),1);

for d = 1 : length(D)
    clear tmp_1 tmp_2;
    
    load([D(d).folder '\' D(d).name]);
    
    where_slash_in_ckp_name = strfind(D(d).name,'_'); %net_checkpoint__X...
    iteration_number(d,1) = str2double(D(d).name(where_slash_in_ckp_name(3)+1 : where_slash_in_ckp_name(4)-1));
    
    featuresTest = squeeze(activations(net,imdbTestUnseen,'relu_2'));
    
    DISTmat = pdist2(featuresTest',attUnseen');
    [~,pos] = min(DISTmat,[],2);
    PredTestUnseenLabels = AllClasses(pos);
    
    tmp_1 = mean(PredTestUnseenLabels == TestUnseenLabels);
    
    TestUnseenAcc(d,1) = tmp_1;
    
    featuresTrain = squeeze(activations(net,imdbTrain,'relu_2'));
    
    DISTmat = pdist2(featuresTrain',attSeen');
    [~,pos] = min(DISTmat,[],2);
    PredTrainLabels = AllClasses(pos);
    
    tmp_2 = mean(PredTrainLabels == TrainLabels);
    
    TrainAcc(d,1) = tmp_2;
    
    fprintf('Ckp %03d out of %03d (iter no. %04d) \t[train acc = %2.2f%%, T1 = %2.2f%%]\n',d,length(D),iteration_number(d,1),100*tmp_2,100*tmp_1)

end