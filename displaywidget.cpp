#include "displaywidget.h"
#include <GL/glu.h>
#include <cmath>

#define LEFTBAR .1l*LEFT+.9l*RIGHT

#include <iostream>

bool gluInvertMatrix(const double m[16], double invOut[16])
{
double inv[16], det;
int i;

inv[0] =   m[5]*m[10]*m[15] - m[5]*m[11]*m[14] - m[9]*m[6]*m[15]
+ m[9]*m[7]*m[14] + m[13]*m[6]*m[11] - m[13]*m[7]*m[10];
inv[4] =  -m[4]*m[10]*m[15] + m[4]*m[11]*m[14] + m[8]*m[6]*m[15]
- m[8]*m[7]*m[14] - m[12]*m[6]*m[11] + m[12]*m[7]*m[10];
inv[8] =   m[4]*m[9]*m[15] - m[4]*m[11]*m[13] - m[8]*m[5]*m[15]
+ m[8]*m[7]*m[13] + m[12]*m[5]*m[11] - m[12]*m[7]*m[9];
inv[12] = -m[4]*m[9]*m[14] + m[4]*m[10]*m[13] + m[8]*m[5]*m[14]
- m[8]*m[6]*m[13] - m[12]*m[5]*m[10] + m[12]*m[6]*m[9];
inv[1] =  -m[1]*m[10]*m[15] + m[1]*m[11]*m[14] + m[9]*m[2]*m[15]
- m[9]*m[3]*m[14] - m[13]*m[2]*m[11] + m[13]*m[3]*m[10];
inv[5] =   m[0]*m[10]*m[15] - m[0]*m[11]*m[14] - m[8]*m[2]*m[15]
+ m[8]*m[3]*m[14] + m[12]*m[2]*m[11] - m[12]*m[3]*m[10];
inv[9] =  -m[0]*m[9]*m[15] + m[0]*m[11]*m[13] + m[8]*m[1]*m[15]
- m[8]*m[3]*m[13] - m[12]*m[1]*m[11] + m[12]*m[3]*m[9];
inv[13] =  m[0]*m[9]*m[14] - m[0]*m[10]*m[13] - m[8]*m[1]*m[14]
+ m[8]*m[2]*m[13] + m[12]*m[1]*m[10] - m[12]*m[2]*m[9];
inv[2] =   m[1]*m[6]*m[15] - m[1]*m[7]*m[14] - m[5]*m[2]*m[15]
+ m[5]*m[3]*m[14] + m[13]*m[2]*m[7] - m[13]*m[3]*m[6];
inv[6] =  -m[0]*m[6]*m[15] + m[0]*m[7]*m[14] + m[4]*m[2]*m[15]
- m[4]*m[3]*m[14] - m[12]*m[2]*m[7] + m[12]*m[3]*m[6];
inv[10] =  m[0]*m[5]*m[15] - m[0]*m[7]*m[13] - m[4]*m[1]*m[15]
+ m[4]*m[3]*m[13] + m[12]*m[1]*m[7] - m[12]*m[3]*m[5];
inv[14] = -m[0]*m[5]*m[14] + m[0]*m[6]*m[13] + m[4]*m[1]*m[14]
- m[4]*m[2]*m[13] - m[12]*m[1]*m[6] + m[12]*m[2]*m[5];
inv[3] =  -m[1]*m[6]*m[11] + m[1]*m[7]*m[10] + m[5]*m[2]*m[11]
- m[5]*m[3]*m[10] - m[9]*m[2]*m[7] + m[9]*m[3]*m[6];
inv[7] =   m[0]*m[6]*m[11] - m[0]*m[7]*m[10] - m[4]*m[2]*m[11]
+ m[4]*m[3]*m[10] + m[8]*m[2]*m[7] - m[8]*m[3]*m[6];
inv[11] = -m[0]*m[5]*m[11] + m[0]*m[7]*m[9] + m[4]*m[1]*m[11]
- m[4]*m[3]*m[9] - m[8]*m[1]*m[7] + m[8]*m[3]*m[5];
inv[15] =  m[0]*m[5]*m[10] - m[0]*m[6]*m[9] - m[4]*m[1]*m[10]
+ m[4]*m[2]*m[9] + m[8]*m[1]*m[6] - m[8]*m[2]*m[5];

det = m[0]*inv[0] + m[1]*inv[4] + m[2]*inv[8] + m[3]*inv[12];
if (det == 0)
        return false;

det = 1.0 / det;

for (i = 0; i < 16; i++)
        invOut[i] = inv[i] * det;

return true;
}

