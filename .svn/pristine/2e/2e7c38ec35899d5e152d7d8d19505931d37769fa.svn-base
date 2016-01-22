function [ length ] = satFit( InputResult,satId,Cus2CusDist,Sat2CusDist )
length=0;
L2Result=InputResult{1,2};
%L2

for pathId=1:size(L2Result{satId},1)
    if size(L2Result{satId}{pathId},1)==0 || size(L2Result{satId}{pathId},2)==0
        continue;
    end
    first=Sat2CusDist(satId,L2Result{satId}{pathId}(1));
    length=length+first;
    if size(L2Result{satId}{pathId},1)==1
        length=length+first;
    else
        for k=1:size(L2Result{satId}{pathId},1)-1
            length=length+Cus2CusDist(L2Result{satId}{pathId}(k),L2Result{satId}{pathId}(k+1));
        end
        length=length+Sat2CusDist(satId,L2Result{satId}{pathId}(size(L2Result{satId}{pathId},1)));
    end
end
end

