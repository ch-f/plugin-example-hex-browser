// SPDX-License-Identifier: MIT
#include "PluginExampleHexBrowser.h"
#include "HelloWorldItem.h"
#include <QDebug>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>

PluginExampleHexBrowser::PluginExampleHexBrowser(QObject* parent)
    : QObject(parent)
{
}

PluginExampleHexBrowser::~PluginExampleHexBrowser()
{
}

QString PluginExampleHexBrowser::pluginName() const
{
	return QStringLiteral("plugin-example-hex-browser");
}

QQuickItem* PluginExampleHexBrowser::createItem(QQuickItem* parent)
{
#if 0 // choose c++ or qml example
	HelloWorldItem* item = new HelloWorldItem(parent);

	if (m_args.contains("verboseConsole")) {
		bool isVerbose = m_args.value("verboseConsole").toBool();
		item->setVerbose(isVerbose);
	}
#else
	engine = nullptr;

	// Only call qmlEngine() if parent is non-null
	if (parent) {
		engine = qmlEngine(parent);
	}

	// If that yields null, create a fallback engine
	if (!engine) {
		qWarning() << "[Plugin] parent is null or not in a QML context. Creating new QQmlEngine.";
		engine = new QQmlEngine(this);
	}

	m_helper = new Helper(engine);
	engine->rootContext()->setContextProperty("Helper", m_helper);

	// Load actual QML
	QQmlComponent component(engine, QUrl("qrc:/DemoMain.qml"));

	if (component.status() == QQmlComponent::Error) {
		qWarning() << "Failed to load DemoMain.qml from resource:" << component.errors();
		return nullptr;
	}

	// Create QML object
	QObject *obj = component.create();
	if (!obj) {
		qWarning() << "Failed to create QML object:" << component.errors();
		return nullptr;
	}

	// We expect a QQuickItem
	item = qobject_cast<QQuickItem*>(obj);
	if (!item) {
		qWarning() << "Root object is not a QQuickItem?";
		obj->deleteLater();
		return nullptr;
	}

	if (parent) {
		// Put it under given parent item
		item->setParentItem(parent);
	}

	if (m_args.value("verboseConsole").toBool()) {
		qDebug() << "Plugin loaded DemoMain.qml with fade transitions among 3 pages.";
	}

#endif
	return item;
}

void PluginExampleHexBrowser::setArguments(const QVariantMap &args)
{
	m_args = args;
	qDebug() << "PluginExampleHexBrowser received arguments" << m_args;
}
