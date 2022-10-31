/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

#pragma once

#include <QObject>
#include <QtTest>

#include "qtwidgettestlib/MyClass.h"

class Foo : public QObject
{
    Q_OBJECT

private slots:
    static void test1();
};
