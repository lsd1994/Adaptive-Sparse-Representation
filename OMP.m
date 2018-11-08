function [A,res]=OMP(D,X,L)
% input:
%       D - dictionary
%       X - image
%       L - 0-norm
% ouput:
%       A - sparse coefficients
%       res - residual
residual=X;
indx=zeros(L,1);
for i=1:L
    proj=D'*residual;
    [~,pos]=max(abs(proj));
    pos=pos(1);
    indx(i)=pos;
    a=pinv(D(:,indx(1:i)))*X;
    residual=X-D(:,indx(1:i))*a;
    res=norm(residual);
    if res<1e-6
        break;
    end
end
A=zeros(size(D,2),1);
A(indx(indx~=0))=a;
end