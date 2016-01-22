function [ SameList]= checkSatCusAllocWithBest( CurrentSources,BestResult,QUESTIONOpts )
SameList=[];
BestAlloc=zeros(QUESTIONOpts.Satellites,QUESTIONOpts.Customers);

for satId=1:QUESTIONOpts.Satellites
    pathNum=size(BestResult{1,2}{satId,1},1);
    for pathId=1:pathNum
        cusNum=size(BestResult{1,2}{satId,1}{pathId,1},1);
        if cusNum==0
            continue;
        end
        path=BestResult{1,2}{satId,1}{pathId,1};
        for cusInd=1:cusNum
            BestAlloc(satId,path(cusInd))=1;
        end
    end
end

sNum=size(CurrentSources,1);
for sId=1:sNum
    Alloc=zeros(QUESTIONOpts.Satellites,QUESTIONOpts.Customers);
    for satId=1:QUESTIONOpts.Satellites
        pathNum=size(CurrentSources{sId,1}{1,2}{satId,1},1);
        for pathId=1:pathNum
            cusNum=size(CurrentSources{sId,1}{1,2}{satId,1}{pathId,1},1);
            if cusNum==0 || size(CurrentSources{sId,1}{1,2}{satId,1}{pathId,1},2)==0
                continue;
            end
            path=CurrentSources{sId,1}{1,2}{satId,1}{pathId,1};
            for cusInd=1:cusNum
                Alloc(satId,path(cusInd))=1;
            end
        end
    end
    %check
    if isequal(Alloc,BestAlloc)
        SameList=[SameList;sId];
    end
    %     diff=0;d=0;
    %     for i=1:QUESTIONOpts.Customers
    %         if BestAlloc(1,i)~=Alloc(1,i)
    %             diff=diff+1;
    %             d=i;
    %         end
    %     end
    %     if diff==1
    %         fprintf('1:%d ',d);
    %     end
    %     Diff(sId,1)=diff;
    %     fprintf('%d ',diff);
    %     if diff==1
    %         fprintf('\n');
    %         for i=1:QUESTIONOpts.Customers
    %             fprintf('%d\t',i);
    %         end
    %         fprintf('\n');
    %         for i=1:QUESTIONOpts.Customers
    %             fprintf('%d\t',Alloc(1,i));
    %         end
    %         fprintf('\n');
    %         for i=1:QUESTIONOpts.Customers
    %             fprintf('%d\t',BestAlloc(1,i));
    %         end
    %         fprintf('\n');
    %     end
    
    
end
end

