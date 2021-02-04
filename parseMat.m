function raw = parseMat(dataFilePath, startChirp, numberOfChirps)
    raw = [];
    load(dataFilePath);
    raw = [raw; complex(rawRe,rawIm)];
    raw = raw(startChirp:(startChirp + numberOfChirps - 1), :);
end