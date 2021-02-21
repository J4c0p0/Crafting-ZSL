function [augimdb, Labels] = augment_imdb(imdb,size_)

Labels = imdb.Labels;
augimdb = augmentedImageDatastore(size_,imdb,'ColorPreprocessing','gray2rgb');