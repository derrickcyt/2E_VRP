function dividedResult = angleDivide(SatCusPos,SatPos,num)
%divide customers according to degree.
    angle=0:360/num:360;
    dividedResult=zeros(size(SatCusPos,1),2);
    for i=1:size(SatCusPos,1)
        x=SatCusPos(i,2)-SatPos(1);
        y=SatCusPos(i,3)-SatPos(2);
        if x==0 && y==0
            dividedResult(i,:)=[SatCusPos(i,1),1];
        else
            d=getDegree(x,y);
            for j=1:num
                if d>=angle(j) && d<angle(j+1)
                    dividedResult(i,:)=[SatCusPos(i,1),j];
                    break;
                end
            end

        end
    end
    



end

