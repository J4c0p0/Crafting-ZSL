function path_ = pather()

[checkip, config_ip] = system('ipconfig'); %It will throw an error on a Ubuntu Machine (i.e., checkip == 0)
[checkif, config_if] = system('ifconfig'); %It will throw an error on a Windows Machine (i.e., checkif == 0)

if checkip == 0 && contains(config_ip,'10.245.83.26') %we're on a windows machine (replace XX.XXX.XX.XX with IP address)
    path_.GBU_ = '??';
    path_.AWA2 = '??';
    path_.CUB = '??';
    path_.SUN = '??';
    path_.FLO = '??';
    path_.NAB = '??';
elseif checkif == 0 && contains(config_if,'10.255.0.137') % we're on a unix machine (replace XX.XXX.XX.XX with IP address)
    path_.GBU_ = '??';
    path_.AWA2 = '??';
    path_.CUB = '??';
    path_.SUN = '??';
    path_.FLO = '??';
    path_.NAB = '??';
else 
    path_ = NaN;
end
