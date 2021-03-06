#include "controlwidget.h"
#include <QDesktopWidget>
#include <cstdio>

#define targetDuration .5
#define oRadius min/80
#define calRadius min/40
#define cRadius min/40
#define tRadius min/40
#define TAB << "\t" <<
#define CURLVAL -20  //Should be -20, changed for Justin
#define SADDLEVAL 10
#define TIME_OFFSET .25l
#define initialDirectionTime .1l

ControlWidget::ControlWidget(QDesktopWidget * qdw) : QWidget(qdw->screen(qdw->primaryScreen()))
{
	//Take care of window and input initialization.

	setFocus(); //Foreground window that gets all X input

	center=point((LEFT+RIGHT)/2l,(TOP+BOTTOM)/2l); //Known from direct observation, do not change
	cursor=center;
	origin=center;
	//state=acquireTarget;

	min=(fabs(LEFT-RIGHT)>fabs(TOP-BOTTOM)?fabs(TOP-BOTTOM):fabs(LEFT-RIGHT)); //Screen diameter (shortest dimension) known from direct observation, do not change
	target=point(5,5);

	//Snag a UDP Socket and call a function (readPending) every time there's a new packet.
	ignoreInput=true;
	us=new QUdpSocket(this);
	us->bind(QHostAddress("192.168.1.1"),25000,QUdpSocket::DontShareAddress); //Bind the IP and socket you expect packets to be received from XPC on.
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
	trialNumBox->setMaximum(5000);
	trialNumBox->setMinimum(0);
	grayList.push_back(trialNumBox);
	connect(trialNumBox, SIGNAL(valueChanged(int)), this, SLOT(setTrialNum(int)));

	layout->addRow("Stimulus:",stimulusBox=new QComboBox(this));
	stimulusBox->insertItem(0,"Unstimulated");
	stimulusBox->insertItem(1,"Curl");
	stimulusBox->insertItem(2,"Saddle");
	stimulusBox->insertItem(3,"Rotation 45");
	stimulusBox->insertItem(4,"Rotation Flip");
	grayList.push_back(stimulusBox);
	stimulus=UNSTIMULATED;
	connect(stimulusBox, SIGNAL(activated(int)), this, SLOT(setStimulus(int)));

	layout->addRow("Treatment:",treatmentBox=new QComboBox(this));
	treatmentBox->insertItem(0,"Unstimulated");
	treatmentBox->insertItem(1,"EA");
	treatmentBox->insertItem(2,"2X");
	treatmentBox->insertItem(3,"EA: Adaptive");
	grayList.push_back(treatmentBox);
	treatment=UNTREATED;
	connect(treatmentBox, SIGNAL(activated(int)), this, SLOT(setTreatment(int)));

	layout->addRow(tr("Added Delay:"), delayBox=new QDoubleSpinBox(this));
	delayBox->setValue(0);
	delayBox->setMaximum(2);
	delayBox->setMinimum(0);
	delayBox->setDecimals(3);
	visualdelay=-1;
	connect(delayBox, SIGNAL(valueChanged(double)), this, SLOT(setDelay(double)));

	layout->addRow(tr("Adaptive EA:"), adaptiveBox=new QDoubleSpinBox(this));
	adaptiveBox->setValue(0);
	adaptiveBox->setMaximum(20);
	adaptiveBox->setMinimum(-1);
	adaptiveBox->setDecimals(3);
	adaptive=0;
	connect(adaptiveBox, SIGNAL(valueChanged(double)), this, SLOT(setAdaptive(double)));


	setLayout(layout);


	QRect geo=qdw->screenGeometry();
	geo.setWidth(2*geo.width()/3);
	geo.setHeight(4*geo.height()/5);
	geo.translate(80,80);
	setGeometry(geo);

	int notprimary=qdw->primaryScreen()==0?1:0;
	userWidget=new DisplayWidget(qdw->screen(notprimary), (qdw->screenCount()>1)?true:false);
	userWidget->setGeometry(qdw->screenGeometry(notprimary));
	userWidget->show();

	sphereVec.clear();
	sphere.color=point(0,.5,0);
	sphere.position=center;
	sphere.radius=min;
	sphereVec.push_back(sphere);
	sphere.color=point(.5,.5,.5);
	sphere.position=center;
	sphere.radius=min/2l;
	sphereVec.push_back(sphere);
	sphere.color=point(1,0,0);
	sphere.position=center;
	sphere.radius=calRadius;
	sphereVec.push_back(sphere);
	point unit(1,0);
	for(double k=0;k<4;k++)
	{
		sphere.color=point(1,0,0);
		sphere.position=center+unit.rotateZero(k*3.14159l/2l)*(min/2l);
		sphere.radius=calRadius;
		sphereVec.push_back(sphere);
	}
	sphere.color=point(.5,.5,.5); //Grey
	sphere.position=point(LEFT,TOP);
	sphere.radius=calRadius;
	sphereVec.push_back(sphere);
	sphere.color=point(.5,.5,.5); //Grey
	sphere.position=point(LEFT,BOTTOM);
	sphere.radius=calRadius;
	sphereVec.push_back(sphere);
	sphere.color=point(.5,.5,.5); //Grey
	sphere.position=point(RIGHT,TOP);
	sphere.radius=calRadius;
	sphereVec.push_back(sphere);
	sphere.color=point(.5,.5,.5); //Grey
	sphere.position=point(RIGHT,BOTTOM);
	sphere.radius=calRadius;
	sphereVec.push_back(sphere);
	
	
	/* double mcorr=min-.02l;
	point temp;
	for(double k=0;k<2*3.14159l;k+=.01)
	{
		sphere.color=point(0,0,1);
		temp=unit.rotateZero(k);
		temp.Y()+=.4l;
		sphere.position=temp*(mcorr/1.5l)*.6l+center-point(0,mcorr/6l);
		sphere.radius=calRadius;
		sphereVec.push_back(sphere);
	} */
	userWidget->setSpheres(sphereVec);
	
	double mcorr=min-.02l;
	for(double k=0;k<3.14159l;k+=.01)
	{
		sphere.color=point(.8,.8,.8);
		sphere.position=unit.rotateZero(k)*(mcorr/1.5l)+center-point(0,mcorr/6l);
		sphere.radius=calRadius;
		sphereVec.push_back(sphere);
	}

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
		case ROTATION45:
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
		default:
			curl=0;
			saddle=0;
			break;
		}
		out.append(reinterpret_cast<char*>(&curl),sizeof(double));
		out.append(reinterpret_cast<char*>(&saddle),sizeof(double));
		//This will require additional appends for other stimuli
		us->writeDatagram(out.data(),out.size(),QHostAddress("192.168.1.2"),25000);
		return;
	}

	times.push_back(now);
	data.push_back(in);
	bool old_enough=false;
	while((now-times.front())>visualdelay)
	{
		times.pop_front();
		in=data.front();
		data.pop_front();
		old_enough=true;
		if (times.empty())
			break;
	}
	if(!old_enough) return;

	cursor.X()=*reinterpret_cast<double*>(in.data()+sizeof(double));
	cursor.Y()=*reinterpret_cast<double*>(in.data()+2*sizeof(double));
	velocity.X()=*reinterpret_cast<double*>(in.data()+3*sizeof(double));
	velocity.Y()=*reinterpret_cast<double*>(in.data()+4*sizeof(double));
	accel.X()=*reinterpret_cast<double*>(in.data()+5*sizeof(double));
	accel.Y()=*reinterpret_cast<double*>(in.data()+6*sizeof(double));


	outStream << trial TAB now-zero TAB cursor.X() TAB cursor.Y() TAB velocity.X() TAB velocity.Y() TAB accel.X() TAB accel.Y() TAB origin.X() TAB origin.Y() TAB target.X() TAB target.Y() << "\t";

	if (!leftOrigin) trialStart=now;
	if(!leftOrigin) if (cursor.dist(origin)>(oRadius+cRadius)) leftOrigin=true;
	if ((treatment==EA_ADAPTIVE)&leftOrigin&!initialdirectionnoted) 
		if ((now-trialStart)>initialDirectionTime)
		{
			initialdirectionnoted=true;
			initialdirectionerror.push_back(atan2(cursor.Y()-origin.Y(),cursor.X()-origin.X())-atan2(target.Y()-origin.Y(),target.X()-origin.X()));
			while(initialdirectionerror.size()>6) initialdirectionerror.pop_front();
			if (initialdirectionerror.size()==6)
			{
				double newer=(initialdirectionerror[6]+initialdirectionerror[5]+initialdirectionerror[4]);
				double older=(initialdirectionerror[3]+initialdirectionerror[2]+initialdirectionerror[1]);
				double delta_ide=(newer-older)/newer;
				if (delta_ide>.1) adaptive--;
				else if(delta_ide<-.0909) adaptive++;
				if (adaptive<-1) adaptive=-1;
				adaptiveBox->setValue(adaptive/10);
			}
		}

	sphereVec.clear();
	//Target
	if(state!=inTarget) sphere.color=point(1,0,0); //Red
	else
	{
		double acquire_time=targetAcquired-trialStart+TIME_OFFSET;
		//double color=exp(-pow(((targetAcquired-trialStart+TIME_OFFSET)-(UPPERBAR+LOWERBAR)/2l)*5l,2));
		//sphere.color=point(1l-color,color,0);
		if (acquire_time<LOWERBAR) sphere.color=point(1,1,0);
		else if (acquire_time>UPPERBAR) sphere.color=point(1,1,1);
		else sphere.color=point(0,1,0);
	}
	sphere.position=target;
	sphere.radius=tRadius;
	sphereVec.push_back(sphere);
	//Cursor
	sphere.color=point(0,0,1); //Blue
	
	point temp;
	switch(stimulus)
	{
		case ROTATION45:
			cursor=(cursor-center).rotateZero(-3.14159l/4l)+center;
			break;
		case ROTATIONFLIP:
			temp=cursor-center;
			cursor=point((temp.X()+temp.Y())/2l,(temp.X()-temp.Y())/2l)+center;
			break;
		default:
			break;
	}

	switch(treatment)
	{
		case UNTREATED:
			sphere.position=cursor;
			break;
		case EA:
			sphere.position=cursor+cursor.linepointvec(origin, target); 
			//cursor + the vector that points from the line intersecting both origin and target to the cursor.
			break;
		case EA_ADAPTIVE:
			sphere.position=cursor+cursor.linepointvec(origin, target)*(.1l*adaptive);
			break;
		case X2:
			double mcorr=min-.02l;
			sphere.position=cursor*2-(center-point(0,mcorr/6l));
			//sphere.position=cursor*2-center;  //About zero. 
			//Doubles the distance between the cursor and origin ONLY makes sense in the context of center-out reaching
			break;
	}
	outStream << sphere.position.X() TAB sphere.position.Y() TAB adaptive << endl;
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
				/* double movetime=targetAcquired-trialStart;
				QString qs1, qs2("Movement Time was ");
				qs1.setNum(movetime);
				times.push_front(movetime+TIME_OFFSET);
				while (times.size()>5) times.erase(times.end());
				userWidget->setBars(times); */

				if(trial>=1) {target=loadTrial(trial+1);}
				else target=(target==(point(0,0)+center)?point(0,min/3)+center:point(0,0)+center);
				origin=sphere.position;
				state=acquireTarget;
				leftOrigin=false;
			}
		}
		else state=acquireTarget;
		break;
	}

	out=QByteArray(in.data(),sizeof(double));//Copy the timestamp from the input
	switch(stimulus)
	{
	case ROTATION45:
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
	default:
		curl=0;
		saddle=0;
		break;
	}
	out.append(reinterpret_cast<char*>(&curl),sizeof(double));
	out.append(reinterpret_cast<char*>(&saddle),sizeof(double));
	//This will require additional appends for other stimuli
	us->writeDatagram(out.data(),out.size(),QHostAddress("192.168.1.2"),25000);
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
			QMessageBox::critical(this, "File Not Found!", "File not found, please select a different file.");
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
		target=center;
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
	initialdirectionnoted=false;
	if(trialFile.atEnd()) emit(endApp());

	char line[201];
	std::string qline;
	int temptrial, temptreat, tempstim;
	double tempx, tempy, tempdelay;
	std::cout << "Loading Trial " << T << std::endl;
	do
	{
		trialFile.readLine(line,200);
		std::cout << line << std::endl;
		if(sscanf(line, "%d\t%d\t%d\t%lf\t%lf\t%lf",&temptrial,&temptreat,&tempstim,&tempx,&tempy,&tempdelay));
		else
		{
			std::cout << "Complete failure to read line: " << line << std::endl; return center;
		}
	} while ((temptrial < T)&&(!trialFile.atEnd()));
	visualdelay=tempdelay;
	stimulus=stimuli(tempstim);
	point temppoint=point(tempx,-tempy);
	//Lines were accomodating 2x vc vs 2x hc, but this is dumb.  Should change in input files
	//if (temptreat==3) {temptreat=2; temppoint*=2;} 
	//if (temptreat==4) {temptreat=0; temppoint/=2l;}
	treatment=treatments(temptreat);
	trialNumBox->setValue(T);
	stimulusBox->setCurrentIndex(tempstim);
	treatmentBox->setCurrentIndex(temptreat);
	delayBox->setValue(visualdelay);
	std::cout << "Finished Loading Trial " << temptrial << std::endl;
	double mcorr=min-.02l;
	return temppoint*(mcorr/1.5l)+center-point(0,mcorr/6l-0.05l);
}
