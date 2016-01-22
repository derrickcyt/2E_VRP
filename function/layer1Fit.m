function [ length ] = layer1Fit( TotalResult,Center2SatDist,Sat2SatDist )
length=0;
L1Result=TotalResult{1,1};
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
end

