// SPDX-License-Identifier: MIT
#pragma once

#include <QQuickPaintedItem>
#include <QColor>

class HelloWorldItem : public QQuickPaintedItem {
	Q_OBJECT
	public:
		explicit HelloWorldItem(QQuickItem *parent);

		~HelloWorldItem() override {}

		void paint(QPainter *painter) override;

		void setVerbose(bool v) { m_verbose = v; }

	protected:
		void mousePressEvent(QMouseEvent *event) override;

	private:
		bool m_verbose = false;
		QRect m_buttonRect;
		QQuickItem* m_parent = nullptr;
};
