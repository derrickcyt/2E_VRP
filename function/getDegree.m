function degree = getDegree(x,y)
c=sqrt(x.^2+y.^2);
sin=y/c;
cos=x/c;
if cos<=0
    degree=180-asind(sin);
else
    degree=mod(asind(sin),360);
end
end
% function degree = getDegree(sin,cos)
% if cos<=0
%     degree=180-asind(sin);
% else
%     degree=mod(asind(sin),360);
% end
% end

