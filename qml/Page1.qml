// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	anchors.fill: parent
	color: "white"

	Column {
		anchors.centerIn: parent
		width: Math.min(parent.width * 0.82, 720)
		spacing: 14

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 20

			Rectangle {
				width: 82
				height: 58
				anchors.verticalCenter: parent.verticalCenter
				radius: 8
				color: "#41cd52"

				Text {
					anchors.centerIn: parent
					text: "Qt"
					color: "white"
					font.pixelSize: 30
					font.bold: true
				}
			}

			Image {
				width: 70; height: 70
				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/assets/hex-browser.svg"
				fillMode: Image.PreserveAspectFit
			}
		}

		Text {
			width: parent.width
			text: "Qt Quick plugin for hex-browser"
			font.pixelSize: 28
			font.bold: true
			color: "#202020"
			horizontalAlignment: Text.AlignHCenter
		}

		Text {
			width: parent.width
			text: "A native QML scene loaded from a Qt plugin shared library."
			font.pixelSize: 17
			color: "#404040"
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
		}

		Text {
			id: repositoryLink
			anchors.horizontalCenter: parent.horizontalCenter
			text: "github.com/ch-f/plugin-example-hex-browser"
			font.pixelSize: 15
			color: "#0066cc"
			font.underline: true

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: Qt.openUrlExternally("https://github.com/ch-f/plugin-example-hex-browser")
			}
		}
	}
}

