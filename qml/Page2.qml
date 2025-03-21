// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	anchors.fill: parent
	color: "white"

	Text {
		anchors.centerIn: parent
		width: parent.width * 0.9   // Wrap text at 90% of parent's width
		text: "System-Info from uname:\n\n" + Helper.getSystemInfo()
		font.pointSize: 12
		color: "black"
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}
}
