
close all
clc
times=3;
setName='set4';
%goalFile=importdata(strcat('dataset/',setName,'/goal.dat'));
for k=1:times
    file=dir(strcat('dataset/',setName,'/*'));
    result=cell(size(file,1),3);%1:result 2:fit 3:time
    for i=1:size(file,1)
        if strcmp(file(i).name,'.')||strcmp(file(i).name,'..')||strcmp(file(i).name,'goal.dat') || strcmp(file(i).name,'.DS_Store')
            continue;
        end
        
        % Set ABC Control Parameters
        ABCOpts = struct( 'ColonySize',  100, ...   % Number of Employed Bees+ Number of Onlooker Bees
            'SourceSize',50,...
            'OnlookerSize',50,...
            'MaxCycles', 1000,...   % Maximum cycle number in order to terminate the algorithm
            'FitGoal',   0, ...  % Error goal in order to terminate the algorithm (not used in the code in current version)
            'Limit',   50, ... % Control paramter in order to abandone the food source
            'RandBeginCycle', 500,...%outer operater's range increase
            'RecordLimit', 2,...%tolenrate times
            'RecordLimit2',3,...%2nd tolenrate times
            'InitLayer1OptTimes',10,...%init layer 1 opt times
            'InitInnerOptTimes',10,...%init inner opt times
            'EmptySatSourceNum',4,...%init number of source having empty sat
            'SatLimit',10,...%sat not improve limit
            'RunTime',1); % Number of the runs
        ABCOpts.SatLimit=ceil(ABCOpts.ColonySize/2);
        
        start=clock;
        outputFileName=strcat('result/',setName,'/',date,'_',num2str(k),'_',num2str(ABCOpts.ColonySize),'_',num2str(ABCOpts.MaxCycles),'_',num2str(ABCOpts.Limit),'_',file(i).name);
        result{i,1}=runOneData(setName,file(i).name,outputFileName,ABCOpts);
        result{i,3}=etime(clock,start);
        result{i,2}=result{i,1}{1,3};
        fprintf('%s\t%s\tFit:%f\t”√ ±%fs\n\n',setName,file(i).name,result{i,2},result{i,3});
    end
    
    fid=fopen(strcat('result/',setName,'/',num2str(k),'.txt'),'w');
    for i=1:size(file,1)
        if strcmp(file(i).name,'.')||strcmp(file(i).name,'..')||strcmp(file(i).name,'goal.dat') || strcmp(file(i).name,'.DS_Store')
            continue;
        end
        fprintf(fid,'%s\t%f\t%fs\r\n',file(i).name,result{i,1}{1,3},result{i,3});
    end
    fclose(fid);
    
    
end




