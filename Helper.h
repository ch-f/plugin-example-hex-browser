// SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QOpenGLContext>

class Helper : public QObject {
	Q_OBJECT

public:
	Helper(QObject *parent = nullptr);
	~Helper();

	Q_INVOKABLE QString getSystemInfo();
	Q_INVOKABLE bool hasOpenGLSupport();
};
