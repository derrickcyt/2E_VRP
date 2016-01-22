function [ dividedResult ] = distBasedSatCusDivide( SatPosDist,CusPos )
satNum=size(SatPosDist,1);
cusNum=size(SatPosDist,2);
dividedResult=cell(size(SatPosDist,1),1); %1:Sat-Cus 2:Sat's CusNum
SatCusNum=zeros(size(SatPosDist,1),1);
for i=1:size(SatPosDist,1)
    TempSatCusPos=zeros(size(SatPosDist,2),3);
    dividedResult(i,1)={TempSatCusPos};
end

%if the dist error less than 5, choose randomly.
for j=1:cusNum
    minSatId=find(SatPosDist(:,j)==min(SatPosDist(:,j)),1);
    E=zeros(satNum,1);
    for i=1:satNum
        if i==minSatId
            E(i,1)=+inf;
        else
            E(i,1)=abs(SatPosDist(i,j)-SatPosDist(minSatId,j)); 
        end
    end
    minE=min(E);
    if minE<5;
        askSatId=find(E==minE,1);
        whichLess=randi([1,2],1,1);
        if whichLess==2
            SatPosDist(askSatId,j)=SatPosDist(minSatId,j)-1;
        end
    end
end


for i=1:size(SatPosDist,2)
    minSatIndex=find(SatPosDist(:,i)==min(SatPosDist(:,i)),1);
    SatCusNum(minSatIndex)=SatCusNum(minSatIndex)+1;
    dividedResult{minSatIndex,1}(SatCusNum(minSatIndex),:)=[i,CusPos(i,:)];
end

for i=1:size(SatPosDist,1)
    dividedResult{i,1}=dividedResult{i,1}(1:SatCusNum(i),:);
end

end

