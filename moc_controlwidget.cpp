/****************************************************************************
** Meta object code from reading C++ file 'controlwidget.h'
**
** Created: Thu Oct 28 19:01:54 2010
**      by: The Qt Meta Object Compiler version 62 (Qt 4.6.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "controlwidget.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'controlwidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 62
#error "This file was generated using the moc from 4.6.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_ControlWidget[] = {

 // content:
       4,       // revision
       0,       // classname
       0,    0, // classinfo
       7,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      15,   14,   14,   14, 0x05,

 // slots: signature, parameters, type, tag, flags
      24,   14,   14,   14, 0x0a,
      38,   14,   14,   14, 0x0a,
      55,   53,   14,   14, 0x0a,
      72,   53,   14,   14, 0x0a,
      88,   53,   14,   14, 0x0a,
     106,   53,   14,   14, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_ControlWidget[] = {
    "ControlWidget\0\0endApp()\0readPending()\0"
    "startClicked()\0i\0setTrialNum(int)\0"
    "setSubject(int)\0setTreatment(int)\0"
    "setStimulus(int)\0"
};

const QMetaObject ControlWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_ControlWidget,
      qt_meta_data_ControlWidget, 0 }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &ControlWidget::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *ControlWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *ControlWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_ControlWidget))
        return static_cast<void*>(const_cast< ControlWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int ControlWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: endApp(); break;
        case 1: readPending(); break;
        case 2: startClicked(); break;
        case 3: setTrialNum((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 4: setSubject((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: setTreatment((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 6: setStimulus((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
        _id -= 7;
    }
    return _id;
}

// SIGNAL 0
void ControlWidget::endApp()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}
QT_END_MOC_NAMESPACE
