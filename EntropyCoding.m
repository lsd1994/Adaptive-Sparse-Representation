function EntropyCoding(c,min,max)%O(nlogn)
global str;
if(min==max)
    if(c(min)~=0)
        str=strcat(str,'1');
        tmp=dec2bin(c(min)+31,6);%only use 8 bits
        str=strcat(str,tmp);
    else
        str=strcat(str,'0');
    end
else
    flag=0;%all zero coefficients
    for i=min:max 
        if(c(i)~=0)
            flag=1;break;
        end
    end
    if(flag==1)
        str=strcat(str,'1');
        mid=floor((min+max)/2);
        EntropyCoding(c,min,mid);
        EntropyCoding(c,mid+1,max);
    else
        str=strcat(str,'0');
    end
end