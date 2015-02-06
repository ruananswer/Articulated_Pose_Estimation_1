clear;clc;
dbstop if error;
globals;

% different dataset use different 

datasetNum = 2;

%% read data
if datasetNum == 1
    name = 'TUD210';
    cls = [name '_data'];
    if ~exist([cachedir 'imrotateTUD210/'],'dir')
        mkdir([cachedir 'imrotateTUD210/']);
    end
    if ~exist([cachedir 'imflipTUD210/'],'dir')
        mkdir([cachedir 'imflipTUD210/']);
    end
        
    TRAIN_NUM = 2;
% ---- read data    
    try
        xmlDoc = xmlread('train-210-annopoints.al');
        nameArray = xmlDoc.getElementsByTagName('name');
        nameContent = [];thisX = [];thisY = [];
        for i = 0 : nameArray.getLength-1
            nameContent(i+1).name = char(nameArray.item(i).getFirstChild.getData);
        end
    catch
        error('Failed to read XML file!');
    end
    
    try
        load('TUD210_label.mat');
    catch
        error('Failed to read LABEL file!');
    end
    
    try
        load([cachedir cls]);
    catch
        % tud data. Prepare training and testing data and part bounding boxes
        % training data for positive
        trainfrs_pos = 1:TRAIN_NUM;
        % testing data for positive
        testfrs_pos = TRAIN_NUM+1:100;
        % train data for neg
        trainfrs_neg = 1:11;       
        numpos = 0;
        pos = [];
        for fr = trainfrs_pos
            numpos = numpos + 1;
            pos(numpos).im = nameContent(fr).name;
            for j = 1:13
                temp(j,1) = thisX(fr,j);
                temp(j,2) = thisY(fr,j);
            end
            pos(numpos).point = temp;
        end

        % -------------------
        % rotate positive images by a small amount of degree
        degree = [-15 -7.5 7.5 15];
        posims_rotate = [cachedir 'imrotateTUD210/im%d_%d.png'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            for i = 1:length(degree)
                imwrite(imrotate(im, degree(i)),sprintf(posims_rotate,n,i));
            end
        end

        for n = 1:length(pos)
            im = imread(pos(n).im);
            for i = 1:length(degree)
                numpos = numpos + 1;
                pos(numpos).im = sprintf(posims_rotate,n,i);
                pos(numpos).point = map_rotate_points(pos(n).point,im,degree(i),'ori2new');
            end
        end

        % -------------------
        % flip positive training images
        posims_flip = [cachedir 'imflipTUD210/im%d.jpg'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
        end

        % -------------------
        % flip labels for the flipped positive training images
        % mirror property for the keypoint, please check your annotation for your own dataset
        mirror = [1 5 6 7 2 3 4 11 12 13 8 9 10];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            width = size(im,2);
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims_flip,n);
            pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
            pos(numpos).point(mirror,2) = pos(n).point(:,2);
        end

        %-----------------
        % grab negative image
        negims = 'train-210-neg/%.5d.png';
        neg = [];
        numneg = 0;
        for fr = trainfrs_neg
            numneg = numneg + 1;
            neg(numneg).im = sprintf(negims,fr);
        end

        %-----------------
        % grab testing image information
        numtest = 0;
        test = [];
        for fr = testfrs_pos
            numtest = numtest + 1;
            test(numtest).im = nameContent(fr).name;
            for j = 1:13
                temp(j,1) = thisX(fr,j);
                temp(j,2) = thisY(fr,j);
            end    
            test(numtest).point = temp;
        end

        save([cachedir cls],'pos','neg','test');
    end
       
elseif datasetNum == 2
    name = 'PARSE';
    cls = [name '_data'];
    if ~exist([cachedir 'imrotatePARSE/'],'dir')
        mkdir([cachedir 'imrotatePARSE/']);
    end
    if ~exist([cachedir 'imflipPARSE/'],'dir')
        mkdir([cachedir 'imflipPARSE/']);
    end
    
    try 
        load([cachedir cls]);
    catch
        trainfrs_pos = 1:100; % training frames for positive
        testfrs_pos = 101:305; % testing frames for positive
        trainfrs_neg = 615:1832; % training frames for negative 

        % -------------------
        % grab positive annotation and image information
        load PARSE/labels.mat;
        posims = 'PARSE/im%.4d.jpg';
        pos = [];
        numpos = 0;
        for fr = trainfrs_pos
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims,fr);
            pos(numpos).point = ptsAll(:,:,fr);
        end

        % -------------------
        % rotate positive images by a small amount of degree
        %{
        degree = [-15 -7.5 7.5 15];
        posims_rotate = [cachedir 'imrotatePARSE/im%.4d_%d.jpg'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            for i = 1:length(degree)
                imwrite(imrotate(im,degree(i)),sprintf(posims_rotate,n,i));
            end
        end

        for n = 1:length(pos)
            im = imread(pos(n).im);
            for i = 1:length(degree)
                numpos = numpos + 1;
                pos(numpos).im = sprintf(posims_rotate,n,i);
                pos(numpos).point = map_rotate_points(pos(n).point,im,degree(i),'ori2new');
            end
        end
        %}
        
        % -------------------
        % flip positive training images
        posims_flip = [cachedir 'imflipPARSE/im%.4d.jpg'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
        end

        % -------------------
        % flip labels for the flipped positive training images
        % mirror property for the keypoint, please check your annotation for your own dataset
        mirror = [6 5 4 3 2 1 12 11 10 9 8 7 13 14];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            width = size(im,2);
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims_flip,n);
            pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
            pos(numpos).point(mirror,2) = pos(n).point(:,2);
        end

        % --------
        % create 13 keypoints
        I = [1   1   2 3 4 5 6 7  8  9  10 11 12 13];
        J = [14 13   9 8 7 3 2 1 10 11  12  4  5  6];
        A = [1/2 1/2 1 1 1 1 1 1  1  1   1  1  1  1];
        Trans = full(sparse(I, J, A, 13, 14));
        for i = 1:length(pos)
            pos(i).point = Trans * pos(i).point;
        end
        % -------------------
        % grab neagtive image information
        negims = 'INRIA/%.5d.jpg';
        neg = [];
        numneg = 0;
        for fr = trainfrs_neg
            numneg = numneg + 1;
            neg(numneg).im = sprintf(negims,fr);
        end

        % -------------------
        % grab testing image information 
        testims = 'PARSE/im%.4d.jpg';
        test = [];
        numtest = 0;
        for fr = testfrs_pos
            numtest = numtest + 1;
            test(numtest).im = sprintf(testims,fr);
            test(numtest).point = ptsAll(:,:,fr);
        end

        for i = 1:length(test)
            test(i).point = Trans * test(i).point;
        end  

        save([cachedir cls],'pos','neg','test');
    end
               
elseif datasetNum == 3
    name = 'BUFFY';
    cls = [name '_data'];
    if ~exist([cachedir 'imrotateBUFFY/'],'dir')
        mkdir([cachedir 'imrotateBUFFY/']);
    end
    if ~exist([cachedir 'imflipBUFFY/'],'dir')
        mkdir([cachedir 'imflipBUFFY/']);
    end
    
    try
        load([cachedir cls]);
    catch
        posanno   = 'BUFFY/data/buffy_s5e%d_sticks.txt';
        posims    = 'BUFFY/images/buffy_s5e%d_original/%.6d.jpg';
        labelfile = 'BUFFY/labels/buffy_s5e%d_labels.mat';   
        trainepi = [3 4];   % training episodes
        testepi  = [2 5 6]; % testing  episodes
        trainfrs_neg = 615:1832;  % training frames for negative
        
        % -------------------
        % grab positive annotation and image information
        pos = [];
        numpos = 0;
        for e = trainepi
            lf = ReadStickmenAnnotationTxt(sprintf(posanno,e));
            load(sprintf(labelfile,e));
            for n = 1:length(lf)
                numpos = numpos + 1;
                pos(numpos).im = sprintf(posims,e,lf(n).frame);
                pos(numpos).point = labels(:,:,n);
            end
        end

        % -------------------
        % flip positive training images
        posims_flip = [cachedir 'imflipBUFFY/BUFFY%.6d.jpg'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
        end

        % -------------------
        % flip labels for the flipped positive training images
        % mirror property for the keypoint, please check your annotation for your
        % own dataset
        mirror = [1 2 5 6 3 4 8 7 10 9]; % for flipping original data
        for n = 1:length(pos)
            im = imread(pos(n).im);
            width = size(im,2);
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims_flip,n);
            pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
            pos(numpos).point(mirror,2) = pos(n).point(:,2);
        end
               
        % -------------------
        % grab neagtive image information
        negims = 'INRIA/%.5d.jpg';
        neg = [];
        numneg = 0;
        for fr = trainfrs_neg
            numneg = numneg + 1;
            neg(numneg).im = sprintf(negims,fr);
        end
  
        % -------------------
        % grab testing image information
        test = [];
        numtest = 0;
        for e = testepi
            lf = ReadStickmenAnnotationTxt(sprintf(posanno,e));
            load(sprintf(labelfile,e));
            for n = 1:length(lf)
                numtest = numtest + 1;
                test(numtest).epi = e;
                test(numtest).frame = lf(n).frame;
                test(numtest).im = sprintf(posims,e,lf(n).frame);
                test(numtest).point = labels(:,:,n);
            end
        end

        save([cachedir cls],'pos','neg','test');   
    end
    
else
    name = 'LSP';
    cls = [name '_data'];
    if ~exist([cachedir 'imrotateLSP/'], 'dir')
        mkdir([cachedir 'imrotateLSP/']);
    end
    if ~exist([cachedir 'imflipLSP/'], 'dir')
        mkdir([cachedir 'imflipLSP/']);
    end

    try 
        xmlDoc = xmlread('dpm-neg.al');
        nameArray = xmlDoc.getElementsByTagName('name');
        nameContent = []; thisX = []; thisY = [];
        for i = 0 : nameArray.getLength-1
            nameContent(i+1).name = char(nameArray.item(i).getFirstChild.getData);
        end
    catch
        error('Failed to read al File!');
    end
     
    try 
        load('joints.mat');
    catch
        error('Failed to read joints file!');
    end
       
    try
        load([cachedir cls]);
    catch
        trainfrs_pos = 1:1500;
        testfrs_pos = 1501:2000;
        
        % ----------------------------
        % positive annotation and image information
        posims = 'LSP/images/im%.4d.jpg';
        pos = [];
        numpos = 0;
        for fr = trainfrs_pos
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims, fr);
            pos(numpos).point = joints(1:2,1:14,fr);
        end        
        % flip positive training images
        posims_flip = [cachedir 'imflipLSP/im%.4d.jpg'];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            imwrite(im(:, end:-1:1, :),sprintf(posims_flip, n));
        end
        mirror = [6 5 4 3 2 1 12 11 10 9 8 7 13 14];
        for n = 1:length(pos)
            im = imread(pos(n).im);
            width = size(im,2);
            numpos = numpos + 1;
            pos(numpos).im = sprintf(posims_flip,n);
            pos(numpos).point(1, mirror) = width - pos(n).point(1,:) + 1;
            pos(numpos).point(2, mirror) = pos(n).point(2,:);
        end
        
        % --------
        % create 13 keypoints
        I = [1   1   2 3 4 5 6 7  8  9  10 11 12 13];
        J = [14 13   9 8 7 3 2 1 10 11  12  4  5  6];
        A = [1/2 1/2 1 1 1 1 1 1  1  1   1  1  1  1];
        Trans = full(sparse(I, J, A, 13, 14));
        for i = 1:length(pos)
            pos(i).point = Trans * pos(i).point';
        end   
        
        % ------------------------
        % negative image information
        for i = 1:length(nameContent)
            neg(i).im = nameContent(i).name;
        end
          
        % -------------------------
        % testing image information
        testims = 'LSP/images/im%.4d.jpg';
        test = [];
        numtest = 0;
        for fr = testfrs_pos
            numtest = numtest + 1;
            test(numtest).im = sprintf(testims,fr);
            test(numtest).point = joints(1:2,1:14,fr);
        end

        for i = 1:length(test)
            test(i).point = Trans * test(i).point';
        end  

        save([cachedir cls],'pos','neg','test');        
        
    end
