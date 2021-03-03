function net_cut = net_cutter(net,layer_cut_name)

for i = 1 : length(net.Layers)
    if strcmpi(layer_cut_name,net.Layers(i).Name)
        position_cut = i;
        break
    end
end

net_cut = net.Layers(1:position_cut);
