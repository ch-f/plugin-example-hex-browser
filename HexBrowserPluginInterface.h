// SPDX-License-Identifier: MIT
#pragma once

#include <QtPlugin>
#include <QQuickItem>
#include <QString>
#include <QVariantMap>

class HexBrowserPluginInterface
{
public:
	virtual ~HexBrowserPluginInterface() {}

	virtual QString pluginName() const = 0;

	virtual QQuickItem* createItem(QQuickItem* parent, const QVariantMap &args) = 0;
};

#define HexBrowserPluginInterface_iid "com.hexbrowser.HexBrowserPluginInterface/2.0"

Q_DECLARE_INTERFACE(HexBrowserPluginInterface, HexBrowserPluginInterface_iid)
