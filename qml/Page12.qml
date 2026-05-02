// SPDX-License-Identifier: MIT
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: "#000327"
	gradient: Gradient {
		GradientStop { position: 0; color: "#000327" }
		GradientStop { position: 0.52 + Math.sin(root.t * 0.22) * 0.06; color: "#003152" }
		GradientStop { position: 1; color: "#007F98" }
	}

	readonly property color red: "#EC0000"
	readonly property color orange: "#FF901E"
	readonly property color night: "#000327"
	readonly property color deep: "#003152"
	readonly property color sea: "#007F98"
	readonly property color qtGreen: "#41CD52"
	readonly property color flutterBlue: "#44D1FD"
	readonly property color chromiumBlue: "#679EF5"
	readonly property color yoctoMagenta: "#D73B9A"
	property real t: 0
	property int selected: 0
	property bool userSelected: false
	readonly property var features: [
		{ "title": "hex-browser", "body": "Providing runtime engines for your app, integrated into a secure Linux.", "accent": red, "source": "qrc:/assets/hex-browser.svg" },
		{ "title": "Chromium engine", "body": "HTML apps for embedded devices, tuned for constrained RAM.", "accent": chromiumBlue, "source": "qrc:/assets/chromium_logo.svg" },
		{ "title": "Qt plugins", "body": "Load native .so plugins and QML screens in the same shell.", "accent": qtGreen, "source": "qrc:/assets/qt_logo.svg" },
		{ "title": "Native Flutter", "body": "Flutter apps run as native content, not as HTML tabs.", "accent": flutterBlue, "source": "qrc:/assets/flutter_logo.svg" },
		{ "title": "OE/Yocto Linux", "body": "Tempo2Market delivers reproducible Linux images and BSPs.", "accent": yoctoMagenta, "source": "qrc:/assets/yocto_project_logo.svg" },
		{ "title": "Fleet Warden", "body": "Cloud fleet management with OTA, telemetry and LIVE service.", "accent": orange, "source": "qrc:/assets/fleetwarden_logo.svg" }
	]
	readonly property int designWidth: 820
	readonly property int sectionGap: 50
	readonly property int pillHeight: 32
	readonly property int fullHeight: 128 + 8 + 360 + sectionGap + pillHeight + Math.round(sectionGap * 1.2)
	readonly property int compactHeight: 560
	readonly property bool compact: width < 760 || height < 620
	readonly property int designHeight: compact ? compactHeight : fullHeight
	readonly property real contentScale: Math.min(width / designWidth, height / designHeight)
	readonly property bool showPills: !compact && contentScale > 0.86

	function cardX(index, cardWidth, areaWidth) {
		return index < 3 ? 0 : areaWidth - cardWidth;
	}

	function cardY(index, top) {
		return top + (index % 3) * 112;
	}

	Canvas {
		id: network
		anchors.fill: parent
		opacity: 0.9
		onPaint: {
			var ctx = getContext("2d");
			var w = width;
			var h = height;
			var cx = w * 0.5;
			var cy = h * 0.48;
			ctx.clearRect(0, 0, w, h);
			ctx.lineCap = "round";

			for (var i = 0; i < 18; ++i) {
				var y = 72 + i * 34 + Math.sin(root.t * 0.7 + i) * 7;
				ctx.beginPath();
				ctx.moveTo(0, y);
				ctx.bezierCurveTo(w * 0.22, y - 40, w * 0.72, y + 46, w, y - 12);
				ctx.strokeStyle = "rgba(255,255,255,0.055)";
				ctx.lineWidth = 1.1;
				ctx.stroke();

				var p = (root.t * (0.11 + i * 0.004) + i * 0.19) % 1;
				var x = w * p;
				ctx.beginPath();
				ctx.arc(x, y + Math.sin(p * Math.PI * 2 + i) * 18, 2.2, 0, Math.PI * 2);
				ctx.fillStyle = i % 3 === 0 ? root.red : (i % 3 === 1 ? root.orange : root.sea);
				ctx.globalAlpha = 0.55;
				ctx.fill();
				ctx.globalAlpha = 1;
			}

			var glow = ctx.createRadialGradient(cx, cy, 20, cx, cy, Math.min(w, h) * 0.36);
			glow.addColorStop(0, "rgba(255,144,30,0.2)");
			glow.addColorStop(0.5, "rgba(236,0,0,0.08)");
			glow.addColorStop(1, "rgba(0,127,152,0)");
			ctx.fillStyle = glow;
			ctx.fillRect(0, 0, w, h);
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
				x: 34
				y: 34
				spacing: 16

				Image {
					width: 62
					height: 62
					source: "qrc:/assets/hexdev_logo.svg"
					fillMode: Image.PreserveAspectFit
				}
				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: "Tempo2Market"
					color: "#F5FAFC"
					font.pixelSize: 30
					font.bold: true
				}
			}

			Item {
				id: stage
				x: 34
				y: 128
				width: parent.width - 68
				height: parent.height - 190

				readonly property real cardWidth: Math.min(282, Math.max(212, width * 0.28))
				readonly property real centerWidth: Math.max(250, width - cardWidth * 2 - 70)
				readonly property real centerX: (width - centerWidth) * 0.5

				Repeater {
					model: root.features
					Rectangle {
						id: card
						x: root.cardX(index, stage.cardWidth, stage.width)
						y: root.cardY(index, 16)
						width: stage.cardWidth
						height: 94
						radius: 8
						color: index === root.selected ? "#F8FFFFFF" : "#DFFFFFFF"
						border.width: index === root.selected ? 2 : 1
						border.color: index === root.selected ? modelData.accent : "#33FFFFFF"
						scale: index === root.selected ? 1.035 : 1

						Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
						Behavior on color { ColorAnimation { duration: 220 } }
						Behavior on border.color { ColorAnimation { duration: 220 } }

						Rectangle {
							x: 0
							y: 1
							width: 8
							height: parent.height - 2
							radius: 3
							color: modelData.accent
						}
						Text {
							x: 18
							y: 13
							width: parent.width - 34
							text: modelData.title
							color: root.deep
							font.pixelSize: 15
							font.bold: true
							elide: Text.ElideRight
						}
						Text {
							x: 18
							y: 38
							width: parent.width - 34
							text: modelData.body
							color: "#33454E"
							font.pixelSize: index === 0 ? 11 : 12
							wrapMode: Text.WordWrap
						}
						MouseArea {
							anchors.fill: parent
							onPressed: {
								root.selected = index;
								root.userSelected = true;
							}
						}
					}
				}

				Rectangle {
					id: hub
					x: stage.centerX
					y: 8
					width: stage.centerWidth
					height: Math.min(360, stage.height - 10)
					radius: 12
					color: "#26FFFFFF"
					border.width: 1
					border.color: root.selected === 0 ? root.red : "#33FFFFFF"

					Behavior on border.color { ColorAnimation { duration: 180 } }

					Rectangle {
						anchors.centerIn: parent
						width: Math.min(parent.width, parent.height) * 0.76
						height: width
						radius: width / 2
						color: "#1AFFFFFF"
						border.width: 1
						border.color: "#24FFFFFF"
						rotation: root.t * 8
					}
					Rectangle {
						anchors.centerIn: parent
						width: Math.min(parent.width, parent.height) * 0.48
						height: width
						radius: width / 2
						color: root.selected === 0 ? "#22EC0000" : "#18FF901E"
						border.width: 2
						border.color: root.selected === 0 ? root.red : "#55FF901E"
						scale: (root.selected === 0 ? 1.07 : 1) + Math.sin(root.t * 1.7) * 0.03

						Behavior on color { ColorAnimation { duration: 180 } }
						Behavior on border.color { ColorAnimation { duration: 180 } }
					}

					Image {
						id: browserLogo
						anchors.centerIn: parent
						width: Math.min(parent.width, parent.height) * 0.31
						height: width
						source: "qrc:/assets/hex-browser.svg"
						fillMode: Image.PreserveAspectFit
						scale: (root.selected === 0 ? 1.12 : 1) + Math.sin(root.t * 1.4) * 0.025

						MouseArea {
							anchors.fill: parent
							onPressed: {
								root.selected = 0;
								root.userSelected = true;
							}
						}
					}

					Repeater {
						model: root.features.length - 1
						Item {
							readonly property var item: root.features[index + 1]
							readonly property bool active: index + 1 === root.selected
							readonly property real angle: root.t * 0.42 + index * Math.PI * 2 / (root.features.length - 1)
							readonly property real radius: Math.min(hub.width, hub.height) * 0.3
							x: hub.width * 0.5 + Math.cos(angle) * radius - width / 2
							y: hub.height * 0.5 + Math.sin(angle) * radius * 0.72 - height / 2
							width: Math.min(84, Math.max(55, hub.width * 0.198))
							height: Math.min(55, width * 0.68)
							scale: active ? 1.14 : 1
							z: active ? 1 : 0

							Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

							Rectangle {
								anchors.fill: parent
								anchors.margins: -7
								radius: 12
								color: "transparent"
								border.width: 2
								border.color: item.accent
								opacity: active ? 0.85 : 0

								Behavior on opacity { NumberAnimation { duration: 180 } }
								Behavior on border.color { ColorAnimation { duration: 180 } }
							}
							Rectangle {
								anchors.fill: parent
								radius: 8
								color: active ? "#FFFFFFFF" : "#EBFFFFFF"
								border.width: active ? 2 : 1
								border.color: active ? item.accent : "#44FFFFFF"

								Behavior on color { ColorAnimation { duration: 180 } }
								Behavior on border.color { ColorAnimation { duration: 180 } }
							}
							Image {
								anchors.centerIn: parent
								width: parent.width * 0.79
								height: parent.height * 0.64
								source: item.source
								fillMode: Image.PreserveAspectFit
							}
							MouseArea {
								anchors.fill: parent
								onPressed: {
									root.selected = index + 1;
									root.userSelected = true;
								}
							}
						}
					}

					Text {
						anchors {
							horizontalCenter: parent.horizontalCenter
							bottom: parent.bottom
							bottomMargin: 22
						}
						width: parent.width * 0.8
						text: "A kiosk shell for your app"
						color: "#E7F0F5"
						font.pixelSize: 16
						wrapMode: Text.WordWrap
						horizontalAlignment: Text.AlignHCenter
					}
				}
			}

			Row {
				visible: root.showPills
				anchors.horizontalCenter: stage.horizontalCenter
				y: stage.y + hub.y + hub.height + root.sectionGap
				spacing: 10

				Repeater {
					model: ["Focus on your product", "We provide the shell", "Fleet Warden keeps it alive"]
					Rectangle {
						width: 190
						height: root.pillHeight
						radius: 7
						color: "#22FFFFFF"
						border.width: 1
						border.color: "#33FFFFFF"
						Text {
							anchors.centerIn: parent
							text: modelData
							color: "#EAF2F5"
							font.pixelSize: 12
							font.bold: true
						}
					}
				}
			}
		}

	Timer {
		interval: 16
		repeat: true
		running: true
		onTriggered: {
			root.t += 0.016;
			if (!root.userSelected)
				root.selected = Math.floor(root.t * 0.55) % root.features.length;
			network.requestPaint();
		}
	}

	CodeLineBadge { lines: 321 }
}
