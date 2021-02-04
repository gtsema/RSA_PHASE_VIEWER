function raw = parse2k(dataFilePath, header, startChirp, numberOfChirps, rChannel, tChannel)
    switch header.channels
        case channels.FIRST || channels.SECOND
            raw = parse2ch_firstOrSecond(dataFilePath, header, startChirp, numberOfChirps);
        case channels.BOTH_CONSISTENTLY
            raw = parse2chConsistently(dataFilePath, header, startChirp, numberOfChirps, rChannel, tChannel);
        case channels.BOTH_CONCURRENTLY
            raw = parse2chConcurrently(dataFilePath, header, startChirp, numberOfChirps, rChannel);
    end
end

function raw = parse2ch_firstOrSecond(dataFilePath, header, startChirp, numberOfChirps)
    fid = fopen(dataFilePath);
    [~, ~, cycleDataLen, tailLen] = getDataSpec(fid, header);
    start = Header.HEADER_LEN + (startChirp - 1)*(Header.CYCLE_HEADER_LEN + cycleDataLen + tailLen) + Header.CYCLE_HEADER_LEN;
    skip = tailLen + Header.CYCLE_HEADER_LEN;
    raw = zeros(numberOfChirps ,header.samples);
    
    fseek(fid, start, 'bof');
    for i = 1:numberOfChirps
        raw(i, :) = fread(fid, header.samples, 'bit16');
        fseek(fid, skip, 'cof');
    end
    fclose(fid);
end

function raw = parse2chConcurrently(dataFilePath, header, startChirp, numberOfChirps, rChannel)
    fid = fopen(dataFilePath);
    [~, ~, cycleDataLen, tailLen] = getDataSpec(fid, header);
    rawR1 = zeros(numberOfChirps, header.samples);
    rawR2 = zeros(numberOfChirps, header.samples);
    samples = header.samples*2; % for 2 channels
    
    start = Header.HEADER_LEN + (startChirp - 1)*(Header.CYCLE_HEADER_LEN + cycleDataLen + tailLen) + Header.CYCLE_HEADER_LEN;
    skip = tailLen + Header.CYCLE_HEADER_LEN;
    
    fseek(fid, start, 'bof');
    for i = 1:numberOfChirps
        raw = fread(fid, samples, 'bit16');
        j=0;
        for k = 1:8:samples
            a=k-j;
            b=a+3;
            rawR1(i, a:b) = raw(k:k+3);
            rawR2(i, a:b) = raw(k+4:k+7);
            j=j+4;
        end
        fseek(fid, skip, 'cof');
    end
    fclose(fid);
    
    if(rChannel == channels.FIRST)
        raw = rawR1;
    elseif(rChannel == channels.SECOND)
        raw = rawR2;
    end
end

function raw = parse2chConsistently(dataFilePath, header, startChirp, numberOfChirps, rChannel, tChannel)
    fid = fopen(dataFilePath);
    [~, cycleLen, ~, tailLen] = getDataSpec(fid, header);
    rawR1 = zeros(numberOfChirps, header.samples);
    rawR2 = zeros(numberOfChirps, header.samples);
    
    samples = header.samples*2; % for 2 channels
    if(tChannel == channels.FIRST)
        start = Header.HEADER_LEN + (startChirp - 1)*2*cycleLen + Header.CYCLE_HEADER_LEN;
    elseif(tChannel == channels.SECOND)
        start = Header.HEADER_LEN + (startChirp - 1)*2*cycleLen + cycleLen + Header.CYCLE_HEADER_LEN;
    end
    skip = tailLen + Header.CYCLE_HEADER_LEN + cycleLen;
    
    fseek(fid, start, 'bof');
    for i = 1:numberOfChirps
        raw = fread(fid, samples, 'bit16');
        j=0;
        for k = 1:8:samples 
            a=k-j;
            b=a+3;
            rawR1(i, a:b) = raw(k:k+3);
            rawR2(i, a:b) = raw(k+4:k+7);
            j=j+4;
        end
        fseek(fid, skip, 'cof');
    end
    fclose(fid);
    
    if(rChannel == channels.FIRST)
        raw = rawR1;
    elseif(rChannel == channels.SECOND)
        raw = rawR2;
    end
end