clear all
close all
clc
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>SETTINGS<~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
path = 'D:\RSA\DATA\testData\1k';

tChannel = channels.FIRST;  % transfer channel (only for Channel=3 mode)
rChannel = channels.FIRST;  % reception channel (for Channel=3 and
                            %                        Channel=2 modes)
startChirp = 1;             %
numberOfChirps = 500;       % number of chirp
stopTime = 0;               % μs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dataFilePath = getFile(path);
header = Header(dataFilePath);

[~, ~, ext] = fileparts(dataFilePath);
if(lower(ext) == ".bin" && isnan(header.channels))
    rawData = parse1k(dataFilePath, header, startChirp, numberOfChirps);
    shiftedData = sarShift(rawData, header);
    decimateData = decimation(shiftedData, header);
    rangeCompressedData = rangeCompression(decimateData, header);
    showImg(rangeCompressedData, header, stopTime);
elseif(lower(ext) == ".bin" && ~isnan(header.channels))
    rawData = parse2k(dataFilePath, header, startChirp, numberOfChirps, rChannel, tChannel);
    shiftedData = sarShift(rawData, header);
    decimateData = decimation(shiftedData, header);
    rangeCompressedData = rangeCompression(decimateData, header);
    showImg(rangeCompressedData, header, stopTime);
elseif(lower(ext) == ".mat")
    decimateData = parseMat(dataFilePath, startChirp, numberOfChirps);
    rangeCompressedData = rangeCompression(decimateData, header);
    showImg(rangeCompressedData, header, stopTime);
end
