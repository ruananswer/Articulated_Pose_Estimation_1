function scaled = chooseScaled(image, radius, posY, posX)

[Y, X, K] = size(image); 
if K ~= 1
    scaled = uint8(zeros(2*radius+1, 2*radius+1, 3));
else
    scaled = uint8(zeros(2*radius+1, 2*radius+1));
end

sll = 1; suu = 1; srr = 2*radius+1; sdd = 2*radius+1;
ill = posX-radius; iuu = posY-radius; irr = posX+radius; idd = posY+radius;
if posY <= radius
    suu = radius - posY + 1;
    iuu = 1;
    idd = iuu + (2*radius-suu) + 1;
end
if posY >= Y-radius
    sdd = radius + Y - posY;
    idd = Y;
    iuu = posY - radius + 1;
end
if posX <= radius
    sll = radius - posX + 1;
    ill = 1;
    irr = ill + (2*radius-sll) + 1;
end
if posX >= X-radius
    srr = radius + X - posX;
    irr = X;
    ill = posX - radius + 1;
end

if posY < radius && posY >= Y - radius
    suu = radius - posY + 1;
    iuu = 1;
    sdd = radius + Y - posY;
    idd = Y;
end

if posX < radius && posX >= X - radius
    sll = radius - posX + 1;
    ill = 1;
    srr = radius + X - posX;
    irr = X;
end
if K ~= 1
    scaled(suu : sdd, sll : srr, :) = image(iuu : idd, ill : irr, :);
else
    scaled(suu : sdd, sll : srr) = image(iuu : idd, ill : irr);
end


end