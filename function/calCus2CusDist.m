function [ Cus2CusDist ] = calCus2CusDist( CusPos )

Cus2CusDist=zeros(size(CusPos,1),size(CusPos,1));
Cus2CusDist(:,:)=+inf;
for i=1:size(CusPos,1)
   for j=1:size(CusPos,1)
       if i==j
          continue; 
       end
      x1=CusPos(i,1);y1=CusPos(i,2);
      x2=CusPos(j,1);y2=CusPos(j,2);
      Cus2CusDist(i,j)=sqrt((x1-x2).^2+(y1-y2).^2);
   end
end



end

