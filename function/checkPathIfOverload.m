function [ ifOverload ] = checkPathIfOverload( Path,Demand,limit )
ifOverload=0;
load=0;
for i=1:size(Path,1)
    load=load+Demand(Path(i));
end
if load>limit
   ifOverload=1;
end

end

