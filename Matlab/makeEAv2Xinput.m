function makeEAv2Xinput(number, Treat, Stim)

if Treat==3
    Treat=2;
    X2dist=1;
else
    X2dist=0;
end

fhandle=fopen(['../Data/input',num2str(number),'.dat'],'wt');

%In center out reaching, you really only define half of the targets.  The
%goal is a shuffle of 2 lengths with 3 directions.  So, block lengths
%should be even multiples of 12.

directions=[pi/6 5*pi/6 3*pi/2]; % Y shape to avoid motor
%Only need to compute trig/multiply once
cd=cos(directions);
sd=sin(directions);
cd2=cd/2;
sd2=sd/2;

xtable=[cd2',cd'];
ytable=[sd2',sd'];
%use via xtable(direction, distance), directions 1-3 and distance (.5 or 1)
%as (1 or 2)

% sporadicfreq=8;
%
% warmup=45; 15*3 arbitrary
% sporadicstim=192; 8*8*3 not arbitrary
% stimtreat=192; 8*8*3 presently arbitrary, should change depending on observed saturation time
% stimuntreat=24; 8*3 not arbitrary, 8 samples in each direction
% warmdown=15; 5*3 arbitrary

phases=[15*3 8*8*3 8*8*3 8*3 5*3]*2;
sporadic=[0 1 2 -2 0];
offset=0;
zero=1;

for K=1:length(phases)
    [dir,s]=shuffleStuff(phases(K)/2, (abs(sporadic(K)) == 1));
    for k2=1:phases(K)
        k=ceil(k2/2);
        switch sporadic(K)
            case 0 %Untreated
                stim=0;
                treat=0;
            case 1 %Sporadic stim
                if ~zero
                    stim=0;
                else
                    stim=Stim*s(k);
                end
                treat=0;
            case -1 %Sporadically untreated, always stim
                stim=Stim;
                treat=Treat*(~s(k));
            case 2 %Always stim, treat
                stim=Stim;
                treat=Treat;
            case -2 %Always stim, no treat
                treat=0;
                stim=Stim;
            otherwise
                error('Fail at case switch?!??');
        end
        if (treat==2) && X2dist %2x
            dist=2;
        else
            dist=1;
        end
        if zero
            fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',k2+offset,treat,stim,xtable(dir(k),dist),ytable(dir(k),dist));
            zero=0;
        else
            fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',k2+offset,treat,stim,0,0);
            zero=1;
        end
    end
    offset=offset+k2;
end

fclose(fhandle);

function [dir,s]=shuffleStuff(n, sporadic)
n3=mod(n,3);
if n3 ~= 0
    error('N is the wrong size.  Should be divisible by 3.')
end

if (n~=8*8*3) && sporadic
    error('N must be 8*8*3 when sporadic')
end

r1=randperm(n);

direction=ceil(3*(1:n)/n); %A list of 1s, 2s, and 3s, sorted: 111222333 etc
%distance=mod((1:n)-1,2)+1; Not presently in use, but would go 12121212 etc
if sporadic
    s=zeros(size(direction));
    first=find(direction==1);
    second=find(direction==2);
    third=find(direction==3);
    s([first(1:8) second(1:8) third(1:8)])=ones(24,1);
else
    s=zeros(size(direction));
end

flag=1;
while flag
    flag=0;
    for k=1:length(r1)
        if s(r1(k))==1
            if sum(s(r1(k:min(k+3,n))))>1 %Don't permit to catch trials within 4 trials of one another
                temp=r1(k);
                rnd=floor(rand*n)+1;
                r1(k)=r1(rnd);
                r1(rnd)=temp;
                flag=1;
                break;
            end
        end
    end
end

dir=direction(r1);
%dist=distance(r1);
s=s(r1);