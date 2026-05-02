// SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include "HexBrowserPluginInterface.h"

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
	QQuickItem* createItem(QQuickItem* parent, const QVariantMap &m_args) override;
};
