#pragma once

#include <QString>
#include <string>

namespace mApp {

class MyClass
{
  QString _text;

public:
  explicit MyClass(const QString &text);

  [[nodiscard]] QString appendIt(const QString &extra) const;
  [[nodiscard]] QString text() const;
};

}// namespace mApp
