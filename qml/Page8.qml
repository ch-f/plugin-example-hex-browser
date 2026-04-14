// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	id: root
	anchors.fill: parent
	color: "#101010"

	property real hue: 0.58
	property real saturation: 0.85
	property real value: 0.95
	readonly property color selectedColor: Qt.hsva(hue, saturation, value, 1.0)
	readonly property string selectedHex: selectedColor.toString().toUpperCase()

	function clamp(v, minV, maxV) {
		return Math.max(minV, Math.min(maxV, v))
	}

	function updateSv(px, py) {
		saturation = clamp(px / svArea.width, 0, 1)
		value = 1 - clamp(py / svArea.height, 0, 1)
	}

	function updateHue(py) {
		hue = clamp(py / hueSlider.height, 0, 1)
	}

	Item {
		anchors.fill: parent
		anchors.margins: 16

		Rectangle {
			id: svArea
			anchors.top: infoBar.bottom
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.right: hueSlider.left
			anchors.topMargin: 12
			anchors.rightMargin: 12
			radius: 10
			clip: true
			color: Qt.hsva(root.hue, 1, 1, 1)

			Rectangle {
				anchors.fill: parent
				gradient: Gradient {
					GradientStop { position: 0.0; color: "#FFFFFFFF" }
					GradientStop { position: 1.0; color: "#00FFFFFF" }
				}
			}

			Rectangle {
				anchors.fill: parent
				gradient: Gradient {
					GradientStop { position: 0.0; color: "#00000000" }
					GradientStop { position: 1.0; color: "#FF000000" }
				}
			}

			Rectangle {
				x: root.saturation * svArea.width - width / 2
				y: (1 - root.value) * svArea.height - height / 2
				width: 20
				height: 20
				radius: width / 2
				color: "transparent"
				border.color: "white"
				border.width: 2
			}

			MouseArea {
				anchors.fill: parent
				onPressed: function(mouse) {
					root.updateSv(mouse.x, mouse.y)
				}
				onPositionChanged: function(mouse) {
					if (pressed) {
						root.updateSv(mouse.x, mouse.y)
					}
				}
			}
		}

		Rectangle {
			id: hueSlider
			width: 48
			anchors.top: svArea.top
			anchors.bottom: svArea.bottom
			anchors.right: parent.right
			radius: 10
			clip: true
			gradient: Gradient {
				GradientStop { position: 0.000; color: "#FF0000" }
				GradientStop { position: 0.166; color: "#FFFF00" }
				GradientStop { position: 0.333; color: "#00FF00" }
				GradientStop { position: 0.500; color: "#00FFFF" }
				GradientStop { position: 0.666; color: "#0000FF" }
				GradientStop { position: 0.833; color: "#FF00FF" }
				GradientStop { position: 1.000; color: "#FF0000" }
			}

			Rectangle {
				y: root.hue * hueSlider.height - height / 2
				width: parent.width
				height: 4
				color: "white"
			}

			MouseArea {
				anchors.fill: parent
				onPressed: function(mouse) {
					root.updateHue(mouse.y)
				}
				onPositionChanged: function(mouse) {
					if (pressed) {
						root.updateHue(mouse.y)
					}
				}
			}
		}

		Rectangle {
			id: infoBar
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			height: 64
			radius: 10
			color: "#CC202020"
			border.width: 1
			border.color: "#50FFFFFF"

			Row {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 12

				Rectangle {
					width: 44
					height: 44
					radius: 6
					color: root.selectedColor
					border.width: 1
					border.color: "#99FFFFFF"
				}

				Label {
					anchors.verticalCenter: parent.verticalCenter
					text: qsTr("Selected: ") + root.selectedHex
					color: "white"
					font.pixelSize: 18
				}
			}
		}
	}
}
