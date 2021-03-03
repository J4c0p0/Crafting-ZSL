function crafted_layers = crafting_net(net,dataset_name_,flag_semantic_craft)

if flag_semantic_craft
    load('./splits/class_embeddings_Xian.mat','class_embeddings')
    
    [NumClasses_,AttSize_] = size(class_embeddings.(dataset_name_).data);
    
    crafted_layers = [net;
        reluLayer;
        dropoutLayer(0.5);
        fullyConnectedLayer(AttSize_,'BiasL2Factor',20,'WeightL2Factor',10);
        reluLayer;
        fullyConnectedLayer(NumClasses_,'BiasL2Factor',20,'WeightL2Factor',10);
        softmaxLayer;
        classificationLayer];
    
    crafted_layers(end-2).Bias = zeros(NumClasses_,1);
    crafted_layers(end-2).Weights = class_embeddings.(dataset_name_).data;
else %Assuming crafting to be visual
    error('Code is not released yet!\n')
end
