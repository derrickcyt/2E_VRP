function [  ] = printResult( TotalResult,filePath,setName,Cus2CusDist,Sat2CusDist,Sat2SatDist,Center2SatDist,Demand)
L1Result=TotalResult{1,1};
L2Result=TotalResult{1,2};

fid=fopen(filePath,'w');

fprintf(fid,'%s\r\n',setName);
fprintf(fid,'total Cost = %f\r\n',TotalResult{1,3});
fprintf(fid,'-----------------------Layer1--------------------\r\n');

%L1
for i=1:size(L1Result)
    load=0;L1Length=0;
    if size(L1Result{i,1},1)==0
        fprintf(fid,'Cost(0.0),Weight(0.0),Cust(0)\r\n');
        continue;
    end
    first=Center2SatDist(L1Result{i,1}(1,1));
    L1Length=L1Length+first;
    if size(L1Result{i,1},1)==1
        L1Length=L1Length+first;
        load=load+L1Result{i,1}(1,2);
    else
        for j=1:size(L1Result{i,1},1)-1
            load=load+L1Result{i,1}(j,2);
            L1Length=L1Length+Sat2SatDist(L1Result{i,1}(j,1),L1Result{i,1}(j+1,1));
        end
        load=load+L1Result{i,1}(size(L1Result{i,1},1),2);
        L1Length=L1Length+Center2SatDist(L1Result{i,1}(size(L1Result{i,1},1)));
    end
    fprintf(fid,'Cost(%f),Weight(%f),Cust(%d) ',L1Length,load,size(L1Result{i,1},1));
    for j=1:size(L1Result{i,1},1)
        fprintf(fid,'%d ',L1Result{i,1}(j,1));
    end
    fprintf(fid,'\r\n');
end

fprintf(fid,'\r\n');
fprintf(fid,'-----------------------Layer2--------------------\r\n');

%L2
for i=1:size(L2Result,1)
    %for one sat
    SatLength=0;pathNum=0;
    Length=zeros(size(L2Result{i},1),1); %index:pathId, 1:length
    Load=zeros(size(L2Result{i},1),1); %index:pathId, 1:length
    CusNum=zeros(size(L2Result{i},1),1); %index:pathId, 1:CusNum
    Path=cell(size(L2Result{i},1),1); %index:pathId, 1:CusList
    for j=1:size(L2Result{i},1)
        if size(L2Result{i}{j},1)==0
            continue;
        end
        pathNum=pathNum+1;
        pathLength=0;pathLoad=0;CusNum(j,1)=size(L2Result{i}{j},1);
        PathCus=zeros(size(L2Result{i}{j},1),1);
        first=Sat2CusDist(i,L2Result{i}{j}(1));
        SatLength=SatLength+first;
        pathLength=pathLength+first;
        if size(L2Result{i}{j},1)==1
            SatLength=SatLength+first;
            pathLength=pathLength+first;
            pathLoad=pathLoad+Demand(L2Result{i}{j}(1));
            PathCus(1)=L2Result{i}{j}(1);
        else
            for k=1:size(L2Result{i}{j},1)-1
                SatLength=SatLength+Cus2CusDist(L2Result{i}{j}(k),L2Result{i}{j}(k+1));
                pathLength=pathLength+Cus2CusDist(L2Result{i}{j}(k),L2Result{i}{j}(k+1));
                pathLoad=pathLoad+Demand(L2Result{i}{j}(k));
                PathCus(k)=L2Result{i}{j}(k);
            end
            SatLength=SatLength+Sat2CusDist(i,L2Result{i}{j}(size(L2Result{i}{j},1)));
            pathLength=pathLength+Sat2CusDist(i,L2Result{i}{j}(size(L2Result{i}{j},1)));
            pathLoad=pathLoad+Demand(L2Result{i}{j}(size(L2Result{i}{j},1)));
            PathCus(size(L2Result{i}{j},1))=L2Result{i}{j}(size(L2Result{i}{j},1));
        end
        Length(j,1)=pathLength;
        Load(j,1)=pathLoad;
        Path{j,1}=PathCus;
    end
    
    fprintf(fid,'Cost=%f,Vehicles=%d\r\n',SatLength,pathNum);
    for j=1:size(L2Result{i},1)
        if size(L2Result{i}{j},1)==0
            continue;
        end
        fprintf(fid,'Cost(%f),Weight(%f),Cust(%d) ',Length(j,1),Load(j,1),CusNum(j,1));
        for k=1:size(L2Result{i}{j},1)
            fprintf(fid,'%d ',Path{j,1}(k,1));
        end
        fprintf(fid,'\r\n');
    end
    fprintf(fid,'\r\n');
end


fclose(fid);




end

