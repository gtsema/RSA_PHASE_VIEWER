function raw = parse1k(dataFilePath, header, startChirp, numberOfChirps)
    fid = fopen(dataFilePath);
    [cyclesNum, cycleLen, ~, tailLen] = getDataSpec(fid, header);
    
    start = Header.HEADER_LEN + (startChirp - 1)*cycleLen + Header.CYCLE_HEADER_LEN;
    skip = Header.CYCLE_HEADER_LEN + tailLen;
    
    if(startChirp + numberOfChirps > cyclesNum)
        disp("Количество циклов больше доступного и будет уменьшено до максимально возможного");
        numberOfChirps = cyclesNum - startChirp;
    end
    
    raw = zeros(numberOfChirps, header.samples);
    fseek(fid, start, 'bof');
    for i = 1:numberOfChirps
        raw(i, :) = fread(fid, header.samples, 'ubit12=>double');
        raw(i, :) = raw(i, :)' - 2048;
        fseek(fid, skip, 'cof');
    end
    fclose(fid);
end
