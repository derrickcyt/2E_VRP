function [ sourceIndex ] = chooseSource( Priority )
sourceIndex=1;
m=size(Priority,1);
limit=1000;
%cal boundary for per source in [0,1000]
Boundary=zeros(m,1);
start=0;
for i=1:m
    Boundary(i,1)=start+Priority(i,1)*limit;
    start=Boundary(i,1);
end
limit=Boundary(m,1);
die=rand()*limit;
sourceIndex=find(Boundary>die,1);


end

