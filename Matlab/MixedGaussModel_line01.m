clear
close all
%load testdata01 %Curl, no EA
load felix1 %Curl, no EA
%load testdata02 %Curl, with EA
%load testdata2 %Curl, with EA, with delay
%load(['../Data/yyyy.mat']);
%load delayOnly %curl and delay

plotgo=1;
%Number of gaussians in model
numcomp=3; %felix found that 3 works best

%Histogram number of bins
npoints=50;

%Speed threshold; ignore below...
speed0=0.2;

%Position limits for analysis
xxyyspan=[0 0.15 -0.04 0.05];


[BB,AA]=butter(2, .9);
ggsoptions=statset('MaxIter', 200);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Moria's data has six directions of movement    
targlist=[t.target]';
orglist=[t.origin]';

targx=targlist(1:2:end);
targy=targlist(2:2:end);
orgx=orglist(1:2:end);
orgy=orglist(2:2:end);

Bqq=sign(((targy-orgy)*100))+5;
Aqq=(round(10*targx)-round(10*orgx))+2;
alltypes=1000*Bqq+Aqq;

uniquex=unique(alltypes);
for jj=1:6
    tlist{jj}=find(alltypes==uniquex(jj));
end
maxqqq=6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for qqq=1:6
    zvxx=[];
    zvyy=[];
    zxx=[];
    zyy=[];

    epp=0;

    mytriallist=tlist{qqq}';
    %for epi=mytriallist
    for epi=mytriallist(end-50:end) %change # of trials
        %for epi=mytriallist(1:20)

        epp=epp+1;
        dataset=t(epi);
        xxx=dataset.cont(:,1);
        yyy=dataset.cont(:,2);

        xxx_org=dataset.origin(1);
        yyy_org=dataset.origin(2);
        xxx_tar=dataset.target(1);
        yyy_tar=dataset.target(2);

        nz=find(xxx);
        xxx=xxx(nz);
        yyy=yyy(nz);


        if length(xxx)>0

            vxxx=deriv(xxx)/.01;
            vyyy=deriv(yyy)/.01;

            %Just cut off data that is not moving
            sss=(vxxx.^2+vyyy.^2).^0.5;
            lll=find(sss>speed0);
            vxx=vxxx(lll);
            vyy=vyyy(lll);
            xxx=xxx(lll);
            yyy=yyy(lll);

            vxx=filtfilt(BB,AA, xxx);
            vyy=filtfilt(BB,AA, yyy);

            rdist=sqrt((xxx-xxx_org).^2+    (yyy-yyy_org).^2);
            tdist=sqrt((xxx_tar-xxx_org).^2+(yyy_tar-yyy_org).^2);

            AAq=       [(xxx-xxx_org),(yyy-yyy_org)]';
            BBq=repmat([xxx_tar-xxx_org, yyy_tar-yyy_org ],length(AAq),1)';


            LL=sqrt(dot(AAq,AAq)).*sqrt(dot(BBq,BBq));
            qvec=acos(dot(AAq, BBq)./LL);


            AA1=sign(atan2((yyy-yyy_org),(xxx-xxx_org))-atan2((yyy_tar-yyy_org),(xxx_tar-xxx_org)));

            perpdist=sin(qvec).*rdist';
            projdist=cos(qvec).*rdist';
            rvect=projdist'*[(xxx_tar-xxx_org) (yyy_tar-yyy_org)]/[tdist]   ;

            xperp=rvect(:,1)+xxx_org;
            yperp=rvect(:,2)+yyy_org;

            xxxe=projdist';
            yyye=perpdist'.*AA1;

            zvxx=[zvxx; xxxe];
            zvyy=[zvyy; yyye];
            zxx=[zxx; xxx];
            zyy=[zyy; yyy];



        end

    end




    figure(2)

    matrixplot(qqq, 2, maxqqq,4,'',''); hold on

    ggdata=Hist3dxy(zvxx,zvyy, xxyyspan, npoints);
    gg2=surf(ggdata.x, ggdata.y, ggdata.z );
    %gg2=surf(ggdata.x, ggdata.y, newz );
    set(gg2,'edgec','none')
    axis equal
    xlim([xxyyspan(1) xxyyspan(2)])
    ylim([xxyyspan(3) xxyyspan(4)])
    zlim([0 max(ggdata.z(:))])
    G2 = gmdistribution.fit([zvxx, zvyy],numcomp,  'options', ggsoptions);
    MU = G2.mu;
    SIGMA = G2.Sigma;
    MIXP =  G2.PComponents;
    obj = gmdistribution(MU,SIGMA,MIXP);
    newz= ggdata.z.*abs(ggdata.y);

    xsqq=linspace(xxyyspan(1), xxyyspan(2),npoints);
    ysqq=linspace(xxyyspan(3), xxyyspan(4),npoints);
    xsqq2=linspace(xxyyspan(1), xxyyspan(2),round(npoints/5));
    ysqq2=linspace(xxyyspan(3), xxyyspan(4),round(npoints/5));

    [xq,yq] = meshgrid(xsqq,ysqq);
    [xq2,yq2] = meshgrid(xsqq2,ysqq2);


    for ii=1:numcomp
        x=xq-MU(ii,1);
        y=yq-MU(ii,2);
        x2=xq2-MU(ii,1);
        y2=yq2-MU(ii,2);

        sigx=sqrt(SIGMA(1,1,ii));
        sigy=sqrt(SIGMA(2,2,ii));
        roh=SIGMA(1,2,ii)/(sigx*sigy);
        
        %Felix's gaussian calculations:
        fi(:,:,ii)=(1/(2*pi*sigx*sigy*sqrt(1-roh^2)))*exp((-0.5/(1-roh^2))*((x.^2)/sigx^2+(y.^2)/sigy^2-2*roh.*x.*y/(sigx*sigy)));
        fi2(:,:,ii)=(1/(2*pi*sigx*sigy*sqrt(1-roh^2)))*exp((-0.5/(1-roh^2))*((x2.^2)/sigx^2+(y2.^2)/sigy^2-2*roh.*x2.*y2/(sigx*sigy)));


    end
    iii=0;


    fiii=0;
    fiii2=0;

    for kkk=1:numcomp
        fiii=fiii+(MIXP(kkk)*fi(:,:,kkk));
        fiii2=fiii2+(MIXP(kkk)*fi2(:,:,kkk));

    end




    
    matrixplot(qqq, 3, maxqqq,4,'',''); hold on

    gg2=ezsurf(@(x,y)pdf(obj,[x y]),[xxyyspan(1) xxyyspan(2)],[xxyyspan(3) xxyyspan(4)],100);
    %gg2=surf(xq,yq,fiii.*abs(yq));

    set(gg2,'edgec','none')
    axis equal
    xlim([xxyyspan(1) xxyyspan(2)])
    ylim([xxyyspan(3) xxyyspan(4)])
    mmz=get(gg2,'zdata');
    zlim([0 max(mmz(:))])



    %Contour
    matrixplot(qqq, 4, maxqqq,4,'',''); hold on

    [px,py] = gradient(-fiii.*abs(yq),.5,.5);

    ppx=0*fiii2;
    ppy=fiii2.*(yq2);

    contour(xsqq,ysqq,fiii.*abs(yq)), hold on,
    quiver(xsqq2,ysqq2,ppx,ppy), hold off
    %
    axis equal
    xlim([xxyyspan(1) xxyyspan(2)])
    ylim([xxyyspan(3) xxyyspan(4)])





    %Xy data plots
    matrixplot(qqq,1,maxqqq,4,'',''); hold on

    plot(zxx,zyy-0.4,'b-')
    plot(xxx_org,yyy_org-0.4,'ro')
    plot(xxx_tar,yyy_tar-0.4,'rx')
    plot([xxx_org xxx_tar],[yyy_org yyy_tar]-0.4,'k-')
    axis([-1 1 -1 1]*.15)
    axis square

end