function [ ifOverload ] = checkResultIfOverload( Result,Demand,QUESTIONOpts )
ifOverload=0;
for i=1:size(Result{1,2},1)
    for j=1:size(Result{1,2}{i,1},1)
        if size(Result{1,2}{i,1}{j,1},1)==0
            continue;
        end
        load=0;
        for k=1:size(Result{1,2}{i,1}{j,1},1)
           load=load+Demand(Result{1,2}{i,1}{j,1}(k,1)); 
        end
        if load>QUESTIONOpts.L2Capacity
            ifOverload=1;
            return;
        end
    end
end
end

