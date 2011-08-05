function out=speedaccuracyTO(varargin)

% if strcmp(varargin{1},'ylabel')
%     out='Speed-accuracy TO';
%     return
% end
% 
% subject=varargin{1};

load(['../Data/3.mat']);

t=subject.block(3).trials;
length(t)
RT=reachtimes(subject);
length(RT)
maxperp=maxperpendicular(subject);
length(maxperp)
figure(1)
plot(maxperp(t), RT(t), '.')


figure(2)
out=plot3(t, maxperp(t), RT(t), '.')