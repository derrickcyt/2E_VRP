function [ L1Neighbor ] = layer1NeighborOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,iterateNum,QUESTIONOpts )
L1Neighbor=TotalResult;
SatLoad=TotalResult{1,4}; %unchangable
NodePath=zeros(size(TotalResult{1,1},1),3); %1:satId 2:pathId 3:load
PathLoad=zeros(QUESTIONOpts.L1Fleet,1); %index:pathId 1:load
pathNum=0; %amount of paths
nodeNum=0; %total amount of nodes in all paths
if size(TotalResult{1,1},1)<QUESTIONOpts.L1Fleet
    for i=size(TotalResult{1,1},1)+1:QUESTIONOpts.L1Fleet
        TotalResult{1,1}{i,1}=[];
    end
end
for i=1:QUESTIONOpts.L1Fleet
    if i>size(TotalResult{1,1},1)
        PathLoad(i,1)=0;
    else
        if size(TotalResult{1,1}{i,1},1)~=0
            pathNum=pathNum+1;
            for j=1:size(TotalResult{1,1}{i,1},1)
                nodeNum=nodeNum+1;
                NodePath(nodeNum,:)=[TotalResult{1,1}{i,1}(j,1),i,TotalResult{1,1}{i,1}(j,2)];
                PathLoad(i,1)=PathLoad(i,1)+TotalResult{1,1}{i,1}(j,2);
            end
        else
            PathLoad(i,1)=0;
        end
    end
end
NodePath=NodePath(1:nodeNum,:);
%randomly choose some node to move
moveNum=2;
if nodeNum==moveNum
    moveNum=floor(nodeNum/2);
end

MoveNodes=NodePath(randperm(size(NodePath,1),moveNum),:);
%move from paths
for i=1:size(MoveNodes,1)
    tempPath=L1Neighbor{1,1}{MoveNodes(i,2),1};
    tempPath(find(tempPath==MoveNodes(i,1),1),:)=[]; % delete from the source path
    L1Neighbor{1,1}{MoveNodes(i,2),1}=tempPath;
    PathLoad(MoveNodes(i,2),1)=PathLoad(MoveNodes(i,2),1)-MoveNodes(i,3); %minus the load from moved node
end
%find moved nodes from same sat and merge their load
MoveSatLoad=zeros(moveNum,2);
distinctSatNum=0;
for i=1:moveNum
    index=find(MoveSatLoad(:,1)==MoveNodes(i,1)); %find the same sat in the MoveSatLoad set. If found, merge them, if not ,new one.
    if size(index,1)>0
        MoveSatLoad(index,:)=[MoveNodes(i,1),MoveSatLoad(index,2)+MoveNodes(i,3)];
    else
        distinctSatNum=distinctSatNum+1; % as index
        MoveSatLoad(distinctSatNum,:)=MoveNodes(i,[1,3]);%1:satId 2:load
    end
