function dataxy = showskeletons(im, boxes, partcolor, parent)

imagesc(im); axis image; axis off; hold on;
if ~isempty(boxes)
  numparts = length(partcolor);
  box = boxes(:,1:4*numparts);
  xy = reshape(box,size(box,1),4,numparts);
  xy = permute(xy,[1 3 2]);
  for n = 1:size(xy,1)
    x1 = xy(n,:,1); y1 = xy(n,:,2); x2 = xy(n,:,3); y2 = xy(n,:,4);
    x = (x1+x2)/2; y = (y1+y2)/2;
    xy1(1,1) = x(parent(2));
    xy1(2,1) = y(parent(2));
    for child = 2:numparts
      x1 = x(parent(child));
      y1 = y(parent(child));
      x2 = x(child);
      y2 = y(child);
      xy1(1,child) = x(child);
      xy1(2,child) = y(child);
      line([x1 x2],[y1 y2],'color',partcolor{child},'linewidth',3);
    end
  end
  %translate skelton
    dataxy(1,1) =  (xy1(1,9) + xy1(1,21))/2; %(4*xy1(1,9) + xy1(1,8) + 4*xy1(1,21) + xy1(1,20))/5;
    dataxy(2,1) =  (xy1(2,9) + xy1(2,21))/2; %(4*xy1(2,9) + xy1(2,8) + 4*xy1(2,21) + xy1(2,20))/5;

%----  R.leg
    dataxy(1,2) = xy1(1,10); %(xy1(1,10) + xy1(1,11))/2;
    dataxy(2,2) = xy1(2,10); %(xy1(2,10) + xy1(2,11))/2;
    
    dataxy(1,3) = xy1(1,12);
    dataxy(2,3) = xy1(2,12);
    
    dataxy(1,4) = xy1(1,14);
    dataxy(2,4) = xy1(2,14); 
%----  

%----  l.leg 
    dataxy(1,5) = xy1(1,22); %(xy1(1,22) + xy1(1,23))/2;
    dataxy(2,5) = xy1(2,22); %(xy1(2,22) + xy1(2,23))/2;
    
    dataxy(1,6) = xy1(1,24);
    dataxy(2,6) = xy1(2,24);
    
    dataxy(1,7) = xy1(1,26);
    dataxy(2,7) = xy1(2,26); 
%----    
    dataxy(1,8) = xy1(1,2); %(xy1(1,2) + xy1(1,3) + xy1(1,15))/3;
    dataxy(2,8) = xy1(2,2); %(xy1(2,2) + xy1(2,3) + xy1(2,15))/3;
  
    dataxy(1,9) = xy1(1,1);
    dataxy(2,9) = xy1(2,1);    

%---- r.arm 
    
    dataxy(1,10) = (4*xy1(1,3) + xy1(1,2))/5;
    dataxy(2,10) = (4*xy1(2,3) + xy1(2,2))/5;
    
    dataxy(1,11) = xy1(1,5);
    dataxy(2,11) = xy1(2,5);
    
    dataxy(1,12) = xy1(1,7);
    dataxy(2,12) = xy1(2,7);      
%----    

%---- L.arm
    
    dataxy(1,13) = (4*xy1(1,15) + xy1(1,2))/5;
    dataxy(2,13) = (4*xy1(2,15) + xy1(2,2))/5;
    
    dataxy(1,14) = xy1(1,17);
    dataxy(2,14) = xy1(2,17);
    
    dataxy(1,15) = xy1(1,19);
    dataxy(2,15) = xy1(2,19);    
    
%----    
    %save(strcat('data/example0',strcat(num2str(i-1),'.mat')), 'im', 'dataxy');
  
end
drawnow;