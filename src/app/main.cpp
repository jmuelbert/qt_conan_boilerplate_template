#include <functional>
#include <iostream>
#include <optional>

#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>

#include <QApplication>
#include <QLocale>
#include <QTranslator>

// This file will be generated automatically when you run the CMake configuration step.
// It creates a namespace called `myproject`.
// You can modify the source template at `configured_files/config.hpp.in`.
#include <internal_use_only/config.hpp>

#include "mainwindow.h"

int main(int argc, char *argv[])
{
  try {
    CLI::App cliApp{ fmt::format("{} version {}", myproject::cmake::project_name, myproject::cmake::project_version) };

    std::optional<std::string> message;
    cliApp.add_option("-m,--message", message, "A message to print back out");
    bool show_version = false;
    cliApp.add_flag("--version", show_version, "Show version information");

    CLI11_PARSE(cliApp, argc, argv);

    if (show_version) {
      fmt::print("{}\n", myproject::cmake::project_version);
      return EXIT_SUCCESS;
    }

    // Use the default logger (stdout, multi-threaded, colored)
    spdlog::info("Hello, {}!", "World");

    if (message) {
      fmt::print("Message: '{}'\n", *message);
    } else {
      fmt::print("No Message Provided :(\n");
    }
  } catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
  }

  QApplication app(argc, argv);

  QTranslator translator;
  const QStringList uiLanguages = QLocale::system().uiLanguages();
  for (const QString &locale : uiLanguages) {
    const QString baseName = "QtWidgetTest_" + QLocale(locale).name();
    if (translator.load(":/i18n/" + baseName)) {
      app.installTranslator(&translator);
      break;
    }
  }
  MainWindow appWindow;
  appWindow.show();
  return app.exec();
}
