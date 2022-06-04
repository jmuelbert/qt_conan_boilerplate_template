import os
import re

from conan import ConanFile
from conan.tools.files import save, load, copy, rmdir
from conan.tools.gnu import AutotoolsToolchain, AutotoolsDeps
from conan.tools.microsoft import unix_path, VCVars, is_msvc
from conan.errors import ConanInvalidConfiguration
from conan.errors import ConanException
from conan.tools.cmake import CMakeToolchain, CMakeDeps, CMake, cmake_layout
from conan.tools.scm import Version

# TODO replace with new tools for Conan 2.0
from conans.tools import check_min_cppstd, get_env

required_conan_version = ">=1.48.0"

class QtTestConan(ConanFile):
    name = "qt_test"
    version = "0.0.1"

    # Optional metadata
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of QtTest here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "build_docs": [True, False]
    }

    default_options = {
        "shared": False,
        "fPIC": True,
        "build_docs": True
    }

    # Sources are located in the same place as this recipe, copy them to the recipe
    exports = ["LICENSE"]
    exports_sources = "CMakeLists.txt", "src/*", "include/*"

    no_copy_source = True
    # generators = "CMake CMakeDeps"

    @property
    def _run_tests(self):
        return get_env("CONAN_RUN_TESTS", False)

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
        content = load(self, os.path.join(self.recipe_folder, "src/CMakeLists.txt"))
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
        self.requires("cli11/2.2.0")
        self.requires("spdlog/1.10.0")
        self.requires("fmt/8.1.1")
        self.requires("qt/6.3.0")

    def build_requirements(self):

        if self.options.build_docs:
            self.tool_requires("doxygen/1.9.4")

        self.test_requires("gtest/cci.20210126")
        self.test_requires("doctest/2.4.8")
        self.test_requires("catch2/2.13.9")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        # This generates "conan_toolchain.cmake" in self.generators_folder
        tc = CMakeToolchain(self)
        tc.variables["MYVAR"] = "1"
        tc.variables["ENABLE_BUILD_DOCS"] = bool(self.options.build_docs)
        tc.variables["UNITS_USE_LIBFMT"] = self._use_libfmt
        tc.generate()

        # This generates "foo-config.cmake" and "bar-config.cmake" in self.generators_folder
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure(build_script_folder=None if self._run_tests else "src")
        cmake.build()
        if self._run_tests:
            cmake.test()

    def package_id(self):
        self.info.header_only()

    def package(self):
        copy(
            self,
            "LICENSE.md",
            self.source_folder,
            os.path.join(self.package_folder, "licenses"),
        )
        cmake = CMake(self)
        cmake.install()
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))

    def package_info(self):
        pass