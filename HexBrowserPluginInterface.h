// SPDX-License-Identifier: MIT
#pragma once

#include <QtPlugin>
#include <QQuickItem>

class HexBrowserPluginInterface
{
public:
	virtual ~HexBrowserPluginInterface() {}

	virtual QString pluginName() const = 0;

	virtual QQuickItem* createItem(QQuickItem* parent = nullptr) = 0;

	virtual void setArguments(const QVariantMap &args) = 0;
};

#define HexBrowserPluginInterface_iid "com.hexbrowser.HexBrowserPluginInterface/1.0"

Q_DECLARE_INTERFACE(HexBrowserPluginInterface, HexBrowserPluginInterface_iid)