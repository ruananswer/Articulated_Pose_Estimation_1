function [boxes score] = voted(tempboxes,degree,im)
% voted the most possible pose

numparts = 13;
%figure(1);
%imshow(im);
count = 1;
%weight = [];
pos = [];
wei = [];
score = 0.0;
posrotaim_write = ['cache/imwriterota/im_%d.jpg'];

for i = 1:length(tempboxes)
    temp = tempboxes{i};

    box = temp(:,1:4*numparts);
    xy = reshape(box,size(box,1),4,numparts);
    xy = permute(xy,[1 3 2]);
    for j = 1:size(temp,1)
        %weight(1,j) = temp(j,4*numparts+2);  
        %if temp(j,54) <= 0 
        %    continue;
        %end
        wei(count,1) = temp(j,54);
        score = score + wei(count,1);
        tp = [];
        for k = 1:numparts
            tp(k,1) = (xy(j,k,1) + xy(j,k,3))/2;
            tp(k,2) = (xy(j,k,2) + xy(j,k,4))/2;          
        end
        tp = map_rotate_points(tp, im, degree(i),'new2ori');
        
        for ii = 1:size(tp,1)
            for jj = 1:size(tp,2)
                pos(count, ii, jj) = tp(ii,jj);
            end
        end
%%  show rotate image and point        
%{
        figure(i);
        imshow(im);
        for kk = 1:numparts
            hold on;
            plot(tp(kk,1), tp(kk,2),'r*');
        end
        hold off;
        saveas(gcf,sprintf(posrotaim_write,i));
        close;
        
%}
        
        count = count + 1;
    end
end
score = score/count;

%% voted  
%pos -> boxes   x:13:2    13:2

areasize = 10;

for j = 1:numparts
    for i = 1:size(pos,1)
        tempx(i,1) = pos(i,j,1);
        tempy(i,1) = pos(i,j,2);
    end
    sort(tempx);sort(tempy);
    
    max = -100.0;
    ansx = 0.0;
    ansy = 0.0;
    for ii = 1:size(tempx,1)
        for jj = 1:size(tempy,1)
            tpx = 0;
            tpy = 0;
            weisum = 0;
            count = 0;
            for kk = 1:size(pos,1)
                if (pos(kk,j,1)>=tempx(ii,1) && pos(kk,j,1)<=(tempx(ii,1)+areasize) && pos(kk,j,2)>=tempy(jj,1) && pos(kk,j,2)<=(tempy(jj,1)+areasize))
                    count = count + 1;
                    tpx = tpx + pos(kk,j,1)*wei(kk,1);
                    tpy = tpy + pos(kk,j,2)*wei(kk,1);
                    weisum = weisum + wei(kk,1);
                end
            end
            if weisum > max 
                max = weisum;
                ansx = tpx/weisum;
                ansy = tpy/weisum;
            end
        end
    end
    
    boxes(j,1) = ansx;
    boxes(j,2) = ansy;
end   

end