/*
 * SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
 *
 * SPDX-License-Identifier: EUPL-1.2
 *
 */

#include "qtwidgettest/main.h"

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

    QApplication const app(argc, argv);

    QCoreApplication::setApplicationName(PROJECT_NAME);
    QCoreApplication::setApplicationVersion(VERSION);

    QCommandLineParser parser;

    parser.setApplicationDescription(PROJECT_DESCRIPTION);
    parser.addHelpOption();
    parser.addVersionOption();

    parser.addPositionalArgument("source", QCoreApplication::translate("main", "Source file to copy."));
    parser.addPositionalArgument("destination", QCoreApplication::translate("main", "Destination directory."));

    // Process the actual command line arguments given by the user
    parser.process(app);

    const QCommandLineOption helpOption = parser.addHelpOption();
    const QCommandLineOption versionOption = parser.addVersionOption();

    // A boolean option with a single name (-p)
    QCommandLineOption const showProgressOption("p", QCoreApplication::translate("main", "Show progress during copy"));
    parser.addOption(showProgressOption);

    if (parser.isSet(versionOption)) {
        QApplication::exit();
    }

    if (parser.isSet(helpOption)) {
        QApplication::exit();
    }

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "QtWidgetTest_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            QApplication::installTranslator(&translator);
            break;
        }
    }
    MainWindow appWindow;
    appWindow.show();
    return QApplication::exec();
}
