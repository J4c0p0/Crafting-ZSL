function [path_, flag_downloaded, flag_unzipped] = emergency_AWA2_downloader()

flag_downloaded = false; %Boolean to understand if we have to download the
                         %Animals with Attributes 2 dataset from the web
flag_unzipped = false; %Boolean to understand if I have to unzip the
                       %AWA2.zip file, once downloaded
if ~exist('./image_datasets/','dir')
    flag_downloaded = true;
    flag_unzipped = true;
    mkdir('./image_datasets/')
end

if ~exist('./image_datasets/AWA2.zip','file')
    if ~exist('./image_datasets/Animals_with_Attributes2/','dir')
        fprintf('Downloading AWA2 .. (please, be patient, it''s 13 GB!)')
        
        clear ME;
        try websave('./image_datasets/AWA2','https://cvml.ist.ac.at/AwA2/AwA2-data.zip');
        catch ME
        end
        
        if exist('ME','var')
            error('FATAL ERROR. Downloading Animals with Attributes 2 from the Web failed')
        end
        fprintf('done!\n');
        flag_downloaded = true;
    end
end

if ~exist('./image_datasets/Animals_with_Attributes2/','dir') && ...
    exist('./image_datasets/AWA2.zip','file')

    fprintf('Unpacking AWA2.zip .. (again, please wait, still 13 GB of stuff to be unpacked')
    
    clear ME;
    try unzip('./image_datasets/AWA2.zip','./image_datasets/');
    catch ME
    end
    if exist('ME','var')
        error('FATAL ERROR. Unzipping AWA2.zip failed');
    end
    fprintf('done!\n');
    flag_unzipped = true;
    
end

% Allocating the path where we will now load the image database
path_.AWA2 = './image_datasets/Animals_with_Attributes2/JPEGImages';

%% Let's create the splits (for ZSL) using the proposed splits (PS) by [Xian et al. TPAMI 18]

%Class embeddings ...
attributes = importdata('./image_datasets/Animals_with_Attributes2/predicate-matrix-continuous.txt');
attributes = bsxfun(@rdivide,attributes,sqrt(sum(attributes.^2,2))); %
% ... are L2 normalied as in [Xian et al. TPAMI 18]

% Extracting class names
SeenClasses = {'antelope'; 'beaver'; 'buffalo'; 'chihuahua'; 'chimpanzee'; ...
    'collie'; 'cow'; 'dalmatian'; 'deer'; 'elephant'; 'fox'; ...
    'german+shepherd'; 'giant+panda'; 'gorilla'; 'grizzly+bear'; ...
    'hamster'; 'hippopotamus'; 'humpback+whale'; 'killer+whale'; ...
    'leopard'; 'lion'; 'mole'; 'moose'; 'mouse'; 'otter'; 'ox'; ...
    'persian+cat'; 'pig'; 'polar+bear'; 'rabbit'; 'raccoon'; 'rhinoceros'; ...
    'siamese+cat'; 'skunk'; 'spider+monkey'; 'squirrel'; 'tiger'; ...
    'weasel'; 'wolf'; 'zebra';};


% Allocating the unseen classes names as in the PS of AWA2 from [Xian et al. TPAMI 18]
UnseenClasses = {'bat';'blue+whale';'bobcat';'dolphin';'giraffe';...
    'horse';'rat';'seal';'sheep';'walrus'};

% Check that seen and unseen classes are disjoint
if ~isempty(intersect(SeenClasses,UnseenClasses))
    error('Overlap between seen and unseen classes!');
end

% Group all classes
AllClasses = importdata('.\image_datasets\Animals_with_Attributes2\classes.txt');
for c = 1 : 50
    tmp = AllClasses{c};
    AllClasses{c} = tmp(8:end);
end

if ~isempty(setdiff(union(SeenClasses,UnseenClasses),AllClasses)) || ...
   ~isempty(setdiff(AllClasses,union(SeenClasses,UnseenClasses)))
    error('There is a mismatch in the classes'' names');
end
    
% Save data on the splits 
writecell(UnseenClasses,'./splits/AWA2_unseen_classes.txt');
writecell(SeenClasses,'./splits/AWA2_seen_classes.txt');
class_embeddings.AWA2.classes = AllClasses;
class_embeddings.AWA2.data = attributes;
save('./splits/class_embeddings_Xian.mat','class_embeddings');
