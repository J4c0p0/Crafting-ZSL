function path_ = pather()

[checkip, config_ip] = system('ipconfig'); %It will throw an error on a Ubuntu Machine (i.e., checkip == 0)
[checkif, config_if] = system('ifconfig'); %It will throw an error on a Windows Machine (i.e., checkif == 0)
flag_all_setup = false;

if checkip == 0 && contains(config_ip,'10.245.83.26') %Win Tower
    path_.GBU_ = 'J:\ZSL_datasets\theGood_theBad_theUgly\xlsa17\data';
    path_.AWA2 = 'J:\ZSL_datasets\AwA2\images';
    path_.CUB = 'J:\ZSL_datasets\CUB\images-cropped';
    path_.SUN = 'G:\Datasets\SUNa\images_folder_equal_class';
    path_.FLO = 'G:\Datasets\OxfordFlowers';
    path_.NAB = 'G:\Datasets\NABirds\cropped_imgs_404';
    flag_all_setup = true;
elseif checkif == 0 && contains(config_if,'10.255.0.137') % Unix Workstation 1
    path_.GBU_ = '??';
    path_.AWA2 = '??';
    path_.CUB = '??';
    path_.SUN = '??';
    path_.FLO = '??';
    path_.NAB = '??';
elseif checkip == 0 && contains(config_ip,'10.255.9.50') % Win Workstation 2
    path_.GBU_ = '??';
    path_.AWA2 = '??';
    path_.CUB = '??';
    path_.SUN = '??';
    path_.FLO = '??';
    path_.NAB = '??';
elseif checkip == 0 && contains(config_ip,'10.255.9.51') % Win Workstation 3
    path_.GBU_ = '??';
    path_.AWA2 = '??';
    path_.CUB = '??';
    path_.SUN = '??';
    path_.FLO = '??';
    path_.NAB = '??';
elseif checkif == 0 && contains(config_if,'10.245.83.22') %Ubu Tower (Esculapio)
    path_.GBU_ = '/home/cavazza/Documents/Dataset/ZSL/GBU/xlsa17/data';
    path_.AWA2 = '/media/cavazza/MyPassPort/Datasets/Animals_with_Attributes2/JPEGImages';
    path_.CUB = '/media/cavazza/MyPassPort/Datasets/CUB_200_2011/images_cropped';
    path_.SUN = '/media/cavazza/MyPassPort/Datasets/SUNa/images_one_folder_per_class';
    path_.FLO = '/media/cavazza/MyPassPort/Datasets/OxfordFlowers';
    path_.NAB = '/media/cavazza/MyPassPort/Datasets/NABirds/cropped_imgs_404';
    flag_all_setup = true;
else %Assuming to be on my IIT laptop
    path_.GBU_ = 'D:\Datasets\ZSL\Good_Bad_Ugly\xlsa17';
    path_.AWA2 = 'D:\Datasets\AnimalsWithAttributes2\Animals_with_Attributes2\JPEGImages';
    path_.CUB = 'D:\Datasets\CUB_200_2011\images-cropped';
    path_.SUN = 'D:\Datasets\SUNa\images_one_folder_per_class';
    path_.FLO = 'D:\Datasets\Oxford Flowers\FLO';
    path_.NAB = 'D:\Datasets\NABirds\cropped_imgs_404';
    flag_all_setup = true;
end

if ~flag_all_setup
    error('Undefined path for this machine!')
end
