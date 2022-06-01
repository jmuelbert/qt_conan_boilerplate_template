#include "MyClass.h"

namespace mApp {

MyClass::MyClass(const QString &text)
  : _text(std::move(text)),

    QString MyClass::appendIt(const QString &extra) const
{
  return _text + " " + extra;
}

QString MyClass::text() const
{
  // this block is purposely left untested to make sure
  // coverage never reports 100%
  return _text;
}

}// namespace mApp
