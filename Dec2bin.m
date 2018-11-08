function y=Dec2bin(a)%decimal number to binary
if(a>=0)
    y=dec2bin(a);
else
    y=dec2bin(abs(a));
    for t=1:numel(y)
        if(y(t)=='0')y(t)='1';
        else y(t)='0';
        end
    end
end