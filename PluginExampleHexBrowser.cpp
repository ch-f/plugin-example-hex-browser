// SPDX-License-Identifier: MIT
#include "PluginExampleHexBrowser.h"
#include "HelloWorldItem.h"
#include "Helper.h"
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

QQuickItem* PluginExampleHexBrowser::createItem(QQuickItem* parent, const QVariantMap &m_args)
{
	qDebug() << "PluginExampleHexBrowser received arguments" << m_args;

#if 0 // choose c++ or qml example
	HelloWorldItem* item = new HelloWorldItem(parent);

	if (m_args.contains("verboseConsole")) {
		bool isVerbose = m_args.value("verboseConsole").toBool();
		item->setVerbose(isVerbose);
	}
#else
	QQmlEngine *engine = nullptr;

	// Only call qmlEngine() if parent is non-null
	if (parent) {
		engine = qmlEngine(parent);
	}

	// If that yields null, create a fallback engine
	if (!engine) {
		qWarning() << "[Plugin] parent is null or not in a QML context. Creating new QQmlEngine.";
		engine = new QQmlEngine(this);
	}

	auto *itemContext = new QQmlContext(engine->rootContext(), engine);
	auto *helper = new Helper(itemContext);
	itemContext->setContextProperty("Helper", helper);

	// Load actual QML
	QQmlComponent component(engine, QUrl("qrc:/DemoMain.qml"));

	if (component.status() == QQmlComponent::Error) {
		qWarning() << "Failed to load DemoMain.qml from resource:" << component.errors();
		delete itemContext;
		return nullptr;
	}

	// Create QML object
	QObject *obj = component.create(itemContext);
	if (!obj) {
		qWarning() << "Failed to create QML object:" << component.errors();
		delete itemContext;
		return nullptr;
	}

	// We expect a QQuickItem
	QQuickItem *item = qobject_cast<QQuickItem*>(obj);
	if (!item) {
		qWarning() << "Root object is not a QQuickItem?";
		delete obj;
		delete itemContext;
		return nullptr;
	}

	itemContext->setParent(item);

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
