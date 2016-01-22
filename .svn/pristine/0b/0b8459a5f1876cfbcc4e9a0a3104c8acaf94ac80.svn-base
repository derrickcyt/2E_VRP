function [ OutputResult ] = releasePathTry( TotalResult,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos )
OutputResult=TotalResult;
pathNum=size(TotalResult{1,2}{satId,1},1);
actPathNum=0;%used Path Num
%find the least path in satId
PathCusNum=zeros(pathNum,1);
ActPathList=zeros(pathNum,1);%used Path List
for i=1:pathNum
    if size(TotalResult{1,2}{satId,1}{i,1},1)==0 || size(TotalResult{1,2}{satId,1}{i,1},2)==0
        PathCusNum(i,1)=+inf;% no cus
    else
        PathCusNum(i,1)=size(TotalResult{1,2}{satId,1}{i,1},1);
        actPathNum=actPathNum+1;
        ActPathList(actPathNum,1)=i;
    end
end
ActPathList=ActPathList(1:actPathNum,1);
if actPathNum<=1
    return 
end
OutputResult=Merge2Path(TotalResult,ActPathList,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos);



return;









% minPathId=find(PathCusNum==min(PathCusNum),1);
% MinPath=TotalResult{1,2}{satId,1}{minPathId,1};
% minPathCusNum=size(MinPath,1);
% ActPathList=ActPathList(1:actPathNum);
% ActPathList(find(ActPathList==minPathId,1),:)=[];%remove this path
% actPathNum=actPathNum-1;
% 
% if minPathCusNum>3
%     %this situation can use this method:
%     %find 2 path and check if these 2 path can be merged.
%     
%     
%     
%     return;
% elseif minPathCusNum==1
%     if Sat2CusDist(satId,MinPath(1))==0
%         return;
%     end
% end
% 
% 
% 
% %check the rest space in other path
% PathRestSpace=zeros(pathNum,1);
% totalRest=0;
% for i=1:actPathNum
%     tCusNum=size(TotalResult{1,2}{satId,1}{ActPathList(i,1),1},1);
%     tLoad=0;
%     if tCusNum>0
%         for j=1:tCusNum
%             tLoad=tLoad+Demand(TotalResult{1,2}{satId,1}{ActPathList(i,1),1}(j),1);
%         end
%     end
%     PathRestSpace(ActPathList(i,1),1)=QUESTIONOpts.L2Capacity-tLoad;
%     totalRest=totalRest+PathRestSpace(ActPathList(i,1),1);
% end
% 
% %if no enough space
% if totalRest<QUESTIONOpts.L2Capacity-PathRestSpace(minPathId,1)
%     return;
% end
% 
% %if pathNum smaller than cusNum
% if actPathNum<minPathCusNum
%     return;
% end
% 
% minFit=+inf;
% %del
% TotalResult{1,2}{satId,1}{minPathId,1}=[];
% %insert trying
% if minPathCusNum==1
%     %try every path
%     for i=1:actPathNum
%         if Demand(MinPath(1),1)<=PathRestSpace(ActPathList(i,1),1)
%             cusId=MinPath(1);
%             %add(try every pos)
%             desPathCusNum=size(TotalResult{1,2}{satId,1}{ActPathList(i,1),1},1);
%             for j=1:desPathCusNum+1
%                 Temp=TotalResult;
%                 tempPath=Temp{1,2}{satId,1}{ActPathList(i,1),1};
%                 if j==1
%                     tempPath=[cusId;tempPath];
%                 elseif j==desPathCusNum+1
%                     tempPath=[tempPath;cusId];
%                 else
%                     tempPath=[tempPath(1:j-1,:);cusId;tempPath(j:desPathCusNum,:)];
%                 end
%                 Temp{1,2}{satId,1}{ActPathList(i,1),1}=tempPath;
%                 tempFit=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
%                 if tempFit<minFit
%                     Temp{1,3}=tempFit;
%                     OutputResult=Temp;
%                     minFit=tempFit;
%                 end
%             end
%         end
%     end
%     % else
%     %     tryTimes=prod(1:actPathNum)/prod(1:(actPathNum-minPathCusNum));
%     %     memR=[];memNum=0;memFit=zeros(tryTimes,1);memResult=cell(tryTimes,1);
%     %     %list out all possibility
%     %     nc=nchoosek(actPathList,minPathCusNum);
%     %     for i=1:size(nc,1)
%     %         memR=[memR;perms(nc(i,:))];
%     %     end
%     %     for i=1:size(memR,1)
%     %         minPosResult=TotalResult;
%     %         for j=1:minPathCusNum
%     %             if PathRestSpace(memR(i,j),1)<Demand(minPath(j,1),1)
%     %                 memFit(i,1)=+inf;
%     %                 break;
%     %             end
%     %             minPosFit=+inf;
%     %             cusId=minPath(j,1);
%     %             %add(try every pos)
%     %             desPathCusNum=size(TotalResult{1,2}{satId,1}{memR(i,j),1},1);
%     %             for k=1:desPathCusNum+1
%     %                 Temp=minPosResult;
%     %                 tempPath=Temp{1,2}{satId,1}{memR(i,j),1};
%     %                 if k==1
%     %                     tempPath=[cusId;tempPath];
%     %                 elseif k==desPathCusNum+1
%     %                     tempPath=[tempPath;cusId];
%     %                 else
%     %                     tempPath=[tempPath(1:k-1,:);cusId;tempPath(k:desPathCusNum,:)];
%     %                 end
%     %                 Temp{1,2}{satId,1}{memR(i,j),1}=tempPath;
%     %                 tempFit=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
%     %                 if tempFit<minPosFit
%     %                     Temp{1,3}=tempFit;
%     %                     minPosResult=Temp;
%     %                     minPosFit=tempFit;
%     %                 end
%     %             end
%     %         end
%     %         memResult{i,1}=minPosResult;
%     %     end
%     %     memFit=memFit(1:size(memR,1),1);
%     %     minIndex=find(memFit==min(memFit),1);
%     %     if memFit(minIndex)==+inf
%     %         return
%     %     end
%     %     OutputResult=memResult{minIndex,1};
% end

