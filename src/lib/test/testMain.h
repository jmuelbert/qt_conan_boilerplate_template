
#include "MyClass.h"
#include <QObject>
#include <QtTest>

class Foo : public QObject
{
  Q_OBJECT

private slots:
  void test1();
};
