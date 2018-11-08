function EntropyDecoding(c,lev)
global sr;global len;global it;
if(lev==9)%maximum depth
    if(c(len)~='0')
        tmp=c(len+1:len+6);
        sr(it)=bin2dec(tmp)-31;
        it=it+1;
        len=len+7;
    else
        sr(it)=0;
        it=it+1;
        len=len+1;
    end
else
    if(c(len)=='1')
        len=len+1;
        EntropyDecoding(c,lev+1);
        EntropyDecoding(c,lev+1);
    else
        len=len+1;
        a=2^(9-lev);
        for it=it:it+a-1
            sr(it)=0;
        end
        it=it+1;
    end
end