// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	id: root
	anchors.fill: parent
	color: "white"
	property real wavePhase: 0
	property real introX: 0
	property real dragX: 0
	property real dragY: 0
	property real pressX: 0
	property real pressY: 0
	property real startDragX: 0
	property real startDragY: 0
	property bool dragging: false

	Item {
		id: textBox
		x: (root.width - width) / 2 + root.introX + root.dragX
		y: (root.height - height) / 2 + Math.sin(root.wavePhase) * 12 + root.dragY
		width: root.width * 0.9
		height: systemInfo.implicitHeight
		opacity: 0

		Text {
			id: systemInfo
			width: parent.width
			height: implicitHeight
			text: "System-Info from uname:\n\n" + Helper.getSystemInfo()
			font.pointSize: 12
			color: "black"
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}

		NumberAnimation on opacity {
			from: 0; to: 1; duration: 700
		}
	}

	Behavior on dragX {
		enabled: !root.dragging
		SpringAnimation { spring: 1.9; damping: 0.13; epsilon: 0.08 }
	}
	Behavior on dragY {
		enabled: !root.dragging
		SpringAnimation { spring: 1.9; damping: 0.13; epsilon: 0.08 }
	}

	MouseArea {
		anchors.fill: parent
		onPressed: function(mouse) {
			root.dragging = true;
			root.pressX = mouse.x;
			root.pressY = mouse.y;
			root.startDragX = root.dragX;
			root.startDragY = root.dragY;
		}
		onPositionChanged: function(mouse) {
			if (!pressed)
				return;
			root.dragX = root.startDragX + (mouse.x - root.pressX) * 0.35;
			root.dragY = root.startDragY + (mouse.y - root.pressY) * 0.8;
		}
		onReleased: {
			root.dragging = false;
			root.dragX = 0;
			root.dragY = 0;
		}
	}

	NumberAnimation on introX {
		from: -root.width
		to: 0
		duration: 900
		easing.type: Easing.OutBack
	}

	NumberAnimation on wavePhase {
		from: 0
		to: Math.PI * 2
		duration: 2600
		loops: Animation.Infinite
	}

	CodeLineBadge { lines: 80 }
}
