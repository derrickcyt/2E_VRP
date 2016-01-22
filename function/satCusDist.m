function SatCusDist = satCusDist(CusPos,Nearest,OneSatPos,OneSatIndex )
    SatCusDist=zeros(size(CusPos,1),2);
    num=0;
    for i=1:size(CusPos,1)
       if Nearest(i)==OneSatIndex
           num=num+1;
           SatCusDist(num,:)=[i,sqrt((OneSatPos(1)-CusPos(i,1)).^2+(OneSatPos(2)-CusPos(i,2)).^2)];
       end
    end
    SatCusDist=SatCusDist(1:num,1:2);
end
