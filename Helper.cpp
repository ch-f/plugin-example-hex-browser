// SPDX-License-Identifier: MIT
#include "Helper.h"
#include <sys/utsname.h>
#include <QStringList>

Helper::Helper(QObject *parent) : QObject(parent) {}

Helper::~Helper() {}

QString Helper::getSystemInfo() {
	struct utsname unameData;
	QStringList info;

	if (uname(&unameData) == 0) {
		info << QString("System: %1").arg(unameData.sysname);
		info << QString("Node Name: %1").arg(unameData.nodename);
		info << QString("Release: %1").arg(unameData.release);
		info << QString("Version: %1").arg(unameData.version);
		info << QString("Machine: %1").arg(unameData.machine);
	} else {
		info << "Error retrieving system information";
	}

	return info.join("\n");
}

bool Helper::hasOpenGLSupport() {
	QOpenGLContext ctx;
	ctx.create();
	return ctx.isValid();
}