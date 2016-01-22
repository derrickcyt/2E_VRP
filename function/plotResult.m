function [ statu ] = plotResult( TotalResult,CusPos,SatPos,CenterPos )

L1Result=TotalResult{1,1};
L2Result=TotalResult{1,2};

for i=1:size(L1Result)
    X=[CenterPos(1)];Y=[CenterPos(2)];
    for j=1:size(L1Result{i,1})
        X=[X;SatPos(L1Result{i,1}(j),1)];
        Y=[Y;SatPos(L1Result{i,1}(j),2)];
    end
    X=[X;CenterPos(1)];Y=[Y;CenterPos(2)];
    plot(X,Y,'r-');
    hold on;
end

for i=1:size(L2Result)
    for j=1:size(L2Result{i})
        X=[SatPos(i,1)];Y=[SatPos(i,2)];
        for k=1:size(L2Result{i}{j},1)
            X=[X;CusPos(L2Result{i}{j}(k),1)];
            Y=[Y;CusPos(L2Result{i}{j}(k),2)];
        end
        X=[X;SatPos(i,1)];Y=[Y;SatPos(i,2)];
        plot(X,Y,'b-');
        hold on;
    end
end
plot(CusPos(:,1),CusPos(:,2),'.','MarkerSize',15);
hold on;
plot(SatPos(:,1),SatPos(:,2),'rp','MarkerSize',15);
hold on;
plot(CenterPos(1),CenterPos(2),'ms','MarkerSize',15);




end

