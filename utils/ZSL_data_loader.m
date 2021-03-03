function [imdbSeen, imdbUnseen] = ZSL_data_loader(imdb,UnseenClasses)

complete_path_to_images = imdb.Files;
whr_ = contains(complete_path_to_images,UnseenClasses);

imdbUnseen = subset(imdb,whr_);
imdbSeen = subset(imdb,~whr_);
