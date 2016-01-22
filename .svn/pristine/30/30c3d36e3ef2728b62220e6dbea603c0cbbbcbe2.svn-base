function [ minPath ] = PathInnerOperator( Path,satId,Cus2CusDist,Sat2CusDist,times )
minFit=calPathFit(Path,satId,Cus2CusDist,Sat2CusDist);
minPath=Path;
length=size(Path,1);
if length==1
    return;
end
%try k cus
for i=1:times
    Temp=minPath;
    index=randi([1,length],1,1);
    cusId=Temp(index);
    %1.remove from path
    Temp(index)=[];
    %2.try every pos
    for pos=1:length
        TTemp=Temp;
        TTemp=[TTemp(1:pos-1);cusId;TTemp(pos:end)];
        fit=calPathFit(Path,satId,Cus2CusDist,Sat2CusDist);
        if fit<minFit
            minFit=fit;
            minPath=TTemp;
        end
    end
end
end

function [fit]=calPathFit(Path,satId,Cus2CusDist,Sat2CusDist)
length=size(Path,1);
first=Sat2CusDist(satId,Path(1));
fit=first;
if length==1
    fit=fit+first;
else
    for i=1:length-1
        fit=fit+Cus2CusDist(Path(i),Path(i+1));
    end
    fit=fit+Sat2CusDist(satId,Path(length));
end

end