# -*- coding: utf-8 -*-
#
# SPDX-FileCopyrightText:
#       2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#

import os
import re

from conan import ConanFile
from conan.errors import ConanInvalidConfiguration
from conan.tools.build import check_min_cppstd
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from conan.tools.files import copy, load, rmdir
from conan.tools.scm import Version

required_conan_version = ">=1.50.0"


class QtTestConan(ConanFile):
    name = "qt_test"

    # Optional metadata
    license = "EUPL-1.2"
    author = "Jürgen Mülbert"
    url = "https://github.com/jmuelbert/qt-conan_boilerplate_template"
    description = "<Description of QtTest here>"
    topics = ("qt_biolerpalte", "conan", "qt6")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = dict(
        {
            "shared": [True, False],
            "fPIC": [True, False],
            "build_docs": [True, False],
            "build_tests": [True, False],
        }
    )

    default_options = dict(
        {"shared": False, "fPIC": True, "build_docs": True, "build_tests": True}
    )

    # Sources are located in the same place as this recipe,
    # copy them to the recipe
    exports = ["LICENSE"]
    exports_sources = [
        "docs/*",
        "src/*",
        "test/*",
        "cmake/*",
        "example/*",
        "CMakeLists.txt",
    ]

    no_copy_source = True
    generators = "CMakeDeps", "CMakeToolchain"
    #   "cmake", "cmake_find_package",

    @property
    def _use_libfmt(self):
        compiler = self.settings.compiler
        version = Version(self.settings.compiler.version)
        std_support = (
            compiler == "Visual Studio" and version >= 17 and compiler.cppstd == 23
        ) or (compiler == "msvc" and version >= 193 and compiler.cppstd == 23)
        return not std_support

    @property
    def _use_range_v3(self):
        compiler = self.settings.compiler
        version = Version(self.settings.compiler.version)
        return "clang" in compiler and compiler.libcxx == "libc++" and version < 14

    @property
    def _msvc_version(self):
        compiler = self.settings.compiler
        if compiler.update:
            return int(f"{compiler.version}{compiler.update}")
        else:
            return int(f"{compiler.version}0")

    def set_version(self):
        content = load(self, os.path.join(self.recipe_folder, "CMakeLists.txt"))
        version = re.search(
            r"project\([^\)]+VERSION (\d+\.\d+\.\d+)[^\)]*\)", content
        ).group(1)
        self.version = version.strip()

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

        self.options["qt"].shared = True
        self.options["qt"].qttranslations = True

    def requirements(self):
        self.requires("spdlog/1.11.0")
        self.requires("extra-cmake-modules/5.93.0")

        if self._use_libfmt:
            self.requires("fmt/9.1.0")

        qtDir = os.environ.get("Qt6_Dir")
        if qtDir == 0:
            self.requires("qt/6.3.1")

    def build_requirements(self):
        if self.options.build_tests:
            self.test_requires("gtest/cci.20210126")
            self.test_requires("doctest/2.4.9")
            self.test_requires("catch2/3.1.0")
        # if self.options.build_docs:
        #    self.tool_requires("doxygen/1.9.4")

    # TODO Replace with `valdate()` for Conan 2.0 (https://github.com/conan-io/conan/issues/10723)
    def configure(self):
        compiler = self.settings.compiler
        version = Version(self.settings.compiler.version)
        if compiler == "gcc":
            if version < 10:
                raise ConanInvalidConfiguration("project requires at least g++-10")
        elif compiler == "clang":
            if version < 12:
                raise ConanInvalidConfiguration("project requires at least clang++-12")
        elif compiler == "apple-clang":
            if version < 13:
                raise ConanInvalidConfiguration(
                    "project requires at least AppleClang 13"
                )
        elif compiler == "Visual Studio":
            if version < 16:
                raise ConanInvalidConfiguration(
                    "project requires at least Visual Studio 16.9"
                )
        elif compiler == "msvc":
            if self._msvc_version < 1928:
                raise ConanInvalidConfiguration("project requires at least MSVC 19.28")
        else:
            raise ConanInvalidConfiguration("Unsupported compiler")
        check_min_cppstd(self,17)

    def layout(self):
        cmake_layout(self)

    def generate(self):
        # This generates "conan_toolchain.cmake" in self.generators_folder
        tc = CMakeToolchain(self)
        tc.variables["MYVAR"] = "1"
        tc.variables["ENABLE_BUILD_DOCS"] = self.options.build_docs
        tc.variables["ENABLE_USE_LIBFMT"] = self._use_libfmt
        tc.generate()

        # This generates "foo-config.cmake" and "bar-config.cmake" in self.generators_folder
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        if self.settings.build_type == "Debug":
            self.options.tests = true

        cmake.configure(build_script_folder=None if self.options.build_tests else "src")
        cmake.build()
        if self.options.build_tests:
            cmake.test()

    def package_id(self):
        self.info.clear()

    def package(self):
        copy(
            self,
            "LICENSE",
            self.source_folder,
            os.path.join(self.package_folder, "licenses"),
        )
        cmake = CMake(self)
        cmake.install()
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))

    def package_info(self):
        # compiler = self.settings.compiler
        self.cpp_info.names["generator_name"] = "<PKG_NAME>"
        self.cpp_info.includedirs = ["include"]  # Ordered list of include paths
        self.cpp_info.libs = []  # The libs to link against
        self.cpp_info.system_libs = []  # System libs to link against
        self.cpp_info.libdirs = ["lib"]  # Directories where libraries can be found
        self.cpp_info.resdirs = [
            "res"
        ]  # Directories where resources, data, etc. can be found
        self.cpp_info.bindirs = [
            "bin"
        ]  # Directories where executables and shared libs can be found
        self.cpp_info.srcdirs = (
            []
        )  # Directories where sources can be found (debugging, reusing sources)
        self.cpp_info.build_modules = {}  # Build system utility module files
        self.cpp_info.defines = []  # preprocessor definitions
        self.cpp_info.cflags = []  # pure C flags
        self.cpp_info.cxxflags = []  # C++ compilation flags
        self.cpp_info.sharedlinkflags = []  # linker flags
        self.cpp_info.exelinkflags = []  # linker flags
        self.cpp_info.components  # Dictionary with the different components a package may have
        self.cpp_info.requires = None  # List of components from requirements
