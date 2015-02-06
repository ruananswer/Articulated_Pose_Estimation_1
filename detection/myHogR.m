function feat = myHog( simage, sbin, model )
%MYHOG Summary of this function goes here
%   Detailed explanation goes here

% change feature must change " nw * nh * nf " the in initmodel.m
% 

%feat = features(simage, sbin);
%%{

F = FourierHOG(im2double(simage), 11);
[padL, padC, padK] = size(simage);
ifr = floor((padL - 28)/4);
jfr = floor((padC - 28)/4);

feat = zeros(ifr+1, jfr+1, model.featureDimen);

for i = 1 : ifr+1
    for j = 1 : jfr+1
        %k = k + 1;
        temp = simage((i-1)*4+1 : (i-1)*4+28, (j-1)*4+1 : (j-1)*4+28, :);
        temp_feat = extractRGH(temp, model.testRadius, model.Bin, model.maskCircle, model.partNum, model.featureDimen-1693);
        feat(i, j, :) = cat(2, temp_feat', F( ((i-1)*4+15)*size(simage, 2) + ((j-1)*4+15), : ));
    end
end
%}

end

