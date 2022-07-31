/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

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
