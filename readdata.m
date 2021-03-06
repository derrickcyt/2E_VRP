%read data
data= regexpi(source, '(-\d)?\w*(\.*)(\w*)', 'match');

QUESTIONOpts=struct('Dimension',str2num(char(data{4}(2))),...
    'Satellites',str2num(char(data{5}(2))),...
    'Customers',str2num(char(data{6}(2))),...
    'L1Capacity',str2num(char(data{9}(2))),...
    'L2Capacity',str2num(char(data{10}(2))),...
    'L1Fleet',str2num(char(data{11}(2))),...
    'L2Fleet',str2num(char(data{12}(2))));

%find NODE_COORD_SECTION begin postion
DataCusBeginPos=-1;
DataSatBeginPos=-1;
DataDemandBeginPos=-1;
DataDepotBeginPos=-1;
for i=1:size(data,1)
    if strcmp(data{i},'NODE_COORD_SECTION')
        DataCusBeginPos=i;
    elseif strcmp(data{i},'SATELLITE_SECTION')
        DataSatBeginPos=i;
    elseif strcmp(data{i},'DEMAND_SECTION')
        DataDemandBeginPos=i;
    elseif strcmp(data{i},'DEPOT_SECTION')
        DataDepotBeginPos=i;
    end;
end;

CusPos=zeros(QUESTIONOpts.Customers,2);
CenterPos=[str2double(char(data{DataCusBeginPos+1}(2))) str2double(char(data{DataCusBeginPos+1}(3)))];
for i=DataCusBeginPos+2:(DataSatBeginPos-1)
    CusPos(i-DataCusBeginPos-1,:)=[str2double(char(data{i}(2))) str2double(char(data{i}(3)))];
end;


SatPos=zeros(QUESTIONOpts.Satellites,2);
for i=DataSatBeginPos+1:(DataSatBeginPos+QUESTIONOpts.Satellites)
    SatPos(i-DataSatBeginPos,:)=[str2double(char(data{i}(2))) str2double(char(data{i}(3)))];
end;

% Demand{0} is depot's demand. default 0.
Demand=zeros(QUESTIONOpts.Customers,1);
for i=DataDemandBeginPos+2:(DataDepotBeginPos-1)
    if size(data{i,1},1)==0
        continue;
    end
    Demand(i-DataDemandBeginPos-1)=str2double(char(data{i}(2)));
end;
clear DataCusBeginPos;clear DataSatBeginPos;clear DataDemandBeginPos;clear DataDepotBeginPos;clear source;clear data;
%end of reading data

%noEdgePlot(CusPos,SatPos,CenterPos);