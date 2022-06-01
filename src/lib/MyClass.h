#pragma once

#include <QString>
#include <string>

namespace mApp {

class MyClass
{
  QString _text;

public:
  explicit MyClass(const QString &text);

  QString appendIt(const QString &extra) const;
  QString text() const;
};

}// namespace mApp
