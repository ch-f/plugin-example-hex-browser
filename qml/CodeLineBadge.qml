// SPDX-License-Identifier: MIT
import QtQuick

Item {
	id: root

	required property int lines
	property bool darkBackground: parent.color.r * 0.299 + parent.color.g * 0.587 + parent.color.b * 0.114 < 0.5
	readonly property color badgeColor: darkBackground ? "#AAAAAA" : "#888888"

	anchors.right: parent.right
	anchors.top: parent.top
	anchors.margins: 12
	z: 10
	width: label.implicitWidth
	height: label.implicitHeight

	Text {
		id: label
		anchors.centerIn: parent
		text: lines + " lines of code"
		color: root.badgeColor
		font.pixelSize: 13
	}
}
