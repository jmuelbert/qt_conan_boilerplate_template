#pragma once

#include <QObject>
#include <QtTest>

#include "myclass/MyClass.h"

class Foo : public QObject
{
  Q_OBJECT

private slots:
  void test1();
};
