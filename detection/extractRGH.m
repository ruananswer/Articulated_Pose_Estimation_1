function H = extractRGH(im, Radius, B, maskCircle, partNum, featureDimen)
% im is the image
% Radius is the radius of each annulus
% B = 9  the angle of hog
% gaussianKernel is the annulus' weight
% maskCircle is an look-up table to patch the concentric circles
% nParts is the num of partitions 

im = im2double(im);
[L, C, K] = size(im);

maxSize = max(L, C);
if maxSize ~= L || maxSize ~= C
    im = padarray(im, double(int32([(maxSize - L)/2, (maxSize - C)/2])));
end
Center = floor([(maxSize+1)/2, (maxSize+1)/2]);

grad_x = zeros(maxSize, maxSize);
grad_y = zeros(maxSize, maxSize);
rgtx = zeros(maxSize, maxSize);
rgty = zeros(maxSize, maxSize);

if K ~= 1
    [DX, DY, ~] = gradient(im);
    mag = DX .^ 2 + DY .^ 2;
    [~,channel] = max(mag,[],3);
    grad_x = DX(:,:, 1) .* (channel == 1) + DX(:,:, 2) .* (channel == 2) + DX(:,:, 3) .* (channel == 3);
    grad_y = DY(:,:, 1) .* (channel == 1) + DY(:,:, 2) .* (channel == 2) + DY(:,:, 3) .* (channel == 3);
    complex_g = complex(grad_x,grad_y);    
else
    [grad_x,grad_y] = gradient(im);
    complex_g = complex(grad_x,grad_y);    
end

%% for each pixel to compute RGT
for i = 1 : maxSize
    for j = 1 : maxSize   
        cp = [maxSize-i+1-Center(1), j-Center(2)];
        theta = atan2(cp(1), cp(2));
        radial = [cos(theta), sin(theta)];
        tangential = [-radial(2), radial(1)];
        gradientt = [grad_y(i,j); grad_x(i,j)];
        rgty(i,j) = radial*gradientt;
        rgtx(i,j) = tangential*gradientt;
    end
end

complex_g2 = complex(rgtx, rgty);
newangles = angle(complex_g2);
newmagnit = abs(complex_g);

%% 
if K ~= 1
    %YIQ = rgb2ntsc(im);
    %grayim = YIQ(:, :, 1);
    grayim = rgb2gray(im);
    %YCBCR = rgb2ycbcr(im);
    %grayim = YCBCR(:, :, 1);
    %grayim = im;   
    %xyz = rgb2xyz(im);
    %grayim = xyz(:, :, 3);
else
    grayim = im;
end

cont  = 0;
numRids = size(Radius, 1) - 1;
H = zeros(featureDimen, 1);

for i = 1 : numRids
	mask = maskCircle{i};
    % show circle
    %{ 
    mat = zeros(maxSize,maxSize);
    for j = 1:size(mask,1)
        mat(mask(j,1), mask(j,2)) = 1;
    end
    imshow(mat, [-1 1]);
    %}
    KKK = size(mask, 1);
    
    v_angles = zeros(KKK, 1);
    v_magnit = zeros(KKK, 1);
    v_grayim = zeros(KKK, 1);

    for j = 1 : KKK
        v_angles(j, 1) = newangles(mask(j, 1), mask(j, 2));
        v_magnit(j, 1) = newmagnit(mask(j, 1), mask(j, 2));
        v_grayim(j, 1) = grayim(mask(j, 1), mask(j, 2), 1);
    end
    
    nParts = max(1, floor(KKK/partNum));
    if nParts ~= 1 && partNum < KKK
        [fcmCenter, fcmU] = fcm(v_grayim, nParts, [2; 100; 1e-5; 0]);
        for j = 1 : nParts
            index{i,j} = find(fcmU(j,:) >= 0.3);
            sortnum(j) = size(index{i,j}, 2);
            %sortindex(j) = j;
        end
        [tempsort, sortindex] = sort(sortnum);
        %{
        [cc, ssindex] = sort(v_grayim);
        for j = 1 : nParts
            if abs(j*partNum - KKK) < partNum
                index{i, j} = ssindex((j-1)*partNum+1 : KKK);
            else
                index{i, j} = ssindex((j-1)*partNum+1 : j*partNum);
            end
            sortindex(j) = j;
        end
        %}
    else
        index{i, 1} = 1:KKK;
        sortindex = 1;
        nParts = 1;
    end

    for j = 1 : nParts
    	cont = cont + 1;
        %{
        mat = zeros(maxSize,maxSize);
        for kk = 1 : length(index{i, sortindex(j)})
            mat(mask(index{i,sortindex(j)}(kk), 1), mask(index{i,sortindex(j)}( kk), 2)) = 1;
        end
        imshow(mat, [-1 1]);            
        %}
	    vv_magnit = v_magnit(index{i,sortindex(j)}, 1);
	    vv_angles = v_angles(index{i,sortindex(j)}, 1);
	    
        bin = 0;
	H2 = zeros(B, 1);  
        KK = size(vv_magnit, 1);
	    for ang_lim = -pi+2*pi/B : 2*pi/B : pi
	        bin = bin + 1;
	        for k = 1 : KK
                if abs(ang_lim - (-pi+2*pi/B)) < 1e-6
                    if vv_angles(k) < ang_lim - pi/B
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin+B-1) = H2(bin+B-1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;
                    end
                    if vv_angles(k) < ang_lim
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin+1) = H2(bin+1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;     
                    end
                elseif abs(ang_lim - pi) < 1e-6
                    if vv_angles(k) < ang_lim - pi/B
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin-1) = H2(bin-1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;                          
                    end
                    if vv_angles(k) < ang_lim
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin-B+1) = H2(bin-B+1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;                        
                    end
                else
                    if vv_angles(k) < ang_lim - pi/B
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin-1) = H2(bin-1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;                        
                    end
                    if vv_angles(k) < ang_lim
                        H2(bin) = H2(bin) + vv_magnit(k)*(1 - (( vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B)));
                        H2(bin+1) = H2(bin+1) + vv_magnit(k)*(vv_angles(k)-(ang_lim-pi/B) )/(2*pi/B);
                        vv_angles(k) = 100;                           
                    end
                end
           end
        end
        H2 = H2 / (norm(H2)+1e-6);
	H((cont-1)*B+1:cont*B,1) = H2;
    end

end