DisplayWidget::DisplayWidget(QWidget *parent,bool FullScreen)
:QGLWidget(QGLFormat(QGL::DoubleBuffer|QGL::AlphaChannel|QGL::SampleBuffers|QGL::AccumBuffer), parent, 0, FullScreen?Qt::X11BypassWindowManagerHint:Qt::Widget)
{
	//Take care of window and input initialization.
	timer.start(16, this); //Draw again shortly after constructor finishes
	if(FullScreen)
	{
		setWindowState(Qt::WindowFullScreen); 
		setCursor(QCursor(Qt::BlankCursor)); //Hide the cursor
		raise(); //Make sure it's the top window
	}
	setPalette(QPalette(QColor(0, 0, 0))); //IF the background draws, draw it black.
	setAutoFillBackground(false); //Try to let glClear work...
	setAutoBufferSwap(false); //Don't let QT swap automatically, we want to control timing.
	backgroundColor=point(0,0,0);
	min=.4436;
}

DisplayWidget::~DisplayWidget()
{
	makeCurrent();
	glDeleteLists(sphereList,1);
}

void DisplayWidget::initializeGL()
{  
	glClearColor(0,0,0,1);
	glClear(GL_COLOR_BUFFER_BIT);
	glShadeModel(GL_FLAT);
	sphereList = glGenLists (1);
	GLUquadricObj *qobj=gluNewQuadric();
	gluQuadricDrawStyle(qobj, GLU_FILL);
	glNewList(sphereList, GL_COMPILE);
	gluSphere(qobj, 1, 100, 100); //Arbitrary defaults "grid" size: 100 x 100		
	glEndList();
	
	glEnable(GL_POINT_SMOOTH);
	glPointSize(1);
}

void DisplayWidget::resizeGL(int w, int h)
{
	W=w; H=h;
	glViewport(0,0, w, h);
	glMatrixMode(GL_PROJECTION);
	//gluPerspective(asin(fabs(TOP-BOTTOM)/1.39)*180l/3.13159l, fabs(LEFT-RIGHT)/fabs(TOP-BOTTOM), 0, 1);
	//gluLookAt(-.099194,.5955l,1.39l,0l,.456l,0l,0l,-1l,0l);
	//double projection[16], iprojection[16];
	//glGetDoublev(GL_PROJECTION_MATRIX, projection);
	//gluInvertMatrix(projection, iprojection);
	//glLoadIdentity();
	glOrtho(LEFT,RIGHT,BOTTOM,TOP,1,-1);
	//glMultMatrixd(iprojection);
	//glLoadMatrixd(iprojection);
	update();
}

void DisplayWidget::paintGL()
{
	timer.stop();
	dataMutex.lock();
	glClearColor(backgroundColor.X(), backgroundColor.Y(), backgroundColor.Z(),1);
	glClear(GL_COLOR_BUFFER_BIT);
	glShadeModel(GL_FLAT);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); 
	
	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POLYGON_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	
	for(std::vector<Sphere>::iterator it=spheres.begin();it!=spheres.end();++it)
	{
		if(it->radius<=0) continue;
		glColor3dv(it->color);
		glPushMatrix();
		glTranslated(it->position.X(),it->position.Y(),it->position.Z());
		glScaled(it->radius,it->radius,it->radius);
		glCallList(sphereList);
		glPopMatrix();
	}
	
	glColor3d(1,1,1);
	renderText(LEFT,.39,0, text);
	
	//Goal is to allocate the rightmost 10th of the screen, draw rectangles with 1:height scaling
	//Color should be green in band, fade to red outside it
	//Band is purple
	double barwidth=.1*(RIGHT-LEFTBAR)/double(times.size());
	double left=LEFTBAR;
	for(std::deque<double>::iterator it=times.begin();it!=times.end();++it)
	{
		double sat=exp(-pow((*it-(UPPERBAR+LOWERBAR)/2l)*5l,2));
		glColor3d(1l-sat,sat,0);
		glRectd(left,BOTTOM,left+barwidth,*it*(TOP-BOTTOM)+BOTTOM);
		left+=barwidth;
	}
	if (times.size()>0)
	{
		glColor3d(1,0,1);
		glRectd(LEFTBAR,BOTTOM+LOWERBAR*(TOP-BOTTOM)-.001,RIGHT,BOTTOM+LOWERBAR*(TOP-BOTTOM)+.001);
		glRectd(LEFTBAR,BOTTOM+UPPERBAR*(TOP-BOTTOM)-.001,RIGHT,BOTTOM+UPPERBAR*(TOP-BOTTOM)+.001);
	}
	
	dataMutex.unlock();
	swapBuffers();
	glFinish();  //Get precise timing, blocks until swap succeeds.  Swap happens during refresh.
	timer.start(15, this); //60 Hz = 16.6 ms, guarantee a paint in each refresh and almost immediately before refresh to minimize lag.
}

