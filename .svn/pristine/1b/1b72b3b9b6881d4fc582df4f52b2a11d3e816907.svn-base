function [ length ] = fitness( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist )
length=0;
L1Result=TotalResult{1,1};
L2Result=TotalResult{1,2};

% L1
for i=1:size(L1Result)
    if size(L1Result{i,1},1)==0
        continue;
    end
    first=Center2SatDist(L1Result{i,1}(1,1));
    length=length+first;
    if size(L1Result{i,1},1)==1
        length=length+first;
    else
        for j=1:size(L1Result{i,1},1)-1
            length=length+Sat2SatDist(L1Result{i,1}(j,1),L1Result{i,1}(j+1,1));
        end
        length=length+Center2SatDist(L1Result{i,1}(size(L1Result{i,1},1)));
    end
end

%L2
for i=1:size(L2Result,1)
    for j=1:size(L2Result{i},1)
        if size(L2Result{i}{j},1)==0 || size(L2Result{i}{j},2)==0
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

