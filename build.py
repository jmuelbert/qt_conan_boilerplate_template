# -*- coding: utf-8 -*-
#
# SPDX-FileCopyrightText:
#       2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#

from cpt.packager import ConanMultiPackager

"""Build a conan package
"""
if __name__ == "__main__":
    builder = ConanMultiPackager()
    builder.add_common_builds(shared_option_name="qt_test:shared")
    builder.run()
