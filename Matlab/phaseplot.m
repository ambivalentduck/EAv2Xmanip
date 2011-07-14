function phaseplot(varargin)
%load systematically
name=varargin{1};

output=cell(1,1);

load(['../Data/',name,'.mat']);

for k=2:length(varargin)
    if isa(varargin{k},'function_handle') %If argument 2,3,4...etc is a functional handle, run it on the data and store it
        output{k-1}=feval(varargin{k},subject);
    else
        break;
    end
end

lo=length(output);

try
    figure(varargin{end});
catch %#ok<CTCH>
    figure(1);
end
clf
hold on

%initalize
aftereffects=zeros(lo,1);
learningStarttoFinish=zeros(lo,1);
learning3=zeros(lo,1);

f=find([subject.trial(subject.block(2).trials).stim]~=0);
exes2=subject.block(2).trials(f);
f=find([subject.trial(subject.block(2).trials).stim]==0);
dots2=subject.block(2).trials(f);

for o=1:lo
    sub=[subject.block(1).trials(end-9:end) subject.block(5).trials(1:10)];
    aftereffects(o)=regressNotZero(sub,output{o}(sub));

    subset=subject.block(3).trials;
    learning3(o)=regressNotZero(subset,output{o}(subset));

    sub=[exes2, subject.block(4).trials(max([end-2*length(exes2),2]):2:end)];
    learningStarttoFinish(o)=regressNotZero(sub,output{o}(sub));
end


colors='kgcmy';

tol=.01;


ticklabs=zeros(2*lo+4,1);
for k=1:length(output)
    m=mean(output{k});
    s=std(output{k});
    f=find(abs(output{k}-m)<3*s);
    if isempty(f)
        f=1:length(output{k});
    end
    ticklabs(1+2*(k-1))=min(output{k}(f));
    ticklabs(2*k)=max(output{k}(f));
    output{k}=output{k}-ticklabs(1+2*(k-1)); %subtract off the minimum
    output{k}=output{k}/(ticklabs(2*k)-ticklabs(1+2*(k-1))); %divide by the maximum
    output{k}(output{k}>=1-tol)=1-tol;
    output{k}(output{k}<=tol)=tol;
end

ticklabs(end-3:end)=[0; 1; 0; 1];
centers=zeros(length(subject.block),1);
for b=1:length(subject.block)
    centers(b)=(subject.block(b).trials(end)+subject.block(b).trials(1))/2;
end

for k=1:lo
    for b=1:length(subject.block)
        subset=subject.block(b).trials(6:end-5);
        if b~=2
            dots=1:length(subset);
            exes=[];
        else
            exes=find([subject.trial(subset).stim]~=0);
            dots=find([subject.trial(subset).stim]==0);
        end
        output_=output{k}(subset);
        plot(subset(dots(2:2:end)),output_(dots(2:2:end))+(k-1),'b.')
        plot(subset(exes),output_(exes)+(k-1),'bx')
        for kk=1:5
            symbol='.';
            plot(subject.block(b).trials(kk),output{k}(subject.block(b).trials(kk))+(k-1),[symbol,colors(kk)])
            plot(subject.block(b).trials(end-(kk-1)),output{k}(subject.block(b).trials(end-(kk-1)))+(k-1),[symbol,colors(6-kk)])
        end

        if learningStarttoFinish(k)&&(b==4)
            plot(centers(b),k-.5,'r*')
        end
        if learning3(k)&&(b==3)
            plot(centers(b),k-.5,'r*')
        end
        if aftereffects(k)&&(b==5)
            plot(centers(b),k-.5,'r*')
        end
    end
end

try
    k=1;
    y=subject.expfitvals(1)+subject.expfitvals(2)*exp(-(0:length(subject.block(3).trials)-1)/subject.expfitvals(3));
    y=y-ticklabs(1+2*(k-1));
    y=y/(ticklabs(2*k)-ticklabs(1+2*(k-1)));
    plot(subject.block(3).trials,y,'c')
end

plotlaunches(gcf,lo,subject,colors,centers)

legends=cell(length(subject.block),1);
for k=1:length(subject.block)
    if strcmp(subject.block(k).treatName,'')
        plus='';
        if strcmp(subject.block(k).stimName,'')
            arrow='';
        else
            arrow=': ';
        end
    else
        arrow=': ';
        plus='+';
    end
    legends{k}=[subject.block(k).typeName,arrow,subject.block(k).stimName,plus,subject.block(k).treatName];
end
legends{end-1}=[legends{end-1},' ',legends{end}];
legends{end}=' ';


xtick=zeros(length(subject.block),1);

ylim([0 lo+2])
y=ylim;

for k=1:length(subject.block)
    if k>1
        plot([subject.block(k).trials(1)-.5 subject.block(k).trials(1)-.5],[y(1) y(2)],'r');
    end
    xtick(k)=mean([subject.block(k).trials(1) subject.block(k).trials(end)]);
end
L=subject.block(end).trials(end);
for k=1:(length(output)+1)
    plot([1 L], [k k],'r')
end

labels=cell(lo+2,1);
for k=1:lo
    labels{k}=feval(varargin{k+1},'ylabel');
end
labels{end-1}='Last five';
labels{end}='First five';
ytick=zeros(3*lo,1);
yticklabs=cell(3*lo,1);
displace=.1;
for k=1:lo+2
    ytick(1+3*(k-1):3*k)=[(k-1)+displace; k-.5; k-displace];
    yticklabs(1+3*(k-1):3*k)={num2str(ticklabs(1+2*(k-1))); labels{k}; num2str(ticklabs(2*k))};
end
set(gca,'ytick',ytick);
set(gca,'yticklabel',yticklabs);

set(gca,'xlim',[1 L]);
set(gca,'xtick',xtick);
set(gca,'xticklabel',legends)
title([name,', \tau = ',num2str(subject.tau,2)])

end