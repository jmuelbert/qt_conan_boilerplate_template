#include <QtCore/qcoreapplication.h>
#include <functional>
#include <iostream>
#include <optional>

#include <spdlog/spdlog.h>

#include <QApplication>
#include <QCommandLineParser>
#include <QLocale>
#include <QTranslator>

#include "qtwidgettest/mainwindow.h"

#include "qtconanboilerplate/qtconanboilerplate-version.h"

int main(int argc, char *argv[])
{
  //   std::optional<std::string> message;

  //   // Use the default logger (stdout, multi-threaded, colored)
  //   spdlog::info("Hello, {}!", "World");

  //   if (message) {
  //     fmt::print("Message: '{}'\n", *message);
  //   } else {
  //     fmt::print("No Message Provided :(\n");
  //   }

  QApplication app(argc, argv);

  QCoreApplication::setApplicationName(QTCONANBOILERPLATE_PROJECT_NAME);
  QCoreApplication::setApplicationVersion(QTCONANBOILERPLATE_VERSION);

  QCommandLineParser parser;

  parser.setApplicationDescription(QTCONANBOILERPLATE_PROJECT_DESCRIPTION);
  parser.addHelpOption();
  parser.addVersionOption();

  parser.addPositionalArgument("source", QCoreApplication::translate("main", "Source file to copy."));
  parser.addPositionalArgument("destination", QCoreApplication::translate("main", "Destination directory."));

  // Process the actual command line arguments given by the user
  parser.process(app);

  const QCommandLineOption helpOption = parser.addHelpOption();
  const QCommandLineOption versionOption = parser.addVersionOption();

  // A boolean option with a single name (-p)
  QCommandLineOption showProgressOption("p", QCoreApplication::translate("main", "Show progress during copy"));
  parser.addOption(showProgressOption);

  if (parser.isSet(versionOption)) app.exit();

  if (parser.isSet(helpOption)) app.exit();

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
