#include "controlwidget.h"
#include <QDesktopWidget>
#include <cstdio>

#define targetDuration .5
#define oRadius min/80
#define cRadius min/40
#define tRadius min/40
#define TAB << "\t" <<
#define CURLVAL -20
#define SADDLEVAL 10
#define TIME_OFFSET .25l

ControlWidget::ControlWidget(QDesktopWidget * qdw) : QWidget(qdw->screen(qdw->primaryScreen()))
{
	//Take care of window and input initialization.
	
	setFocus(); //Foreground window that gets all X input
	
	center=point(-0.019,0.53); //Known from direct observation, do not change
	cursor=center;
	origin=center;
	//state=acquireTarget;
	
	min=.26; //Screen diameter (shortest dimension) known from direct observation, do not change
	targets = new TargetControl(.99l*min/2.5l, min/2.5l, min/2l, 7, 3);
		    //TargetControl(double spawndist, double innerRadius, double maxRadius)
	target=point(5,5);
	
	//Snag a UDP Socket and call a function (readPending) every time there's a new packet.
	ignoreInput=true;
	us=new QUdpSocket(this);
	us->bind(QHostAddress("192.168.0.1"),25000,QUdpSocket::DontShareAddress); //Bind the IP and socket you expect packets to be received from XPC on.
	connect(us, SIGNAL(readyRead()),this, SLOT(readPending()));
	
	layout = new QFormLayout(this);
	
	layout->addRow(startButton=new QPushButton("Start"));
	connect(startButton, SIGNAL(clicked()), this, SLOT(startClicked()));
	
	layout->addRow(tr("Subject Number:"), subjectBox=new QSpinBox(this));
	subjectBox->setValue(0);
	subjectBox->setMaximum(1000);
	subjectBox->setMinimum(0);
	grayList.push_back(subjectBox);
	connect(subjectBox, SIGNAL(valueChanged(int)), this, SLOT(setSubject(int)));
	
	layout->addRow(tr("Trial Number:"), trialNumBox=new QSpinBox(this));
	trialNumBox->setValue(0);
	trialNumBox->setMaximum(1000);
	trialNumBox->setMinimum(0);
	grayList.push_back(trialNumBox);
	connect(trialNumBox, SIGNAL(valueChanged(int)), this, SLOT(setTrialNum(int)));
	
	layout->addRow("Stimulus:",stimulusBox=new QComboBox(this));
	stimulusBox->insertItem(0,"Unstimulated");
	stimulusBox->insertItem(1,"Curl");
	stimulusBox->insertItem(2,"Saddle");
	grayList.push_back(stimulusBox);
	stimulus=UNSTIMULATED;
	connect(stimulusBox, SIGNAL(activated(int)), this, SLOT(setStimulus(int)));
	
	layout->addRow("Treatment:",treatmentBox=new QComboBox(this));
	treatmentBox->insertItem(0,"Unstimulated");
	treatmentBox->insertItem(1,"EA");
	treatmentBox->insertItem(2,"2X");
	grayList.push_back(treatmentBox);
	treatment=UNTREATED;
	connect(treatmentBox, SIGNAL(activated(int)), this, SLOT(setTreatment(int)));
	
	
	setLayout(layout);
	
	
	QRect geo=qdw->screenGeometry();
	geo.setWidth(2*geo.width()/3);
	geo.setHeight(4*geo.height()/5);
	geo.translate(80,80);
	setGeometry(geo);
	
	int notprimary=qdw->primaryScreen()==0?1:0;
	
	userWidget=new DisplayWidget(qdw->screen(notprimary), true);
	userWidget->setGeometry(qdw->screenGeometry(notprimary));
	userWidget->show();
	
	curl=0;
	saddle=0;
	trial=0;
	subject=0;
	ExperimentRunning=false;
	
	sphereVec.clear();
}

