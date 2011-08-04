function [gg gg0]=Hist3d(wwqx,wwqy, xxyyspan, npoints)

bignum=1000000;
%Just an offset of the minimum data 
xdelta=xxyyspan(1);  
ydelta=xxyyspan(3);  
wwqx=wwqx-xdelta;
wwqy=wwqy-ydelta;

%The total span of xy data
xspan=(xxyyspan(2)-xxyyspan(1));
yspan=(xxyyspan(4)-xxyyspan(3));

%normalizing the points by the real span 
nnx=npoints/xspan;
nny=npoints/yspan;

wwqx=wwqx*nnx;
wwqy=wwqy*nny;
sss=length(wwqy);

%Rou
xround=round(wwqx);
yround=round(wwqy);
wwunique=unique(bignum*xround+ yround);

wwhxx=ones(npoints+1,1)*linspace(0,npoints,npoints+1);
wwhyy=wwhxx';
wwhzz=wwhyy*0;
lll=size(wwunique,1);

HHkk=zeros(lll,1);
HHii=zeros(lll,1);
HHjj=zeros(lll,1);

for jj=1:lll;
    HHkk(jj)=length(find(wwunique(jj)==(bignum*xround+ yround)));
    HHii(jj)=round(100*wwunique(jj)/bignum)/100;
    HHjj(jj)=wwunique(jj)-bignum*(HHii(jj));
    jjx=find(HHjj(jj)==wwhyy(:,1));
    iix=find(HHii(jj)==wwhxx(1,:));
    wwhzz(jjx,iix)=HHkk(jj);
    %wwhxx(iix,jjx)=HHii(jj);
    %wwhyy(iix,jjx)=HHjj(jj);    
end


gg.x=wwhxx/nnx+xdelta;
gg.y=wwhyy/nny+ydelta;
gg.z=wwhzz/sss;
gg0.z=wwhzz;
% % 
% figure(1)
% %plot3(HHii/nn, HHjj/nn, HHkk/sss, 'c.')
% surf(gg.x, gg.y, gg.z,'edgecolor', 'none')
% view(2)
% 
% pause
% %plot(wwhxx/nn, wwhyy/nn,'r.')
% %plot(xround/nn, yround/nn,'g.')
