#pragma once
#include "ui_Window1.h"
#include <QtGui>

namespace Ui {
class Window1;
}

namespace app {

class Window1
  : public QDialog
  , public Ui::Window1
{
  Q_OBJECT

public:
  Window1(QWidget *parent = nullptr);
};

}// namespace app
