function maskCircle = inCircle(Center, Radius, index, circleThreshold)
    circlecnt = 0;
    maskCircle = [];
    for m = -Radius(index+1) + Center(1)  : Radius(index+1) + Center(1)
        for n = -Radius(index+1) + Center(2)  : Radius(index+1) + Center(2)
            if index == 1
                if ((m-Center(1))*(m-Center(1)) + (n-Center(2))*(n-Center(2))) < Radius(index+1)*Radius(index+1)
                    circlecnt = circlecnt + 1;
                    maskCircle(circlecnt, 1) = m;
                    maskCircle(circlecnt, 2) = n;
                end             
            else
                if (m-Center(1))*(m-Center(1)) + (n-Center(2))*(n-Center(2)) < Radius(index+1)*Radius(index+1) &&  ...
               (m-Center(1))*(m-Center(1)) + (n-Center(2))*(n-Center(2)) >= (Radius(index)-circleThreshold)*(Radius(index)-circleThreshold)
                    circlecnt = circlecnt + 1;
                    maskCircle(circlecnt, 1) = m;
                    maskCircle(circlecnt, 2) = n;
                end
            end            
        end
    end
    maskCircle = int32(maskCircle);
end
