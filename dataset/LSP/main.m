joints = load('joints.mat');
im = imread('images/im0001.jpg');
imshow(im);
for i = 1: 14
    hold on;
    plot(joints.joints(1,i,1), joints.joints(2,i,1), 'r*');
end
hold off;