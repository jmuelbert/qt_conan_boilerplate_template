/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

#include "myclass/MyClass.h"

namespace mApp {

MyClass::MyClass(const QString &text) : _text(text) { qDebug("Init text"); }

QString MyClass::appendIt(const QString &extra) const { return _text + " " + extra; }

QString MyClass::text() const
{
  // this block is purposely left untested to make sure
  // coverage never reports 100%
  return _text;
}

}// namespace mApp
