function path_ = emergency_AWA2_downloader()

fprintf('Downloading AWA2 ..')
mkdir('./image_datasets/')
clear ME;
try websave('./image_datasets/AWA2','https://cvml.ist.ac.at/AwA2/AwA2-data.zip');
catch ME
end
if exist('ME','var')
    error('FATAL ERROR. Somebody removed Animals with Attributes 2 from the web')
end
fprintf('done!\n Unpacking ..')
extracted_ = unzip('./image_datasets/AWA2.zip');
parent_ = dir;
path_.AWA2 = [parent_(1).folder '\' extracted_{1} 'Animals_with_Attributes2\JPEGImages'];

attributes = importdata('./predicate-matrix-continuous.txt');
attributes = bsxfun(@rdivide,attributes,sqrt(sum(attributes.^2,2))); %
% Imposing L2 normalization of attributes as in [Xian et al. TPAMI 18]

AllClasses = importdata('./classes.txt');
for c = 1 : length(AllClasses)
    tmp = AllClasses{c};
    AllClasses{c} = tmp(8:end);
end
UnseenClasses = {'bat';'blue+whale';'bobcat';'dolphin';'giraffe';...
    'horse';'rat';'seal';'sheep';'walrus'};
SeenClasses = setdiff(AllClasses,UnseenClasses);
if length(SeenClasses) ~= 40
    error('Wrong Seen Class splits');
end

writecell(UnseenClasses,'./splits/AWA2_unseen_classes.txt');
writecell(SeenClasses,'./splits/AWA2_seen_classes.txt');
class_embeddings.AWA2.classes = AllClasses;
class_embeddings.AWA2.data = attributes;
save('./splits/class_embeddings_Xian.mat','class_embeddings');
