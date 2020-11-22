function imgw = changeImage(IM, xGrid, yGrid, xNoise, yNoise, maxChange)
    %creo le griglie con i punti originali (Z) e le loro immagini (Y)
    i = 1;
    for row = xGrid: xGrid: size(IM,1)-xGrid
        for col = yGrid: yGrid: size(IM,2)-yGrid
            Y(i,1) = col + floor(xNoise*(rand(1)-0.5));
            Y(i,2) = row + floor(yNoise*(rand(1)-0.5));
            i = i+1;
        end
    end
    i = 1;
    for row = xGrid: xGrid: size(IM,1)-xGrid
        for col = yGrid: yGrid: size(IM,2)-yGrid
            Z(i,1) = col;
            Z(i,2) = row;
            i = i + 1;
        end
    end

    %scelgo le opzioni
    interp = struct();
    interp.method = 'nearest';
    interp.radius = maxChange;
    interp.power = 1;
    
    %chiamo la function nel tool
    [imgw, imgwr, map] = tpswarp(single(IM),[size(IM,2),size(IM,1)],Z,Y,interp);
end