end
%% train data
if datasetNum == 1
    % ---------------------------------------
    % specify model parameters number of mixtures for 13 parts
    K = [6 6 6 6 6 6 6 6 6 6 6 6 6];
    pa = [0 1 2 3 1 5 6 2 8 9 5 11 12];
    sbin = 4;
    % -----------------
    % train model
    pos = point2box(pos, pa);    
    model = trainmodel(name, pos, neg, K, pa, sbin);
elseif datasetNum == 2 || datasetNum == 4
    % ---------------------------------------
    % specify model parameters number of mixtures for 13 parts
    K = [6 6 6 6 6 6 6 6 6 6 6 6 6];
    pa = [0 1 2 3 2 5 6 1 8 9 8 11 12];
    sbin = 4;
    % -----------------
    % train model
    pos = point2box(pos, pa);    
    model = trainmodel(name, pos, neg, K, pa, sbin); 
elseif datasetNum == 3
    K = [6 6 6 6 6 6 6 6 6 6]; 
    pa = [0 1 2 3 2 5 4 6 3 5]; 
    sbin = 4;
    pos = point2box(pos,pa);
    % training
    model = trainmodel(name,pos,neg,K,pa,sbin);    
end


%% test & eval data    
% --------------------
% testing phase 1
% human detection + pose estimation
suffix = num2str(K);
model.thresh = min(model.thresh,-2);
boxes = testmodel(name,model,test,suffix);
det = transback(boxes);   

