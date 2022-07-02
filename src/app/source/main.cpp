#include <functional>
#include <iostream>
#include <optional>

#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>

#include <QApplication>
#include <QLocale>
#include <QTranslator>

#include "qtwidgettest/mainwindow.h"

#include "qtconanboilerplate/qtconanboilerplate-version.h"

int main(int argc, char *argv[])
{
  try {
    CLI::App cliApp{ fmt::format("{} version {}", QTCONANBOILERPLATE_PROJECT_NAME, QTCONANBOILERPLATE_VERSION) };

    std::optional<std::string> message;
    cliApp.add_option("-m,--message", message, "A message to print back out");
    bool show_version = false;
    cliApp.add_flag("--version", show_version, "Show version information");

    CLI11_PARSE(cliApp, argc, argv);

    if (show_version) {
      fmt::print("{}\n", QTCONANBOILERPLATE_VERSION);
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
