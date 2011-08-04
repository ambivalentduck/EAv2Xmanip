clc
clear all
tic

%delete('errorvtimedata.mat')
if ~exist('errorvtimedata.mat')
    range=[1,2,5,7,10,11,13,15,19,21,22,26,27,29,30,301:320];

    for k=range
        if(~exist(['../Data/',num2str(k),'.mat']))
            try
                addSubject(num2str(k))
                toc
            end
        end
    end

    matexists=zeros(400,1);

    for k=range
        if(exist(['../Data/',num2str(k),'.mat']))
            matexists(k)=1;
        end
    end


    matexists=find(matexists);
    l=length(matexists);

    group=cell(l,1);

    c=0;
    toc
    names={'Delay','Delay + EA','','EA'};
    delay={'Delay','Delay + EA'};
    ea={'Delay + EA','EA'};

    numbers=zeros(size(matexists));
    for M=matexists'
        disp(num2str(M))
        load(['../Data/',num2str(M),'.mat']);
        if sum(strcmp(subject.block(3).treatName,names))==0
            continue
        end
        c=c+1;

        if sum(strcmp(subject.block(3).treatName,delay))>0
            delaygroup(c)=1;
        end

        if sum(strcmp(subject.block(3).treatName,ea))>0
            eagroup(c)=1;
        end

        group{c}=subject.block(3).treatName;
        if isempty(group{c})
            group{c}='Null';
        end

        %%%%%%% Get perp dists
        trials=subject.block(3).trials(end-20:end);
        data{c}.cat=zeros(length(trials),1);
        for k=trials
            x=subject.trial(k).drawn;
            o=subject.trial(k).origin;
            t=subject.trial(k).time';
            x=[x(:,1)-o(1), x(:,2)-o(2)];
            try
                M=subject.trial(k).target-o;
            catch
                M=subject.trial(k).target'-o;
            end
            d=sqrt(x(:,1).^2 + x(:,2).^2);
            cc=1;
            while d(cc)<(.4436/50+.4436/25)
                cc=cc+1;
            end
            data{c}.t{k-trials(1)+1}=t-t(cc);

            theta=-atan2(M(2),M(1));
            rot=[cos(theta),-sin(theta);sin(theta),cos(theta)];
            y=(rot*x');
            data{c}.error{k-trials(1)+1}=y(:,2);

            if subject.trial(k).targetcat~=0
                data{c}.cat(k-trials(1)+1)=subject.trial(k).targetcat;
            else
                data{c}.cat(k-trials(1)+1)=-subject.trial(k-1).targetcat;
            end
        end
        toc
    end
    disp('Crunching complete, now organizing.')
    save('errorvtimedata.mat')
else
    load('errorvtimedata.mat');
end


cats=[-3 3 -2 2 -1 1];
[a,b,c]=unique(group);

tlims=linspace(0,1,100);
elims=linspace(0,.014,100);

for k=1:length(a)
    fk=find(c==k);
    figure(k)
    clf
    for kk=1:length(fk)
        for k2=1:length(cats)
            subplot(6,length(fk),length(fk)*(k2-1)+kk)
            fc=find(data{fk(kk)}.cat==cats(k2));
            error=[data{fk(kk)}.error{fc}];
            t=[data{fk(kk)}.t{fc}];
            [n,x,y]=hist2d(t,error,10,10);
            imagesc(x(1,:),y(:,1),n)
        end
    end
    suplabel(a{k},'t');
end