void ControlWidget::readPending()
{
	now=getTime();
	
	int s=us->pendingDatagramSize();
	if(inSize != s) in.resize(s);
	us->readDatagram(in.data(), in.size());
	
	if(ignoreInput)
	{
		out=QByteArray(in.data(),sizeof(double));//Copy the timestamp from the input
		switch(stimulus)
		{
		case UNSTIMULATED:
			curl=0;
			saddle=0;
			break;
		case CURL:
			curl=CURLVAL;
			saddle=0;
			break;
		case SADDLE:
			curl=0;
			saddle=SADDLEVAL;
			break;
			
		}
		out.append(reinterpret_cast<char*>(&curl),sizeof(double));
		out.append(reinterpret_cast<char*>(&saddle),sizeof(double));
		//This will require additional appends for other stimuli
		us->writeDatagram(out.data(),out.size(),QHostAddress("192.168.0.2"),25000);
		return;
	}
	
	cursor.X()=*reinterpret_cast<double*>(in.data()+sizeof(double));
	cursor.Y()=*reinterpret_cast<double*>(in.data()+2*sizeof(double));
	velocity.X()=*reinterpret_cast<double*>(in.data()+3*sizeof(double));
	velocity.Y()=*reinterpret_cast<double*>(in.data()+4*sizeof(double));
	accel.X()=*reinterpret_cast<double*>(in.data()+5*sizeof(double));
	accel.Y()=*reinterpret_cast<double*>(in.data()+6*sizeof(double));

	
	outStream << trial TAB now-zero TAB cursor.X() TAB cursor.Y() TAB velocity.X() TAB velocity.Y() TAB accel.X() TAB accel.Y() TAB origin.X() TAB origin.Y() TAB target.X() TAB target.Y();
	
	if (!leftOrigin) trialStart=now;
	if(!leftOrigin) if (cursor.dist(origin)>(oRadius+cRadius)) leftOrigin=true;
	
	sphereVec.clear();
	//origin
	sphere.color=point(.5,.5,.5); //Grey
	sphere.position=origin;
	sphere.radius=oRadius;
	sphereVec.push_back(sphere);
	//Target
	if(state!=inTarget) sphere.color=point(1,0,0); //Red
	else
	{
		double color=exp(-pow(((targetAcquired-trialStart+TIME_OFFSET)-(UPPERBAR+LOWERBAR)/2l)*5l,2));
		sphere.color=point(1l-color,color,0);
	}
	sphere.position=target;
	sphere.radius=tRadius;
	sphereVec.push_back(sphere);
	//Cursor
	sphere.color=point(0,0,1); //Blue
	switch(treatment)
	{
		case UNTREATED:
			sphere.position=cursor;
			break;
		case EA:
			sphere.position=cursor+cursor.linepointvec(origin, target); //That 0 is origin-origin
			break;
		case X2:
			sphere.position=cursor*2-center; //Doubles the distance between the cursor and origin
			break;
	}
	outStream << sphere.position.X() TAB sphere.position.Y() << endl;
	sphere.radius=cRadius;
	sphereVec.push_back(sphere);
	userWidget->setSpheres(sphereVec);
		
	switch(state)
	{
	case acquireTarget:
		if (sphere.position.dist(target)<(tRadius+cRadius)) {state=inTarget; targetAcquired=now;}
		break;
	case inTarget:
		if (sphere.position.dist(target)<(tRadius+cRadius))
		{
			if((now-targetAcquired)>=targetDuration)
			{
				double movetime=targetAcquired-trialStart;
				QString qs1, qs2("Movement Time was ");
				qs1.setNum(movetime);
				times.push_front(movetime+TIME_OFFSET);
				while (times.size()>5) times.erase(times.end());
				userWidget->setBars(times);
				
				if(trial>=1) {target=loadTrial(trial+1);}
				else target=targets->genTarget(sphere.position-center)+center;
				origin=sphere.position;
				state=acquireTarget;
				normal=(target-origin).unit();
				normal=point(-normal.Y(),normal.X());
				leftOrigin=false;
			}
		}
		else state=acquireTarget;
		break;
	}
	
	out=QByteArray(in.data(),sizeof(double));//Copy the timestamp from the input
	switch(stimulus)
	{
	case UNSTIMULATED:
		curl=0;
		saddle=0;
		break;
	case CURL:
		curl=CURLVAL;
		saddle=0;
		break;
	case SADDLE:
		curl=0;
		saddle=SADDLEVAL;
		break;
		
	}
	out.append(reinterpret_cast<char*>(&curl),sizeof(double));
	out.append(reinterpret_cast<char*>(&saddle),sizeof(double));
	//This will require additional appends for other stimuli
	us->writeDatagram(out.data(),out.size(),QHostAddress("192.168.0.2"),25000);
}

