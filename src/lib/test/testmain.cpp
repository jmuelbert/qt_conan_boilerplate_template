

#include "testMain.h"

void Foo::test1()
{
  mApp::MyClass myclass{ "test" };
  QCOMPARE(myclass.appendIt("test"), "test test");
}

QTEST_APPLESS_MAIN(Foo)

#include "testmain.moc"
