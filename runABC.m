
close all
clc
setName='set3';
filename='E-n51-k5-s40-41.dat';
outputpath=strcat('result/test/',date,'_',filename);
start=clock;
GlobalMinResult=runOneData(setName,filename,outputpath,0);
fprintf('”√ ±:%f√Î\n',etime(clock,start));
fid=fopen(outputpath);
temp=fgets(fid);
while temp~=-1
    fprintf('%s',temp);
    temp=fgets(fid);
end
fclose(fid);