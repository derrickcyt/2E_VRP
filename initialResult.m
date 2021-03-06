TotalResult=cell(1,4);

%for every customer, search his nearest satellite
TotalSatPos=distBasedSatCusDivide(Sat2CusDist,CusPos); %cell index:satId, column1:SatCusPos

%check if overload
loadLimit=QUESTIONOpts.L2Fleet*QUESTIONOpts.L2Capacity;
for i=1:QUESTIONOpts.Satellites
    load=0;
    for j=1:size(TotalSatPos{i,1},1)
        load=load+Demand(TotalSatPos{i,1}(j,1));
    end
    if load>loadLimit
        disp('overload!!!!!!!!!!!!!!!!!');
    end
end


%greedy initial customer
L2Result=cell(QUESTIONOpts.Satellites,1);
for i=1:QUESTIONOpts.Satellites %for every sat
    SatResult=cell(QUESTIONOpts.L2Fleet,1);
    dividedResult=degreeDivide(TotalSatPos{i,1},SatPos(i,:),Demand,QUESTIONOpts.L2Fleet,QUESTIONOpts.L2Capacity); %1:CusId 2:PartId
    PerSatCusPos=cell(QUESTIONOpts.L2Fleet,1); % index:PartId 1:SatCusPos. (unHandled)
    for j=1:QUESTIONOpts.L2Fleet
        SatPartCusPos=[];
        load=0;
        for k=1:size(dividedResult,1)
            if dividedResult(k,2)==j
                load=load+Demand(dividedResult(k,1));
                SatPartCusPos=[SatPartCusPos;dividedResult(k,1),CusPos(dividedResult(k,1),:)];
            end
        end
        PerSatCusPos(j,1)={SatPartCusPos};
        if load>QUESTIONOpts.L2Capacity
            ifOverload=j; %no.j car is overloaded.
            break;
        end
    end
    
    %initial every part in every sat:
    %strategy:sum all the cus-sat vector and get the total vecter direction, 
    %choose the left and nearest cus as the next cus, or the right and nearest one.
    for j=1:QUESTIONOpts.L2Fleet %for every part
        TempSatCusPos=PerSatCusPos{j,1};
        Sq=zeros(size(PerSatCusPos{j,1},1),1);
        currentIndex=1; %current index needed to cal.
        vector=[0,0];
        minIndex=-1;
        while currentIndex<=size(Sq,1)
            %if path have cus, cal vecter.
            if currentIndex>1
                vector=vector+CusPos(Sq(currentIndex-1),:)-SatPos(i,:);
            end
            %if vector equals 0, need to find another nearest cus.
            if vector==[0,0]
                %get the nearest cus from sat
                PartSatCusDist=calDist(TempSatCusPos,SatPos(i,:));
                minIndex=find(PartSatCusDist(:,2)==min(PartSatCusDist(:,2)),1);
                Sq(currentIndex)=TempSatCusPos(minIndex,1);
                TempSatCusPos(minIndex,:)=[];
            else
                %choose the left and nearest cus
                %get all the left cus
                leftCus=[];baseDegree=getDegree(vector(1),vector(2));
                for k=1:size(TempSatCusPos,1)
                    x=TempSatCusPos(k,2)-SatPos(i,1);y=TempSatCusPos(k,3)-SatPos(i,2);
                    if baseDegree<getDegree(x,y)
                        leftCus=[leftCus;TempSatCusPos(k,1),CusPos(TempSatCusPos(k,1),:)];
                    end
                end
                if size(leftCus,1)==0
                    leftCus=TempSatCusPos; %if left side has no cus, choose the nearest one from the rest.
                end
                PartSatCusDist=calDist(leftCus,CusPos(Sq(currentIndex-1),:));
                minIndex=find(PartSatCusDist(:,2)==min(PartSatCusDist(:,2)),1);
                Sq(currentIndex)=leftCus(minIndex,1);
                TempSatCusPos(find(TempSatCusPos(:,1)==leftCus(minIndex,1)),:)=[];
            end
            currentIndex=currentIndex+1;
        end   
        SatResult(j,1)={Sq};
    end
    L2Result(i,1)={SatResult};
    clear TempSatCusPos SatResult load dividedResult Nearest PartSatCusDist vector baseDegree leftCus PerSatCusPos SatPartCusPos Sq
end



%initial 1st level(greedy)
SatLoad=zeros(QUESTIONOpts.Satellites,1);
for i=1:QUESTIONOpts.Satellites
    %cal every sat's load
    load=0;
    for j=1:size(L2Result{i,1},1)
        
        for k=1:size(L2Result{i,1}{j,1},1)
            load=load+Demand(L2Result{i,1}{j,1}(k));
        end
    end
    SatLoad(i)=load;
end
TotalResult{1,4}=SatLoad;
%greedy selection
L1Result=cell(QUESTIONOpts.L1Fleet,1); L1Num=0;
while size(nonzeros(SatLoad),1)>0
    Sq=[];
    %start from Center. choose a possible and nearest sat
    CandidateSat=find(SatLoad~=0);minIndex=1; % min dist from center or last sat
    for i=1:size(CandidateSat,1)
       if(Center2SatDist(CandidateSat(i))<Center2SatDist(minIndex))
           minIndex=CandidateSat(i);
       end
    end 
    currentSatIndex=minIndex;
    if SatLoad(minIndex)<QUESTIONOpts.L1Capacity
        load=SatLoad(minIndex);
        SatLoad(minIndex)=0;
        Sq=[Sq;minIndex,load];
    else
        load=QUESTIONOpts.L1Capacity;
        SatLoad(minIndex)=SatLoad(minIndex)-QUESTIONOpts.L1Capacity;
        L1Num=L1Num+1;
        Sq=[Sq;minIndex,load];
        L1Result(L1Num,1)={Sq};
        continue;
    end

    %find more sat adding to this path
    while load<QUESTIONOpts.L1Capacity
        if size(nonzeros(SatLoad),1)==0
            break;
        end
        CandidateSat=find(SatLoad~=0);minIndex=CandidateSat(1);
        for i=1:size(CandidateSat,1)
            if CandidateSat(i)~=minIndex && Sat2SatDist(CandidateSat(i),currentSatIndex)<Sat2SatDist(minIndex,currentSatIndex)
               minIndex=CandidateSat(i);
            end
        end
        space=QUESTIONOpts.L1Capacity-load;
        if space>=SatLoad(minIndex)
            load=load+SatLoad(minIndex);      
            Sq=[Sq;minIndex,SatLoad(minIndex)];
            SatLoad(minIndex)=0;
        else
            load=QUESTIONOpts.L1Capacity;
            SatLoad(minIndex)=SatLoad(minIndex)-space;
            Sq=[Sq;minIndex,space];
        end
    end
    
     L1Num=L1Num+1;
     L1Result(L1Num,1)={Sq};
end

TotalResult{1,1}=L1Result;
TotalResult{1,2}=L2Result;
TotalResult{1,3}=fitness(TotalResult,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist);