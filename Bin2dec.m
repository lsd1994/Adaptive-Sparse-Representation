function a=Bin2dec(s)
if(s(1)=='1')
    a=bin2dec(s);
else
    for t=1:numel(s)
        if(s(t)=='0')s(t)='1';
        else s(t)='0';
        end
    end
    a=bin2dec(s);
    a=-a;
end