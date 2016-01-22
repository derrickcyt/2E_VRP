function [ Sat2SatDist ] = calSat2SatDist( SatPos )
Sat2SatDist=zeros(size(SatPos,1),size(SatPos,1));
Sat2SatDist(:,:)=+inf;
for i=1:size(SatPos,1)
    for j=1:size(SatPos,1)
        if i==j
            continue;
        end
       Sat2SatDist(i,j)=sqrt((SatPos(j,1)-SatPos(i,1)).^2+(SatPos(j,2)-SatPos(i,2)).^2); 
    end
end
end

