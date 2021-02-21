function crafted_layers = crafting_net(net,dataset_name_,flag_semantic_craft)

if flag_semantic_craft
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
    
    att = class_embeddings.(dataset_name_).data';
    
    crafted_layers = [net;
    reluLayer;
    dropoutLayer(0.5);
    fullyConnectedLayer(size(att,1),'BiasL2Factor',20,'WeightL2Factor',10);
    reluLayer;
    fullyConnectedLayer(size(att,2),'BiasL2Factor',20,'WeightL2Factor',10);
    softmaxLayer;
    classificationLayer];

    crafted_layers(end-2).Bias = zeros(size(att,2),1);
    crafted_layers(end-2).Weights = att';
    crafted_layers(end-2).BiasLearnRateFactor = 1e-7;
    crafted_layers(end-2).WeightLearnRateFactor = 1e-7;
        
end
