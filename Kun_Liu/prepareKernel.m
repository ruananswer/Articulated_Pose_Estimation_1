function prepareKernel(binSize, order, vis)

clear global triKERNEL chKERNEL triKERNEL2

global triKERNEL chKERNEL triKERNEL2

if ~exist('binSize', 'var') || isempty(binSize),
    binSize = 6;
    vis = 1;
end

if ~exist('order', 'var') || isempty(order),
    order = 4;
end

if ~exist('vis', 'var') || isempty(vis),
    vis = 1;
end

% triangular kernel
[x,y] = meshgrid(-binSize+1:binSize-1,  -binSize+1:binSize-1);
z = complex(x,y);
triKERNEL = max(binSize - (abs(z)),0);
triKERNEL = triKERNEL / sum(abs(triKERNEL(:)));
if(vis)
    figure('Name','truangle kernel');
    imagesc(real(triKERNEL));axis equal off;
end

[x,y] = meshgrid(-binSize * 2+1:binSize * 2-1,  -binSize * 2+1:binSize * 2 -1);
z = complex(x,y);
triKERNEL2 = min(max(binSize * 2 - (abs(z)),0), binSize);
triKERNEL2 = triKERNEL2 / sum(abs(triKERNEL2(:)));
if(vis)
    figure('Name','triKERNEL2');
    imagesc(real(triKERNEL2));axis equal off;
end

% circular harmonics with radius = 1/2/3 * binSize
% triangular kernel width = sigma = binSize

Order = 0:order;
Scale = 1:3;
sigma = binSize;

if(vis)
    figure('Name','circular harmonic kernel');
    set(gcf, 'Color',[1,1,1]);
    HH = tight_subplot(numel(Order),numel(Scale) * 2,0.02,0.05,0.05);
end
for s = 1:numel(Scale)
    r = binSize * s;
    [x,y] = meshgrid(-r-sigma+1:r+sigma-1,  1-r-sigma:r+sigma-1);
    z = complex(x,y);
    phase_z = angle(z);
    
    for j = 1:numel(Order)
        kernel = max(sigma - abs(abs(z) - r), 0) .* exp(1i * phase_z * Order(j));
        kernel = kernel / sqrt(sum(abs(kernel(:)).^2));     %% make all the output value in same range
        if(vis)
            skernel = (pad(kernel,[150,150]) ./ max(real(kernel(:))) + 1+1i)/2;
            axes(HH(s*2+numel(Scale) * (j-1) * 2 - 1));imshow(pad(real(skernel), [150,150]));axis equal tight off;
            axes(HH(s*2+numel(Scale)* (j-1) * 2 ));imshow(pad(imag(skernel), [150,150]) );axis equal tight off;
        end
        chKERNEL{s,j} = kernel;
    end
end
