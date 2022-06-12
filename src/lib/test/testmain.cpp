#include "MyClass.h"
#include <QObject>
#include <QtTest>

class Foo
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
