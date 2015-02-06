function boxes = testmodel(name,model,test,suffix)
% boxes = testmodel(name,model,test,suffix)
% Returns candidate bounding boxes after non-maximum suppression

globals;
rmpath(genpath('/home/ruan/comman/lib/vlfeat-0.9.18'));

try
  load([cachedir name '_boxes_' suffix]);
catch
  % ------
  % add feature param to model
  model.imageSize = [28, 28];
  model.bbRadius = 14;
  model.testRadius = [0; 4; 8; 12; 14];
  model.Bin = 15;
  model.maskCircle = [];
  model.partNum = 4000;
  model.circleThreshold = 0;
  model.featureScale = 11;
  model.NMS_OV  = 0.5;  
  model.indifferenceRadius = 20;
  model.negSample = 100;
  initrand();
  prepareKernel(model.featureScale, 12, 0);
  Center = ceil(model.imageSize/2);
  for  i = 1 : size(model.testRadius, 1) - 1
      model.maskCircle{i} = inCircle(Center, model.testRadius, i, model.circleThreshold);
  end
  model.featureDimen = 0;
  for i = 1 : size(model.testRadius, 1) - 1
      model.featureDimen = model.featureDimen + max(1, floor(size(model.maskCircle{i}, 1)/model.partNum));
  end
  model.featureDimen = model.featureDimen * model.Bin + 1693; 
  
    % ---------------
    % load rotation invariant model to change the detect score
    load modelR.mat;
    load modelNeg.mat;
    addpath(genpath('/home/ruan/comman/lib/liblinear-1.96'));  

  boxes = cell(1,length(test));
  for i = 1:length(test)
    fprintf([name ': testing: %d/%d\n'],i,length(test));
    im = imread(test(i).im);
    box = detect_fast(im,model,model.thresh, modelR, modelNeg);
    boxes{i} = nms(box,0.3);
  end

  if nargin < 4
    suffix = [];
  end
  save([cachedir name '_boxes_' suffix], 'boxes','model');
end