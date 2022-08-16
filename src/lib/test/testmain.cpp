/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

#include "testmain.h"

void Foo::test1()
{
    mApp::MyClass myclass{"test"};
    QCOMPARE(myclass.appendIt("test"), "test test");
}

QTEST_APPLESS_MAIN(Foo)

#include "testmain.moc"
