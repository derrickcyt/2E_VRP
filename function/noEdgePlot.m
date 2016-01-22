function [ status ] = noEdgePlot( CusPos,SatPos,CenterPos )


plot(CusPos(:,1),CusPos(:,2),'*');
hold on;
plot(SatPos(:,1),SatPos(:,2),'ro');
hold on;
plot(CenterPos(1),CenterPos(2),'md');


end

