function [Img_after_extend,newm,newn]=Extend2(Img,m,n)
%duplicate padding to extend to 8 multiple of row and column
if(mod(m,8)==0)
    row_extend=0;
else
    row_extend=8-mod(m,8);
end
if(mod(n,8)==0)
    col_extend=0;
else
    col_extend=8-mod(n,8);
end
newm=m+row_extend;%size after extend
newn=n+col_extend;
row_add=Img(m,:);
row_add=repmat(row_add,row_extend,1);
col_add=Img(:,n);
col_add=repmat(col_add,1,col_extend);
dig_add=row_add(:,n);
dig_add=repmat(dig_add,1,col_extend);
Img_after_extend=[Img,col_add;row_add,dig_add];