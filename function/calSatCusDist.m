function [ SatCusDist ] = calSatCusDist( SatPos,CusPos )
SatCusDist=zeros(size(SatPos,1),size(CusPos,1));
SatCusDist(:,:)=+inf;
for i=1:size(SatPos,1)
   for j=1:size(CusPos,1)
       SatCusDist(i,j)=sqrt((SatPos(i,1)-CusPos(j,1)).^2+(SatPos(i,2)-CusPos(j,2)).^2);
   end
end
end