void ControlWidget::startClicked()
{
	if(subject>0)
	{
		goGray();
		startButton->setText("Experiment running...");
		char fname[200];
		std::sprintf(fname, "./Data/input%i.dat",subject);
		trialFile.setFileName(fname);
		trialStream.setDevice(&trialFile);
		std::sprintf(fname, "./Data/output%i.dat",subject);
		contFile.setFileName(fname);
		contFile.open(QIODevice::Append);
		outStream.setDevice(&contFile);
		trialStream.setDevice(&trialFile);
		
		
		if(trialFile.exists()) {trialFile.open(QIODevice::ReadOnly); target=loadTrial(trial);}
		else
		{
			//Generate experiment
			//format is: trialStream << trial number TAB treatment TAB stimuli TAB target constraints;
			trialFile.open(QIODevice::WriteOnly);
			bool unshuffled[100];
			bool sporadic[100];
			int perm[100];
			for(int k=0; k<100; k++) unshuffled[k]=(k<=21?true:false);
	
			//30 "warm up" reaches
			for(int k=1; k<=30; k++) trialStream << k TAB UNTREATED TAB UNSTIMULATED TAB false << endl;
			
			//100 "warm up" reaches with sporadic introduction of curl to gauge skill level
			randperm(perm,100);
			for(int k=0; k<100; k++) sporadic[k]=unshuffled[perm[k]];
			noConsecutive(sporadic, 100);
			trialStream << "reset targets 7" << endl;
			for(int k=31; k<=130; k++) trialStream << k TAB UNTREATED TAB (sporadic[k-31]?CURL:UNSTIMULATED) TAB (sporadic[k-31]?true:false) << endl;
			
			//100 treated reaches in curl
			for(int k=131; k<=230; k++) trialStream << k TAB int(treatment) TAB CURL TAB false << endl; //Should be randomized later
			
			//100 treated reaches with sporadic assessment trials that are untreated
			randperm(perm,100);
			for(int k=0; k<100; k++) sporadic[k]=unshuffled[perm[k]];
			noConsecutive(sporadic, 100);
			trialStream << "reset targets 7" << endl;
			for(int k=231; k<=330; k++) trialStream << k TAB (sporadic[k-231]?UNTREATED:int(treatment)) TAB CURL TAB (sporadic[k-231]?true:false) << endl;
			
			//30 untreated curl trials, look at "steady state" final error levels
			trialStream << "reset targets 7" << endl;
			for(int k=331; k<=360; k++) trialStream << k TAB UNTREATED TAB CURL TAB true << endl;
			
			//50 "blank" trials to gauge after-effects
			for(int k=361; k<=410; k++) trialStream << k TAB UNTREATED TAB UNSTIMULATED TAB false << endl;
			
			trialFile.close();
			trialFile.open(QIODevice::ReadOnly);
			trialNumBox->setValue(1);
			target=loadTrial(1);
		}
	}
	else
	{
		trialFile.setFileName("/dev/null");
		trialStream.setDevice(&trialFile);
		contFile.setFileName("/dev/null");
		contFile.open(QIODevice::Append);
		outStream.setDevice(&contFile);
		trialStream.setDevice(&trialFile);	
		target=targets->genTarget(cursor-center)+center;
	}
	ExperimentRunning=true;
	ignoreInput=false;
	zero=getTime(); //Get first time point.
}



void ControlWidget::closeEvent(QCloseEvent *event)
{
	if(ExperimentRunning)
		if(QMessageBox::question(this, tr("For realz?"), tr("Do you really want to shutdown the experiment?"), QMessageBox::Yes| QMessageBox::Cancel)!=QMessageBox::Yes)
		{
			event->ignore();
			return;
		}
	emit(endApp());
	event->accept();
}



point ControlWidget::loadTrial(int T)
{
	trial=T;
	if(trialFile.atEnd()) emit(endApp());
	
	char line[200];
	std::string qline;
	int temptrial, temptreat, tempstim, tempconstrain;
	std::cout << "Loading Trial " << T << std::endl;
	do
	{
		trialFile.readLine(line,200);
		std::cout << line << std::endl;
		if(sscanf(line, "%d\t%d\t%d\t%d",&temptrial,&temptreat,&tempstim,&tempconstrain));
		else
		{
			if(sscanf(line, "reset targets %d",&temptrial)) targets->reset(temptrial);
			else {std::cout << "Complete failure to read line: " << line << std::endl; return point(0,0);}
		}
	} while ((temptrial < T)&&(!trialFile.atEnd()));
	
	stimulus=stimuli(tempstim);
	treatment=treatments(temptreat);
	trialNumBox->setValue(T);
	stimulusBox->setCurrentIndex(tempstim);
	treatmentBox->setCurrentIndex(temptreat);
	std::cout << "Finished Loading Trial " << temptrial << std::endl;	
	return targets->genTarget(cursor-center, tempconstrain)+center;
}

void ControlWidget::noConsecutive(bool * array, int n)
{
	bool swap;
	int r;
	bool fail=false;
	do
	{
		fail=false;
		for(int k=0;k<(n-1);k++)
			if(array[k]&&array[k+1])
			{
				fail = true;
				r=randint(0,n-1);
				swap=array[k];
				array[k]=array[r];
				array[r]=swap;
				break;
			}
	} while(fail);
}



