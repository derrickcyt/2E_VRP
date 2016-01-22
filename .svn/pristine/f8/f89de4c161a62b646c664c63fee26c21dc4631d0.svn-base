function [ Priority ] = calSourcePriority( InputSource,GlobalMin,alpha,ABCOpts )
m=size(InputSource,1);%source amount
fit=zeros(m,1);
for i=1:m
    fit(i,1)= InputSource{i,1}{1,3};
end
MaxFit=max(fit);
Priority=zeros(m,1);
total=0;
for i=1:m
    Priority(i,1)=(MaxFit-fit(i,1)+alpha)*(1-InputSource{i,2}/ABCOpts.Limit);
    total=total+Priority(i,1);
end
if total==0
   disp('total=0'); 
end
%normalize
Priority=Priority./total;




%think about
%1.current best result
%2.no-improve times







end