end



function [Neighbor]=Merge2Path(TotalResult,ActPathList,satId,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand,QUESTIONOpts,CusPos )
Neighbor=TotalResult;
%try to merge
Candidate=nchoosek(ActPathList,2);
%cal path load
PathLoad=zeros(size(ActPathList,1),1);
for i=1:size(ActPathList,1)
    Path=Neighbor{1,2}{satId,1}{ActPathList(i),1};
    for j=1:size(Path,1)
        PathLoad(i)=PathLoad(i)+Demand(Path(j));
    end
end

for i=1:size(Candidate,1)
    P1=Neighbor{1,2}{satId,1}{Candidate(i,1),1};
    P2=Neighbor{1,2}{satId,1}{Candidate(i,2),1};
    E=PathLoad(find(ActPathList==Candidate(i,1),1))+PathLoad(find(ActPathList==Candidate(i,2),1))-QUESTIONOpts.L2Capacity;
    P1=[P1;P2];%merge
    %check
    if E<=0
        Temp=Neighbor;
        Temp{1,2}{satId,1}{Candidate(i,2),1}=[];
        Temp{1,2}{satId,1}{Candidate(i,1),1}=P1;
        fit=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
        Temp{1,3}=fit;
        if fit<TotalResult{1,3}
            Neighbor=Temp;
            return;
        end
    else
        %get the avaliale cus
        CanCus=[];
        for j=1:size(P1,1)
            if E<=Demand(P1(j))
                CanCus=[CanCus;P1(j)];
            end
        end
        if size(CanCus,1)==0
            continue;
        end
        CanDist=Sat2CusDist(satId,CanCus)';%get dist to sat
        %sort cus-sat dist
        SortList=sort(CanDist);
        %try several cus
        for j=1:size(SortList)
            TempP1=P1;
            TempP2=P2;
            Temp=Neighbor;
            cusId=CanCus(find(CanDist==SortList(j),1));
            %remove from P1
            TempP1(find(TempP1==cusId,1))=[];
            TempP2=[cusId];
            %do some path optimization
            TempP1=PathInnerOperator(TempP1,satId,Cus2CusDist,Sat2CusDist,3);
            Temp{1,2}{satId,1}{Candidate(i,2),1}=TempP2;
            Temp{1,2}{satId,1}{Candidate(i,1),1}=TempP1;
            fit=fitness(Temp,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);
            Temp{1,3}=fit;
            if fit<TotalResult{1,3}
                Neighbor=Temp;
                return;
            end
        end
    end
    
    
    
end

end



