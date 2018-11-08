I=imread('lena.pgm');
dc_thre=1;
ac_thre=22;
S=8;
ASR2Encode(I,dc_thre,ac_thre,S);
ASR2Decode(I,dc_thre,ac_thre);