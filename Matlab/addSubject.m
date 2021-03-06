function varargout=addSubject(varargin)
tic

name=varargin{1};
doall=0;

if length(varargin)>1
    if strcmp(varargin{2},'all')
        doall=1;
    end
end

if(~ischar(name))
    name=char(name);
end


if strcmp(name,'parseDir')
    n.names='';
    ns=0;
    d=dir(txtData);
    d={d.name};
    [d1]=regexpi(d,'^(.*)Cont.dat$', 'tokens');
    for k=1:length(d1)
        if ~isempty(d1{k})
            if (~exist([matData,char(d1{k}{1}),'.mat'],'file'))||doall
                ns=ns+1;
                n(ns).names=char(d1{k}{1});
            end
        end
    end
    names={n.names};
else
    names{1}=char(name);
    ns=1;
end

if (nargin>1)&&(nargout>0)
    varargout{1}=names;
end

for n=1:ns
    name=names{n};

    input=load(['../Data/input',name,'.dat']);
    %trial, treat, stim, targetx, targety, (delay)?
    output=load(['../Data/output',name,'.dat']);
    try
        testaccess=output(:,13:14);
    catch
        fixbroken(['output',name,'.dat']);
        output=load(['../Data/output',name,'.dat']);
    end
    %trial TAB now-zero TAB cursor.X() TAB cursor.Y() TAB velocity.X() TAB
    %velocity.Y() TAB accel.X() TAB accel.Y() TAB origin.X() TAB origin.Y() TAB target.X() TAB target.Y();
    %outStream << sphere.position.X() TAB sphere.position.Y() << endl;

    angles=atan2(input(:,5),input(:,4));
    f=find(angles<0);
    angles(f)=angles(f)+2*pi;
    [angletypes,useless,categories]=unique(angles);

    for k=1:size(input,1)
        subject.trial(k).num=k;
        if k~=input(k,1)
            disp(['Line numbers and trial numbers are different? ',num2str(k)])
        end
        subject.trial(k).treat=input(k,2);
        subject.trial(k).stim=input(k,3);
        subject.trial(k).targetcat=categories(k)-1;
        if size(input,2)>5
            subject.trial(k).delay=input(k,6);
        else
            subject.trial(k).delay=zeros(size(input(k,3)));
        end
        f=find(output(:,1)==k);
        subject.trial(k).trials=f;
        subject.trial(k).time=output(f,2);
        subject.trial(k).cont=output(f,3:4);
        subject.trial(k).vel=output(f,5:6);
        subject.trial(k).accel=output(f,7:8);
        subject.trial(k).origin=output(f(1),9:10);
        subject.trial(k).target=output(f(1),11:12);
        subject.trial(k).drawn=output(f,13:14);
    end

    blocks=[15*3 8*8*3 8*8*3 8*3 5*3]*2;
    cumblocks=cumsum([1 blocks]);
    blockNames={'Warm-Up','Sporadically Stimulated','Stimulated and Treated','Stimulated and Untreated','Warm-Down'};
    stimNames={'','Curl','Saddle','Visual Rotation'};
    treatNames={'','EA','2XVC', '2XHC','Half-Reach'};

    for k=1:length(blocks)
        subject.block(k).trials=cumblocks(k):cumblocks(k+1)-1;
        subject.block(k).typeName=blockNames{k};
        block(k).typeName=blockNames{k};
        if k~=3
            subject.block(k).treatName='';
        else
            if sum(find([subject.trial.delay]>0))>0
                if sum(find([subject.trial.treat]==1))>0
                    subject.block(k).treatName=['Delay + ',treatNames{2}];
                elseif sum(find([subject.trial.treat]==2))>0
                    subject.block(k).treatName=['Delay + ',treatNames{3}];
                elseif sum(find([subject.trial.treat]==3))>0
                    subject.block(k).treatName=['Delay + ',treatNames{4}];
                elseif sum(find([subject.trial.treat]==4))>0
                    subject.block(k).treatName=['Delay + ',treatNames{5}];
                else
                    subject.block(k).treatName='Delay';
                end
            else
                if sum(find([subject.trial.treat]==1))>0
                    subject.block(k).treatName=treatNames{2};
                elseif sum(find([subject.trial.treat]==2))>0
                    subject.block(k).treatName=treatNames{3};
                elseif sum(find([subject.trial.treat]==3))>0
                    subject.block(k).treatName=treatNames{4};
                elseif sum(find([subject.trial.treat]==4))>0
                    subject.block(k).treatName=treatNames{5};
                elseif str2num(name)>100
                    subject.block(k).treatName='1995 Graphics';
                else
                    subject.block(k).treatName='';
                end
            end
        end
        if (k~=2) && (k~=3)
            subject.block(k).stimName='';
        else
            subject.block(k).stimName='Curl';
        end
    end
    try
        subject.number=str2num(name);
    end
    save(['../Data/',name,'.mat'],'subject')
    toc
end