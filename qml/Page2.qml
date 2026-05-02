// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	id: root
	anchors.fill: parent
	color: "white"
	property real wavePhase: 0

	Text {
		id: systemInfo
		x: (root.width - width) / 2
		y: (root.height - height) / 2 + Math.sin(root.wavePhase) * 12
		width: parent.width * 0.9   // Wrap text at 90% of parent's width
		text: "System-Info from uname:\n\n" + Helper.getSystemInfo()
		font.pointSize: 12
		color: "black"
		opacity: 0
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		SequentialAnimation on x {
			NumberAnimation { from: -systemInfo.width; to: (root.width - systemInfo.width) / 2; duration: 900; easing.type: Easing.OutBack }
		}

		NumberAnimation on opacity {
			from: 0
			to: 1
			duration: 700
		}
	}

	NumberAnimation on wavePhase {
		from: 0
		to: Math.PI * 2
		duration: 2600
		loops: Animation.Infinite
	}

	CodeLineBadge { lines: 36 }
}
