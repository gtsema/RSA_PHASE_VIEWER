function showImg(raw, header, stopTime)
    
    if (stopTime == 0)
        points = size(raw, 2);
        stopTime = ceil(header.samples/constants.FREQ*1e6);
    else
        rangeDecimationFactor = floor(constants.FREQ / header.deviation);
        points = ceil(stopTime/1e6*(constants.FREQ/rangeDecimationFactor));
    end 

    if(stopTime <= 2)
        step = 0.2;
    elseif(stopTime <= 10)
        step = 0.5;
    elseif(stopTime <= 20)
        step = 1;
    elseif(stopTime <= 50)
        step = 5;
    else
        step = 10;
    end
    
    lbl = 0:step:stopTime;
    t = lbl .* points ./ stopTime;
    t = ceil(t);
    
    
    imagesc(abs(raw(:, 1:points)));
    set(gca, 'XTick', t);
    set(gca, 'XTickLabel', lbl);
%     set(gca, 'YTick', '');
%     set(gca, 'YTickLabel', '');
    xlabel('μs');
end
