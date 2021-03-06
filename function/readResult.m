function [ TotalResult ] = readResult( filePath )
%read result file into a TotalResult

source = importdata(filePath,'',9999999);

S=regexp(source{2,1},' ','split');
totalCost=str2num(S{1,4});
%L1
L1Result={};
i=4;l1PathNum=0;satNum=0;
while size(source{i,1},1)>0
    S=regexp(source{i,1},',','split');
    CostCell=regexprep(S(1),'Cost\((\d+\.\d+)\)','$1');
    cost=str2num(CostCell{1,1});
    WeightCell=regexprep(S(2),'Weight\((\d+\.\d+)\)','$1');
    weight=str2num(WeightCell{1,1});
    PathCell=regexp(S(3),'\s+','split');
    if size(PathCell{1,1},2)<=2
        i=i+1;
        continue;
    end
    Path=zeros(size(PathCell{1,1},2)-2,1);
    for j=1:size(PathCell{1,1},2)-2
        satNum=satNum+1;
        Path(j,1)=str2num(PathCell{1,1}{1,j+1});
    end
    l1PathNum=l1PathNum+1;
    L1Result{l1PathNum,1}=Path;
    i=i+1;
end


%L2
L2Result={};
SatWeight=zeros(satNum,1);
i=i+2;satId=1;ifBegin=1;pathId=1;
for i=i:size(source,1)
    if size(source{i,1},1)==0
        satId=satId+1;
        ifBegin=1;
        pathId=1;
        continue;
    end
    if ifBegin
        i=i+1;
        ifBegin=0;
        continue;
    else
        Path=[];
        S=regexp(source{i,1},',','split');
        WeightCell=regexprep(S(2),'Weight\((\d+\.\d+)\)','$1');
        weight=str2num(WeightCell{1,1});
        SatWeight(satId,1)=SatWeight(satId,1)+weight;
        PathCell=regexp(S(3),'\s+','split');
        if size(PathCell{1,1},2)<=2
            continue;
        end
        Path=zeros(size(PathCell{1,1},2)-2,1);
        for j=1:size(PathCell{1,1},2)-2
            Path(j,1)=str2num(PathCell{1,1}{1,j+1});
        end
        L2Result{satId,1}{pathId,1}=Path;
        pathId=pathId+1;
    end
    
    
    S=regexp(source{i,1},',','split');
    CostCell=regexprep(S(1),'Cost\((\d+\.\d+)\)','$1');
    
    i=i+1;
end



TotalResult=cell(1,4);
TotalResult{1,1}=L1Result;
TotalResult{1,2}=L2Result;
TotalResult{1,3}=totalCost;
TotalResult{1,4}=SatWeight;



end

