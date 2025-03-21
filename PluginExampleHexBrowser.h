// SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include <QQmlEngine>
#include "PluginExampleHexBrowser.h"
#include "HexBrowserPluginInterface.h"
#include "Helper.h"

class HelloWorldItem;

class PluginExampleHexBrowser : public QObject, public HexBrowserPluginInterface
{
	Q_OBJECT
	Q_PLUGIN_METADATA(IID HexBrowserPluginInterface_iid)
	Q_INTERFACES(HexBrowserPluginInterface)

    public:
	explicit PluginExampleHexBrowser(QObject* parent = nullptr);
	~PluginExampleHexBrowser() override;

	// HexBrowserPluginInterface:
	QString pluginName() const override;
	QQuickItem* createItem(QQuickItem* parent = nullptr) override;
	void setArguments(const QVariantMap &args) override;

private:
	QVariantMap m_args;
	QQuickItem* item;
	QQmlEngine *engine;
	Helper* m_helper;
};
