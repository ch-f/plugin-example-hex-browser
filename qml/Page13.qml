// SPDX-License-Identifier: MIT
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: "#000327"
	gradient: Gradient {
		GradientStop { position: 0; color: "#000327" }
		GradientStop { position: 0.55; color: "#003152" }
		GradientStop { position: 1; color: "#007F98" }
	}

	readonly property color red: "#EC0000"
	readonly property color orange: "#FF901E"
	readonly property color sea: "#007F98"
	readonly property int designWidth: 820
	readonly property int designHeight: 620
	readonly property real contentScale: Math.min(width / designWidth, height / designHeight)
	property real t: 0
	readonly property var cards: [
		{ "title": "Runtime shell", "body": "Chromium, Qt plugins and Flutter in one embedded app base.", "source": "qrc:/assets/hex-browser.svg", "accent": red },
		{ "title": "Linux platform", "body": "Tempo2Market provides the OE/Yocto foundation around it.", "source": "qrc:/assets/yocto_project_logo.svg", "accent": "#D73B9A" },
		{ "title": "Cloud lifecycle", "body": "Fleet Warden keeps deployed devices visible and updatable.", "source": "qrc:/assets/fleetwarden_logo.svg", "accent": orange }
	]

	Timer {
		interval: 16
		repeat: true
		running: true
		onTriggered: root.t += 0.016
	}

	Repeater {
		model: 9
		Rectangle {
			x: root.width * ((index + 1) / 10)
			y: -height * 0.2 + Math.sin(root.t * 0.45 + index) * 18
			width: 1
			height: root.height * 1.35
			rotation: -18
			color: index % 3 === 0 ? root.red : (index % 3 === 1 ? root.orange : root.sea)
			opacity: 0.11
		}
	}

	Item {
		id: page
		width: root.designWidth
		height: root.designHeight
		x: (root.width - width * root.contentScale) / 2
		y: (root.height - height * root.contentScale) / 2
		scale: root.contentScale
		transformOrigin: Item.TopLeft

		Row {
			id: brandRow
			x: 36
			y: 32
			spacing: 16

			Image {
				width: 70
				height: 70
				source: "qrc:/assets/hexdev_logo.svg"
				fillMode: Image.PreserveAspectFit
			}

			Column {
				anchors.verticalCenter: parent.verticalCenter
				spacing: 2

				Text {
					text: "hexDEV"
					color: "#F5FAFC"
					font.pixelSize: 30
					font.bold: true
				}

				Text {
					text: "Tempo2Market + hex-browser"
					color: "#BFD5DE"
					font.pixelSize: 14
				}
			}
		}

		Image {
			x: page.width - width - 38
			y: 36
			width: 76
			height: 76
			source: "qrc:/assets/hex-browser.svg"
			fillMode: Image.PreserveAspectFit
			rotation: Math.sin(root.t * 1.1) * 4
		}

		Text {
			id: headline
			x: 46
			y: 136
			width: page.width - 92
			text: "Use hex-browser as the base for your app"
			color: "#FFFFFF"
			font.pixelSize: 38
			font.bold: true
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
		}

		Text {
			id: pitch
			x: 74
			y: headline.y + headline.height + 18
			width: page.width - 148
			text: "Stop rebuilding BSPs, launchers and update plumbing. Start with hex-browser, secure Linux and fleet updates already connected."
			color: "#D7E7EE"
			font.pixelSize: 18
			lineHeight: 1.15
			wrapMode: Text.WordWrap
			horizontalAlignment: Text.AlignHCenter
		}

		Row {
			id: cardRow
			x: 36
			y: 318
			spacing: 14

			Repeater {
				model: root.cards

				Rectangle {
					width: 240
					height: 106
					radius: 8
					color: "#EFFFFFFF"
					border.width: 1
					border.color: modelData.accent
					scale: 1 + Math.sin(root.t * 1.4 + index) * 0.012

					Image {
						x: 14
						y: 16
						width: 42
						height: 42
						source: modelData.source
						fillMode: Image.PreserveAspectFit
					}

					Rectangle {
						x: 0
						y: 0
						width: 7
						height: parent.height
						radius: 3
						color: modelData.accent
					}

					Text {
						x: 68
						y: 15
						width: parent.width - 82
						text: modelData.title
						color: "#003152"
						font.pixelSize: 16
						font.bold: true
					}

					Text {
						x: 68
						y: 42
						width: parent.width - 82
						text: modelData.body
						color: "#33454E"
						font.pixelSize: 12
						wrapMode: Text.WordWrap
					}
				}
			}
		}

		Rectangle {
			id: cta
			x: (page.width - width) / 2
			y: 458
			width: 440
			height: 64
			radius: 10
			color: "#FF901E"
			border.width: 2
			border.color: "#FFFFFF"
			scale: 1 + Math.sin(root.t * 2.2) * 0.018

			Text {
				anchors.centerIn: parent
				text: "Get in contact: meetus@hexdev.de"
				color: "#000327"
				font.pixelSize: 20
				font.bold: true
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: Qt.openUrlExternally("mailto:meetus@hexdev.de?subject=Tempo2Market%20project")
			}
		}
	}

	CodeLineBadge { lines: 187 }
}
