function ASR2Decode(I,dc_thre,ac_thre)
%load bitstream after encoding
input=fopen('bitstream.txt','r');
decode=fgets(input);
fclose(input);

%basic information of image
m=bin2dec(decode(1:10));
n=bin2dec(decode(11:20));
dc_code_length=bin2dec(decode(21:36));
dc_coeff_decode=decode(37:dc_code_length+36);
ac_coeff_decode=decode(dc_code_length+37:end);
if(mod(m,8)~=0)%extend first
    newm=m+8-mod(m,8);
else
    newm=m;
end
if(mod(n,8)~=0)
    newn=n+8-mod(n,8);
else
    newn=n;
end

%dc decode
dc_Huff={'011','100','00','101','110','1110',...%typical huffman code
         '11110','111110','1111110','11111110','111111110'};
pos=1;blockm=newm/8;blockn=newn/8;
dc=zeros(blockm,blockn);
%for each dc component,its prefix code has codelen bits,and tail code has k bits
for i=1:blockm
    for j=1:blockn
        if(dc_coeff_decode(pos:pos+2)=='010')
            dc(i,j)=0;pos=pos+3;
        else
            for codelen=2:9
                tmp=dc_coeff_decode(pos:pos+codelen-1);
                f=0;
                for k=1:11
                    if(strcmp(tmp,dc_Huff(k)))%find corresponding huffman code
                        f=1;break;
                    end
                end
                if(f==1)
                    dc(i,j)=Bin2dec(dc_coeff_decode(pos+codelen:pos+codelen+k-1));
                    pos=pos+codelen+k;
                    break;
                end
            end
        end
    end
end

%dc reconstruction
dc_recon=dc*dc_thre;
for i=1:blockm
    for j=1:blockn
        if(i==1&&j==1)
            dc_recon(i,j)=dc_recon(i,j);
        else
            if(j==1)dc_recon(i,j)=dc_recon(i-1,j)+dc_recon(i,j);
            else dc_recon(i,j)=dc_recon(i,j-1)+dc_recon(i,j);
            end
        end
    end
end

%ac decode
load('Dictionary.mat');
blocknum=newm*newn/64;
global sr;global len;global it;
sr=zeros(256,1);len=1;ac=zeros(64,blocknum);
for i=1:blocknum
    it=1;
    EntropyDecoding(ac_coeff_decode,1);
    sr=sr*ac_thre;
    ac(:,i)=Dictionary.D*sr;
end

%ac reconstruction
k=1;ac_recon=zeros(newm,newn);
for i=1:8:newm
    for j=1:8:newn
        ac_recon(i:i+7,j:j+7)=reshape(ac(:,k),8,8);
        k=k+1;
    end
end

%image reconstruction
img_recon=zeros(newm,newn);
for i=1:newm
    for j=1:newn
        img_recon(i,j)=dc_recon(ceil(i/8),ceil(j/8))+ac_recon(i,j);
    end
end

%truncate to original size
img_recon=img_recon(1:m,1:n);

%decompression information
I=im2double(I)*255;
fprintf('psnr: %.4f\n',psnr(img_recon,I,255));

figure,
subplot(121),imshow(I,[]),title('original');
subplot(122),imshow(img_recon,[]),title('reconstructed');