clear;clc;
globals;

name  = 'TUD210';
try
    xmlDoc = xmlread('train-210-annopoints.al');
catch
    error('Failed to read XML file!');
end
nameArray = xmlDoc.getElementsByTagName('name');
nameContent = [];
thisX = [];
thisY = [];

for i = 0 : nameArray.getLength-1
    nameContent(i+1).name = char(nameArray.item(i).getFirstChild.getData);
end

% load the labeled data
load([cachedir name '_label']);    

for i = size(thisX,1):size(thisX,1)+21
    img = imread(nameContent(i+1).name);
    figure(1);
    imshow(img);
    for j = 1:13
        hold on;    
        [pt(1,1) pt(1,2)]=ginput(1);
        %pt = get(gca,'CurrentPoint');
        thisX(i+1,j) = pt(1,1);
        thisY(i+1,j) = pt(1,2);
        plot(pt(1,1),pt(1,2),'r*');
        pause(.2);
    end
    close;
end

cls = [name '_label'];
save([cachedir cls], 'thisX','thisY');