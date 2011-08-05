clc
clear all
close all
tic

range=[1,2,5,7,10,11,13,15,19,21,22,26,27,29,30,302:320];


matexists=zeros(400,1);
for k=range
    if(exist(['../Data/',num2str(k),'.mat']))
        matexists(k)=1;
    end
end

matexists=find(matexists);
l=length(matexists);
c=0;
group={};
s={};
tic

%find all the mat files/loaded subject data
for k=matexists'
    load(['../Data/',num2str(k),'.mat']);
    c=c+1;
    group{c}=subject.block(3).treatName;
        if isempty(group{c})
        group{c}='Null';
        end

        %grap all the maxperpendicular and reach time data
        try
            output{k}.rawvals=subject.maxperpendicular;
        catch
            subject.maxperpendicular=feval(@maxperpendicular,subject);
            save(['../Data/',num2str(k),'.mat'],'subject')
            output{k}.rawvals=subject.maxperpendicular;
        end
    
    
        try
            output{k}.rawvals=subject.times;
        catch
            subject.times=feval(@reachtimes,subject);
            save(['../Data/',num2str(k),'.mat'],'subject')
            output{k}.rawvals=subject.times;
        end
   
        %output{k}.rawvals=subject.times./log(subject.maxperpendicular);
        %%alternative way to calculate Fitt's law. 
        maxperpB3=output{k}.rawvals(subject.block(3).trials(1:2:end-1)); %includes all the trials including center-in--> if you wanted to restrict to out simply index from (1:2:end)
        reachtimesB3=output{k}.rawvals(subject.block(3).trials(1:2:end-1));
   
end
    


[treatlabels,trash,groupnums]=unique(group);
groupnums

colors=[1, 0, 0;
    0,1,0;
    0,0,1;
    0,0,.5;
    1,.5,.5;
    0,1,1;
    1,1,0;
    1,0,1];

figure(1)

gn=groupnums;
[q1 q2 q3] = unique(gn);
w1 = hist(q3,1:length(q1));
out = [q1' w1'];
out = sortrows(out,-2);
maxlength=out(1,2);

% for k=1:length(treatlabels)
%     figure(151+k)
%     clf
%     hold on
%     f=find(groupnums==k);
%     for g=1:length(set)
%         for kk=1:length(f)
%             subplot(length(f),length(set),g+(kk-1)*length(set))
%             hold on
%             if g==1
%                 ylabel(num2str(kk))
%             end
%             for kkk=1:3
%                 plot(maxperpB3(1:c),reachtimesB3(1:c), '.')
%             end
%             axis equal
%             if kk==1
%             title(names{g})
%         end
%         end
%     end
%     thisisdumb(treatlabels{k})
%     suplabel(treatlabels{k},'t')
% end


for k=1:length(treatlabels)
    hold on
    f=find(groupnums==k);

        for kk=1:maxlength
            %subplot(length(treatlabels), length(groupnums), kk+(k-1)*length(groupnums))
            subplot(length(treatlabels), maxlength, kk+(k-1)*length(groupnums))
            hold on
           
            plot(maxperpB3(1:c),reachtimesB3(1:c), '.')
            axis equal
%             if kk==1
%             title(names{g})
%             end
            if kk==1
            ylabel(treatlabels{k})
            end
        end
      
 end  
    thisisdumb(treatlabels{k})
    suplabel(treatlabels{k},'t')
    
%====old code
% B3trials=subject.block(3).trials;
% length(t)
% RT=reachtimes(subject);
% length(RT)
% maxperp=maxperpendicular(subject);
% length(maxperp)
% figure(1)
% plot(maxperp(t), log(RT(t)), '.')
% 
% figure(2)
% plot3(t, RT(t), maxperp(t),'.')