######################################################################
# Automatically generated by qmake (2.01a) Sat Nov 22 17:22:58 2008
######################################################################

TEMPLATE = app
TARGET = manipulandumDisplay
DEPENDPATH += . 
INCLUDEPATH += .
QT += opengl network
CONFIG += debug
LIBS += -lm
#CUDA_DIR = $$system(which nvcc | sed 's,/bin/nvcc$,,')
#INCLUDEPATH += $$CUDA_DIR/include
#QMAKE_LIBDIR += $$CUDA_DIR/lib
 
# Input
HEADERS += displaywidget.h timestuff.h point.h targetcontrol.h randb.h controlwidget.h
SOURCES += main.cpp displaywidget.cpp timestuff.cpp targetcontrol.cpp randb.cpp controlwidget.cpp
