// SPDX-License-Identifier: MIT
#include "HelloWorldItem.h"
#include <QPainter>
#include <QDebug>
#include <QMouseEvent>

HelloWorldItem::HelloWorldItem(QQuickItem* parent)
    : QQuickPaintedItem(parent)
{
	if (parent) {
		setPosition(QPointF(0, 0));

		setWidth(parent->width());
		setHeight(parent->height());

		connect(parent, &QQuickItem::widthChanged, this, [this, parent]() {
			setWidth(parent->width());
		});

		connect(parent, &QQuickItem::heightChanged, this, [this, parent]() {
			setHeight(parent->height());
		});

		m_parent = parent;
	} else {
		qWarning("HelloWorldItem::HelloWorldItem(): Missing parent");

		setWidth(640);
		setHeight(480);
	}

	// "button" area is a rectangle
	m_buttonRect = QRect(80, 80, 200, 80);
	setAcceptedMouseButtons(Qt::AllButtons);
}

// Cannot use classical QT Widgets on this QQuickPaintedItem
void HelloWorldItem::paint(QPainter* painter)
{
	// Fill background
	painter->fillRect(boundingRect(), QColor("#2a2a2a"));

	// "Draw" text
	painter->setPen(Qt::white);
	QFont f = painter->font();
	f.setPixelSize(22);
	painter->setFont(f);

	painter->drawText(boundingRect(), Qt::AlignCenter, "Hello World from C++ Plugin!");

	// "Draw" a "button"
	painter->setBrush(Qt::gray);
	painter->setPen(Qt::white);
	painter->drawRect(m_buttonRect);

	painter->drawText(m_buttonRect, Qt::AlignCenter, "Click Me");
}

void HelloWorldItem::mousePressEvent(QMouseEvent *event)
{
	if (m_buttonRect.contains(event->position().toPoint())) {
		if (m_verbose) {
			qDebug() << "HelloWorldItem: Button was clicked!";
		} else {
			qInfo() << "HelloWorldItem: Button was clicked!";
		}
	}
	// Let base class do normal handling
	QQuickPaintedItem::mousePressEvent(event);
}
