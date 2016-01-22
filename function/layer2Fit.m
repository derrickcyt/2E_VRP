function [ length ] = layer2Fit( TotalResult,Cus2CusDist,Sat2CusDist )
length=0;
L2Result=TotalResult{1,2};
%L2
for i=1:size(L2Result,1)
    for j=1:size(L2Result{i},1)
        if size(L2Result{i}{j},1)==0
            continue;
        end
        first=Sat2CusDist(i,L2Result{i}{j}(1));
        length=length+first;
        if size(L2Result{i}{j},1)==1
            length=length+first;
        else
            for k=1:size(L2Result{i}{j},1)-1
                length=length+Cus2CusDist(L2Result{i}{j}(k),L2Result{i}{j}(k+1));
            end
            length=length+Sat2CusDist(i,L2Result{i}{j}(size(L2Result{i}{j},1)));
        end
        
    end
end
end