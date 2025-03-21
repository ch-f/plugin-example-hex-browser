// SPDX-License-Identifier: MIT
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQuickItem>
#include <QDebug>

#include "PluginExampleHexBrowser.h"

/* This is just the standalone version for better testing/development/debugging */
int main(int argc, char *argv[])
{
	// Allow qDebug() and console.*() to get displayed
	qputenv("QT_LOGGING_RULES", QByteArray("default.debug=true;qml.debug=true"));

	QGuiApplication app(argc, argv);

	// Create a QQuickView window
	QQuickView view;
	view.setWidth(640);
	view.setHeight(480);
	view.setResizeMode(QQuickView::SizeRootObjectToView);

	// Load minimal StandaloneView QML from resources
	view.setSource(QUrl("qrc:/StandaloneView.qml"));
	if (!view.rootObject()) {
		qWarning() << "Failed to load StandaloneView.qml from resources";
		return -1;
	}

	// Create plugin instance
	PluginExampleHexBrowser plugin;
	plugin.setArguments({{"verboseConsole", true}});  // optional arguments

	// Get root Object from view and tell plugin to create its QQuickItem under same root
	QQuickItem* rootItem = qobject_cast<QQuickItem*>(view.rootObject());
	QQuickItem* pluginItem = plugin.createItem(rootItem);
	if (!pluginItem) {
		qWarning() << "Plugin failed to create item";
		return -1;
	}

	view.show();

	return QGuiApplication::exec();
}
