function varargout=distfrombase(varargin)

if strcmp(varargin{1},'ylabel')
    out='Average Distance from Baseline';
    return
end

subject=varargin{1};

%ultimately need 3 cats, last N reaches from block 1 for each cat, space
%const still 70?

cats=[subject.trial.targetcat];
cat1=cats(subject.block(1).trials);

for cat=1:3
    f=find(cat1==cat);
    f=f(end-4:end);

    completiontime=zeros(length(f),1);
    for kk=1:length(f)
        dat=subject.trial(f(kk));
        target=dat.target;
        x=dat.drawn;
        t=dat.time';
        o=dat.origin;

        x=[x(:,1)-o(1), x(:,2)-o(2)];

        d=sqrt(x(:,1).^2 + x(:,2).^2);
        cc=1;
        while d(cc)<(.4436/50+.4436/25)
            cc=cc+1;
        end
        t=t-t(cc);
        ft=find(t>=0);
        concat(cat,kk).t=t(ft);
        completiontime(kk)=t(end);

        concat(cat,kk).x=subject.trial(f(kk)).drawn(ft,1)';
        concat(cat,kk).y=subject.trial(f(kk)).drawn(ft,2)';
    end
    tlist{cat}=[concat(cat,:).t];
    xlist{cat}=[concat(cat,:).x];
    ylist{cat}=[concat(cat,:).y];
end

out=zeros(length(subject.trial),1);

figure(1)
clf
hold on

for k=1:length(subject.trial)
    dat=subject.trial(k);
    if dat.targetcat==0
        out(k)=out(k-1);
        continue
    end
    target=dat.target;
    x=dat.drawn;
    t=dat.time';
    o=dat.origin;

    x=[x(:,1)-o(1), x(:,2)-o(2)];

    d=sqrt(x(:,1).^2 + x(:,2).^2);
    cc=1;
    while d(cc)<(.4436/50+.4436/25)
        cc=cc+1;
    end
    t=t-t(cc);
    ft=find(t>=0);
    tdesired=t(ft);
    xw=weightedAve(tlist{dat.targetcat},xlist{dat.targetcat},tdesired,70);
    yw=weightedAve(tlist{dat.targetcat},ylist{dat.targetcat},tdesired,70);
    if nargout==0
        for kk=1:length(ft)
            plot3([dat.drawn(ft(kk),1) xw(kk)],[dat.drawn(ft(kk),2) xw(kk)],[kk kk],'g')
        end
        o=ones(size(ft))*kk;
        plot3(dat.drawn(ft,1),dat.drawn(ft,2),o,'b');
        plot3(xw,yw,o,'r');
    end
    out(k)=mean( sqrt( (dat.drawn(ft,1)-xw).^2 + (dat.drawn(ft,2)-yw).^2 ) );
end
varargout{1}=out;
