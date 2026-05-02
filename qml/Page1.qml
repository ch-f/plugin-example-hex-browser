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
				id: hexBrowserLogo
				width: 70; height: 70
				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/assets/hex-browser.svg"
				fillMode: Image.PreserveAspectFit

				Timer {
					id: shakeTimer
					interval: hexBrowserLogo.pauseDuration()
					onTriggered: shakeAnimation.start()
					Component.onCompleted: start()
				}

				SequentialAnimation {
					id: shakeAnimation
					NumberAnimation { target: hexBrowserLogo; property: "rotation"; to: 0; duration: 0 }
					NumberAnimation { target: hexBrowserLogo; property: "rotation"; to: 4; duration: 120; easing.type: Easing.InOutSine }
					NumberAnimation { target: hexBrowserLogo; property: "rotation"; to: -4; duration: 160; easing.type: Easing.InOutSine }
					NumberAnimation { target: hexBrowserLogo; property: "rotation"; to: 2; duration: 120; easing.type: Easing.InOutSine }
					NumberAnimation { target: hexBrowserLogo; property: "rotation"; to: 0; duration: 140; easing.type: Easing.OutQuad }
					onStopped: {
						shakeTimer.interval = hexBrowserLogo.pauseDuration()
						shakeTimer.restart()
					}
				}

				function pauseDuration() {
					return Math.round(1000 + Math.random() * 4000)
				}
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

	CodeLineBadge { lines: 87 }
}
