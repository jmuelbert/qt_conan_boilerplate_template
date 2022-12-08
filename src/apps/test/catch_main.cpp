/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

#include <catch2/catch_session.hpp>

int main(int argc, char *argv[])
{
    // your setup ...

    int result = Catch::Session().run(argc, argv);

    // your clean-up...

    return result;
}
