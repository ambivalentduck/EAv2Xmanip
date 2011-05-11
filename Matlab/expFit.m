function tau=expFit(subject)

y=subject.maxperpendicular(subject.block(4).trials(1:2:end-1))';
x=0:length(y)-1;
p0=[];

L=size(y,1);
q=1:5:100;                                      % setup parameter
yRange=max(y)-min(y);                           % range spanned by y values
TempSchedule=expDecay([0 5*yRange 15],q);       % for simulated anneal.
step=0;                                         % counter
if isempty(p0), p0=[y(L), y(1)-y(L), L]; end    % init.guess ifNot provided

%% INITIAL OPTIMIZATION
fprintf('=========Optimizing..');               % 
p=lsqcurvefit('expDecay',p0,x,y,[0 0 0],[1e5 1e5 100]);               % INITIAL OPTIMIZATION
f=expDecay(p,x);                                % Eval
cost=sum((y-f).^2);                             % evaluate the cost
bestP=p; bestCost=cost;                         % init as best
options=optimset('TolFun',1e-13);               % setup 
lastBestf=0.*x;
fcnExp=['f=' num2str(bestP(1)) '+'        ...   % text string showing sln
        num2str(bestP(2)) '*exp(-x/'      ...   % ...
        num2str(bestP(3)) ')'];                 % ...

%% SIMULATED ANNEALING LOOP
for T=TempSchedule                              % loop: annealing temp
  step=step+1;
  fprintf('__Step%d(temp=%f)...',step,T); 
  p0New=p+T*rand(size(p));                      % simmulated annealing perturbation
  p=lsqcurvefit('expDecay',           ...       % OPTIMIZATON
    p0New,x,y,[0 0 0],[1e5 1e5 100],options);                   % ... f=expDecay(p,x);                              % Eval based on solved params
  cost=sum((y-f).^2);                           % cost evaluation 
  if cost<bestCost,                             % Choose if improved
    bestP=p; bestCost=cost;                     % new init guess as best
    fcnExp=['f=' num2str(bestP(1)) '+'    ...   % text string showing sln
            num2str(bestP(2)) '*exp(-x/'  ...   % ... 
             num2str(bestP(3)) ')'];            % ...
    lastBestf=f;
  end
end

%% FINAL STUFF
p=bestP; cost=bestCost;  f=expDecay(p,x);       % take the best
fprintf('\n======= Optimizing Complete.\n');    %

tau=p(3);