function [augimdb, Labels] = augment_imdb(imdb,size_,dataset_name_)

Labels = imdb.Labels;
augimdb = augmentedImageDatastore(size_,imdb,'ColorPreprocessing','gray2rgb');
