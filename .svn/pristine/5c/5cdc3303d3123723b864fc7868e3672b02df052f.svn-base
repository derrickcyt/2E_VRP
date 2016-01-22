goalFile=importdata('dataset/Set2/goal.dat');
myResultFile=importdata('result/set2/1.txt');
tp=0;num=0;
for i=1:size(goalFile.data,1)
   for j=1:size(myResultFile,1)
       S=regexp(myResultFile{j},'\t','split');
       if strcmp(goalFile.textdata{i,1},S{1})
           p=str2num(S{2})/goalFile.data(i);
           tp=tp+p;num=num+1;
           fprintf('%s %f\r\n',goalFile.textdata{i,1},p);
       end
   end
end

fprintf('%s %f\r\n','average:',tp/num);