if datasetNum == 1 || datasetNum == 2 || datasetNum == 4
    colorset = {'r','m','g','c','b','w','y','r','m','g','c','b','w'};
    apk = eval_apk(det, test, 0.1);
    meanapk = mean(apk);
    %for 13 parts
    result = [apk(1,1) apk(1,2) mean([apk(1,2) apk(1,3)]) mean([apk(1,3) apk(1,4)]) apk(1,5) mean([apk(1,5) apk(1,6)]) mean([apk(1,6) apk(1,7)])...
        1 mean([apk(1,8) apk(1,9)]) mean([apk(1,9) apk(1,10)]) mean([apk(1,11) apk(1,12)]) mean([apk(1,12) apk(1,13)])];
    fprintf('mean APK = %.1f\n',meanapk*100);
    fprintf('Keypoints & Head & RShou & URArm & LRArm & LShou & ULArm & LLArm & Torso & URLeg & LRLeg & ULLeg & LLLeg\n');
    fprintf('APK       '); fprintf('& %.1f ',result*100); fprintf('\n');    
elseif datasetNum == 3
    colorset = {'r','m','g','c','b','w','y','r','m','g'};    
    apk = eval_apk(det, test, 0.1);
    meanapk = mean(apk);
end

%% visual data sample
if datasetNum == 1 || datasetNum == 2 || datasetNum == 3
    for demoimid = 1:size(test,2)
        im = imread(test(1,demoimid).im);
        showboxes(im, boxes{demoimid}, colorset);
        pause();
        %showskeletons(im, boxes{demoimid}, colorset, model.pa);
        %{         
        figure(demoimid);
        imshow(im);
        for j = 1:13
            hold on;
            plot(det(1,demoimid).point(j,1,1), det(1,demoimid).point(j,2,1), 'r*');
        end
        hold off;
        %}
        %pause();
        close;
    end
else
end