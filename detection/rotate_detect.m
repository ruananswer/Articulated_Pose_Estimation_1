function det = rotate_detect(name, model, test, degree, colorset)
%ROTATE_DETECT Summary of this function goes here
%   Return candidate bounding boxes after the voted by rotate image

globals;

try
    load([cachedir name '_boxes_after_rotate']);
catch
    %boxes = cell(1,length(test));
    det = struct('point',cell(1,length(test)),'score',cell(1,length(test)));
    for i = 1:size(test,2)
        tempboxes = cell(1,length(degree)); 
        
        for j = 1:length(degree)
            fprintf([name 'testing: %d image rotate %d\n'],i,degree(j));              
            im = imread(test(i).im);    
            im = imrotate(im, degree(j));
            box = detect_fast(im, model, model.thresh);
            tempboxes{j} = nms(box, .1);
        end

         [boxes score] = voted(tempboxes,degree,imread(test(i).im));
         det(i).point = boxes;
         det(i).score = score;
%{
         figure(1);
         imshow(test(i).im);
         for kk = 1:13
            hold on;
            plot(boxes(kk,1), boxes(kk,2),'r*');
         end
         hold off;
%}
    end
     save([cachedir name '_boxes_after_rotate'], 'det', 'model');
end