end
MoveSatLoad=MoveSatLoad(1:distinctSatNum,:);
%randomly choose a moved sat to insert into a path and greedy select a
%best result
while size(MoveSatLoad,1)>0
    index=randi([1,size(MoveSatLoad,1)],1,1);
    MovedSatItem=MoveSatLoad(index,:); % 1:satId 2:load
    %check if the node is overloaded
    if MovedSatItem(1,2)<=QUESTIONOpts.L1Capacity
        minFit=+inf;minNeighbor=L1Neighbor;minPathId=0;
        for i=1:QUESTIONOpts.L1Fleet
            if i>size(L1Neighbor{1,1},1)
                Temp=L1Neighbor;
                Temp{1,1}{i,1}=[MovedSatItem(1,:)]; % a new path
                tempFit=layer1Fit( Temp,Center2SatDist,Sat2SatDist );
                if tempFit<minFit
                    minPathId=i;
                    minFit=tempFit;
                    minNeighbor=Temp;
                end
                break;
            end
            %check if this path can add this node
            if QUESTIONOpts.L1Capacity-PathLoad(i,1)<MovedSatItem(1,2)
                continue;
            end
            %check if there is the same cus in this path
            if size(L1Neighbor{1,1}{i,1},1)>0
                sameCusIndex=find(L1Neighbor{1,1}{i,1}(:,1)==MovedSatItem(1,1));
                if size(sameCusIndex,1)>0
                    %insert into this path. just add the load to the same sat
                    Temp=L1Neighbor;
                    Temp{1,1}{i,1}(sameCusIndex(1,1),2)=Temp{1,1}{i,1}(sameCusIndex(1,1),2)+MovedSatItem(1,2);
                    minPathId=i;
                    minFit=layer1Fit( Temp,Center2SatDist,Sat2SatDist );
                    minNeighbor=Temp;
                    break;
                end
            end
            
            if size(L1Neighbor{1,1}{i,1},1)==0
                Temp=L1Neighbor;
                Temp{1,1}{i,1}=[MovedSatItem(1,:)]; % a new path         
                tempFit=layer1Fit( Temp,Center2SatDist,Sat2SatDist );
                if tempFit<minFit
                    minPathId=i;
                    minFit=tempFit;
                    minNeighbor=Temp;
                end
            else
                for j=1:size(L1Neighbor{1,1}{i,1},1)+1
                    Temp=L1Neighbor;
                    if j==1
                        Temp{1,1}{i,1}=[MovedSatItem(1,:);Temp{1,1}{i,1}];
                    elseif j==size(L1Neighbor{1,1}{i,1},1)+1
                        Temp{1,1}{i,1}=[Temp{1,1}{i,1};MovedSatItem(1,:)];
                    else
                        Temp{1,1}{i,1}=[Temp{1,1}{i,1}(1:j-1,:);MovedSatItem(1,:);Temp{1,1}{i,1}(j:end,:)];
                    end
                    tempFit=layer1Fit( Temp,Center2SatDist,Sat2SatDist );
                    if tempFit<minFit
                        minPathId=i;
                        minFit=tempFit;
                        minNeighbor=Temp;
                    end
                end
            end
        end
        if minPathId==0
            %try again
            L1Neighbor=layer1NeighborOperator( TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,iterateNum,QUESTIONOpts );
            return;
        end
        %move the node from MoveSatLoad
        PathLoad(minPathId,1)=PathLoad(minPathId,1)+MovedSatItem(1,2);
        MoveSatLoad(index,:)=[];
        L1Neighbor=minNeighbor;
    else
        %if overload, try insert 2paths
        minFit=+inf;minNeighbor=L1Neighbor;minPath1=0;minPath2=0;minPath2Load=+inf;
        for i=1:QUESTIONOpts.L1Fleet
            nodeLoad=MovedSatItem(1,2);
            Temp=L1Neighbor;
            %first path
            if i>size(L1Neighbor{1,1},1)
                Temp{1,1}{i,1}=[MovedSatItem(1,1),QUESTIONOpts.L1Capacity]; % a new path
                nodeLoad=nodeLoad-QUESTIONOpts.L1Capacity;
            else
                rest=QUESTIONOpts.L1Capacity-PathLoad(i,1);
                nodeLoad=nodeLoad-rest;
                
                if size(L1Neighbor{1,1}{i,1},1)>0
                    %check if there is the same cus in this path
                    sameCusIndex=find(L1Neighbor{1,1}{i,1}(:,1)==MovedSatItem(1,1));
                    if size(sameCusIndex,1)>0
                        %insert into this path. just add the load to the same sat
                        Temp{1,1}{i,1}(sameCusIndex(1,1),2)=Temp{1,1}{i,1}(sameCusIndex(1,1),2)+rest;
                    else
                        %try every position
                        minFirstFit=+inf;minFirst=Temp;
                        for j=1:size(L1Neighbor{1,1}{i,1},1)+1
                            Temp1=Temp;
                            if j==1
                                Temp1{1,1}{i,1}=[MovedSatItem(1,1),rest;Temp1{1,1}{i,1}];
                            elseif j==size(L1Neighbor{1,1}{i,1},1)+1
                                Temp1{1,1}{i,1}=[Temp1{1,1}{i,1};MovedSatItem(1,1),rest];
                            else
                                Temp1{1,1}{i,1}=[Temp1{1,1}{i,1}(1:j-1,:);MovedSatItem(1,1),rest;Temp1{1,1}{i,1}(j:end,:)];
                            end
                            tempFit=layer1Fit( Temp1,Center2SatDist,Sat2SatDist );
                            if tempFit<minFirstFit
                                minFirstFit=tempFit;
                                minFirst=Temp1;
                            end
                        end
                        Temp=minFirst;
                    end 
                else
                    Temp{1,1}{i,1}=[MovedSatItem(1,1),rest]; % a new path
                end
                
               
            end
            %second path
            if nodeLoad>QUESTIONOpts.L1Capacity
                %if rest is too big, try another schema
                continue;
            else
                for p=1:QUESTIONOpts.L1Fleet
                    if i==p
                        continue;
                    end
                    % if not used path
                    if p>size(L1Neighbor{1,1},1)
                        TTemp=Temp;
                        TTemp{1,1}{p,1}=[MovedSatItem(1,1),nodeLoad]; % a new path
                        tempFit=layer1Fit( TTemp,Center2SatDist,Sat2SatDist );
                        if tempFit<minFit
                            minPath1=i;minPath2=p;
                            minFit=tempFit;
                            minNeighbor=TTemp;
                            minPath2Load=PathLoad(p,1)+nodeLoad;
                        end
                        break;
                    end
                    rest=QUESTIONOpts.L1Capacity-PathLoad(p,1);
                    if rest<nodeLoad
                        continue;
                    end
                    if size(L1Neighbor{1,1}{p,1},1)==0
                        TTemp=Temp;
                        TTemp{1,1}{p,1}=[MovedSatItem(1,1),nodeLoad]; % a new path
                        tempFit=layer1Fit( TTemp,Center2SatDist,Sat2SatDist );
                        if tempFit<minFit
                            minPath1=i;minPath2=p;
                            minFit=tempFit;
                            minNeighbor=TTemp;
                            minPath2Load=PathLoad(p,1)+nodeLoad;
                        end
                    else
                        %try every position
                        for j=1:size(L1Neighbor{1,1}{p,1},1)+1
                            TTemp=Temp;
                            if j==1
                                TTemp{1,1}{p,1}=[MovedSatItem(1,1),nodeLoad;TTemp{1,1}{p,1}];
                            elseif j==size(L1Neighbor{1,1}{p,1},1)+1
                                TTemp{1,1}{p,1}=[TTemp{1,1}{p,1};MovedSatItem(1,1),nodeLoad];
                            else
                                TTemp{1,1}{p,1}=[TTemp{1,1}{p,1}(1:j-1,:);MovedSatItem(1,1),nodeLoad;TTemp{1,1}{p,1}(j:end,:)];
                            end
                            tempFit=layer1Fit( TTemp,Center2SatDist,Sat2SatDist );
                            if tempFit<minFit
                                minPath1=i;minPath2=p;
                                minFit=tempFit;
                                minNeighbor=TTemp;
                                minPath2Load=PathLoad(p,1)+nodeLoad;
                            end
                        end
                    end
                end
            end
        end
        if minPath1==0
            L1Neighbor=TotalResult;
            return;
        end
        %move the node from MoveSatLoad
        MoveSatLoad(index,:)=[];
        PathLoad(minPath1,1)=QUESTIONOpts.L1Capacity;
        PathLoad(minPath2,1)=minPath2Load;
        L1Neighbor=minNeighbor;
    end
end


%check if a path has 2 same sat
for i=1:size(L1Neighbor{1,1},1)
    if size(L1Neighbor{1,1}{i,1},1)==0
        continue
    end
    for j=1:size(L1Neighbor{1,1}{i,1},1)
        if size(find(L1Neighbor{1,1}{i,1}==L1Neighbor{1,1}{i,1}(j,1)))>1
            disp('a path has 2 same sat!!!!');
        end
    end
end


L1Neighbor{1,3}=fitness(L1Neighbor,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
end

