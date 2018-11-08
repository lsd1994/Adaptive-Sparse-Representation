function y=Normalize(x,ymin,ymax)
%normalize x to ymin-ymax,linear
xmax=max(x(:));
xmin=min(x(:));
y=(ymax-ymin)*(x-xmin)/(xmax-xmin)+ymin; 
end