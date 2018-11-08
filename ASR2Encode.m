function ASR2Encode(I,dc_thre,ac_thre,S)
%duplicate padding to extend
[m,n]=size(I);
if(mod(m,8)~=0||mod(n,8)~=0)
    [I,newm,newn]=Extend2(I,m,n);%see function Extend2
else
    newm=m;newn=n;
end

%partition to 8*8 blocks and averaging
blocknum=newm*newn/64;%number of blocks
I=im2double(I)*255;
f1=@(x) mean2(x.data);
dc_coeff=blockproc(I,[8 8],f1);%dc component

%dc difference
dc_diff_coeff=zeros(1,blocknum);
k=1;
[blockm,blockn]=size(dc_coeff);
for i=1:blockm
    for j=1:blockn
        if(i==1&&j==1)
            dc_diff_coeff(k)=dc_coeff(i,j);
        else
            if(j==1)dc_diff_coeff(k)=dc_coeff(i,j)-dc_coeff(i-1,j);
            else dc_diff_coeff(k)=dc_coeff(i,j)-dc_coeff(i,j-1);
            end
        end
        dc_diff_coeff(k)=round(dc_diff_coeff(k)/dc_thre);
        k=k+1;
    end
end

%dc entropy encoding(Huffman)
dc_Huff={'011','100','00','101','110','1110',...%typical huffman code
         '11110','111110','1111110','11111110','111111110'};
k=1;dc_code={''};
while(k<=blocknum)
    if(dc_diff_coeff(k)==0)
          tmp='010';
    else
        bit=floor(log2(abs(dc_diff_coeff(k))))+1;%length of code
        c.size=dc_Huff(bit);
        c.amp=Dec2bin(dc_diff_coeff(k));
        tmp=strcat(c.size,c.amp);
    end
    k=k+1;
    dc_code=strcat(dc_code,tmp);
end
dc_code_length=length(char(dc_code));

%bitstream output
output=fopen('bitstream.txt','w+');
fprintf(output,'%s',dec2bin(m,10));%original row and col encode for 10 bits
fprintf(output,'%s',dec2bin(n,10));
fprintf(output,'%s',dec2bin(dc_code_length,16));%length of dc code encode for 16 bits
fprintf(output,'%s',char(dc_code));
fclose(output);

%dc removal
ac_coeff=zeros(newm,newn);
for i=1:newm
    for j=1:newn
        ac_coeff(i,j)=I(i,j)-dc_coeff(ceil(i/8),ceil(j/8));
    end
end

%calculate visual saliency map(normalized)
%return value is a struct,whose master_map_resized member is the GBVS map for image
gbvs=GBVS(I);
sal_val=blockproc(gbvs.master_map_resized,[8 8],f1);%saliency map
sal_val=Normalize(sal_val,0,1);%see function Normalize

%calculate sparsity level
sal_tot=sum(sal_val(:));
alpha=blocknum*sal_val/sal_tot;
spar_lev=round(alpha*S);%0-norm of block i

%sparse coefficients
load('Dictionary.mat');
k=1;ac_code_length=0;res=zeros(1,blocknum);
for i=1:8:newm
    for j=1:8:newn
        imtmp=ac_coeff(i:i+7,j:j+7);
        spar_ij=spar_lev(ceil(i/8),ceil(j/8));
        if(spar_ij>1)%acquire sparse coefficients
            [spar_coeff(:,k),res(k)]=OMP(Dictionary.D,imtmp(:),spar_ij);
        else %specify sparsity level with 1
            [spar_coeff(:,k),res(k)]=OMP(Dictionary.D,imtmp(:),1);
        end
        spar_coeff(:,k)=round(spar_coeff(:,k)/ac_thre);
        global str;str='';
        EntropyCoding(spar_coeff(:,k),1,256);%see function EntropyCoding
        output=fopen('bitstream.txt','a+');
        fprintf(output,'%s',str);
        fclose(output);
        ac_code_length=ac_code_length+length(str);
        k=k+1;
    end
end

%compression information
fprintf('length of dc code: %d\n',dc_code_length);
fprintf('length of ac code: %d\n',ac_code_length);
fprintf('bit per pixel: %.3f\n',(36+dc_code_length+ac_code_length)/(m*n));