#include "MyClass.h"
#include <QtTest>

class Foo : public QObject
{
  Q_OBJECT

private slots:
  void test1();
};

void Foo::test1()
{
  mApp::MyClass myclass{ "test" };
  QCOMPARE(myclass.appendIt("test"), "test test");
}

QTEST_APPLESS_MAIN(Foo)

#include "testmain.moc"
