// SPDX-License-Identifier: MIT
pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: "#050714"
	gradient: Gradient {
		GradientStop { position: 0; color: "#050714" }
		GradientStop { position: 0.58 + Math.sin(root.t * 0.16) * 0.025; color: "#082A3F" }
		GradientStop { position: 1; color: "#075467" }
	}

	readonly property color orange: "#FF901E"
	property real t: 0
	property int selected: 0
	readonly property real autoSelectionDelay: 3
	readonly property real interactionDelay: 20
	property real nextAutoSelectionAt: autoSelectionDelay
	readonly property var features: [
		{ "title": "Web / Chromium", "body": "HTML5 apps in the integrated Chromium engine.", "asset": "chromium_logo.svg" },
		{ "title": "Native Flutter", "body": "Flutter apps run as native content, not as web tabs.", "asset": "icon_flutter.svg" },
		{ "title": "Qt / QML", "body": "Native Qt Quick interfaces loaded directly into the shell.", "asset": "qt_logo.svg" },
		{ "title": "Native plugins", "body": "Extend the runtime with custom C++ and QML plugins.", "asset": "native_plugin_logo.svg" },
		{ "title": "Wayland apps", "body": "Host native Wayland applications in a managed session.", "asset": "hex_wayland_logo_favicon.webp" },
		{ "title": "RTSP / RTSPS", "body": "Display live camera and protected network streams.", "asset": "rtsp_logo.svg" },
		{ "title": "Slideshow", "body": "Run image and video playlists as a native runtime.", "asset": "hex-slideshow-runtime-preview.webp" },
		{ "title": "Waydroid", "body": "Bring LineageOS-based Android applications to the kiosk.", "asset": "waydroid-logo.webp" },
		{ "title": "MicroBrowser", "body": "Integrate SpiderControl MicroBrowser visualizations.", "asset": "microbrowser-logo.webp" }
	]
	readonly property var selectedFeature: features[Math.max(0, Math.min(selected, features.length - 1))]
	readonly property int designWidth: 820
	readonly property int navigationHeight: 110
	readonly property int minimumStageHeight: 360
	readonly property size planetCardSize: Qt.size(58, 50)
	readonly property int planetRingMargin: 4
	readonly property int planetRingRadius: 15
	readonly property real contentScale: Math.max(0.001, Math.min(width / designWidth,
	                                                              height / 600,
	                                                              Math.max(0, height - navigationHeight)
	                                                              / (128 + minimumStageHeight)))
	readonly property real availableDesignHeight: height / contentScale
	readonly property real navigationReserve: navigationHeight / contentScale
	readonly property real viewportAspect: width / Math.max(height, 1)
	readonly property real landscapeFactor: Math.max(0, Math.min(1, (viewportAspect - 1) / (16 / 9 - 1)))
	readonly property real targetOrbitAspect: 1 + landscapeFactor * (312 / 132 - 1)

	function featureAngle(index) {
		return t * 0.1425 - Math.PI / 2 + index * Math.PI * 2 / features.length;
	}

	function roundedRectRayDistance(unitX, unitY, halfWidth, halfHeight, radius) {
		var absX = Math.abs(unitX);
		var absY = Math.abs(unitY);
		var sideX = halfWidth / Math.max(absX, 0.001);
		if (absY * sideX <= halfHeight - radius)
			return sideX;

		var sideY = halfHeight / Math.max(absY, 0.001);
		if (absX * sideY <= halfWidth - radius)
			return sideY;

		var cornerX = halfWidth - radius;
		var cornerY = halfHeight - radius;
		var projection = absX * cornerX + absY * cornerY;
		var discriminant = projection * projection
		                   - (cornerX * cornerX + cornerY * cornerY - radius * radius);
		return projection + Math.sqrt(Math.max(0, discriminant));
	}

	Item {
		width: root.designWidth
		height: root.availableDesignHeight
		x: (root.width - width * root.contentScale) / 2
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
				text: "hex-browser runtimes"
				color: "#F5FAFC"
				font.pixelSize: 28
				font.bold: true
			}
		}

		Item {
			id: stage
			x: 34
			y: 128
			width: parent.width - 68
			height: Math.max(root.minimumStageHeight, parent.height - y - root.navigationReserve)

			readonly property real orbitCenterX: width / 2
			readonly property real orbitCenterY: height / 2
			readonly property real orbitRadiusX: Math.min(312, width / 2 - 44,
			                                             (height / 2 - 44) * root.targetOrbitAspect)
			readonly property real orbitRadiusY: orbitRadiusX / root.targetOrbitAspect

			Canvas {
				id: orbitTrack
				anchors.fill: parent
				onPaint: {
					var ctx = getContext("2d");
					ctx.clearRect(0, 0, width, height);
					ctx.lineCap = "round";

					for (var inset = 0; inset <= 8; inset += 8) {
						ctx.beginPath();
						ctx.ellipse(stage.orbitCenterX - stage.orbitRadiusX + inset,
						            stage.orbitCenterY - stage.orbitRadiusY + inset * 0.75,
						            (stage.orbitRadiusX - inset) * 2,
						            (stage.orbitRadiusY - inset * 0.75) * 2);
						ctx.strokeStyle = inset === 0 ? "rgba(137, 188, 211, 0.24)" : "rgba(0, 127, 152, 0.13)";
						ctx.lineWidth = inset === 0 ? 1.2 : 1;
						ctx.stroke();
					}

					var selectedNode = runtimeRepeater.itemAt(root.selected);
					if (!selectedNode)
						return;

					var cardCenter = selectedNode.mapToItem(stage, selectedNode.width / 2,
					                                        root.planetCardSize.height / 2);
					var nodeScale = selectedNode.scale;
					var towardHubX = stage.orbitCenterX - cardCenter.x;
					var towardHubY = stage.orbitCenterY - cardCenter.y;
					var distance = Math.max(0.001, Math.sqrt(towardHubX * towardHubX
					                                        + towardHubY * towardHubY));
					var unitX = towardHubX / distance;
					var unitY = towardHubY / distance;
					var edgeDistance = root.roundedRectRayDistance(unitX, unitY,
					                                               (root.planetCardSize.width / 2
					                                                + root.planetRingMargin) * nodeScale,
					                                               (root.planetCardSize.height / 2
					                                                + root.planetRingMargin) * nodeScale,
					                                               root.planetRingRadius * nodeScale);
					var overlap = 1.25 * nodeScale;

					ctx.lineCap = "butt";
					ctx.beginPath();
					ctx.moveTo(stage.orbitCenterX, stage.orbitCenterY);
					ctx.lineTo(cardCenter.x + unitX * (edgeDistance - overlap),
					           cardCenter.y + unitY * (edgeDistance - overlap));
					ctx.strokeStyle = "rgba(255, 144, 30, 0.48)";
					ctx.lineWidth = 2.6;
					ctx.stroke();
				}
			}

			Canvas {
				anchors.fill: hub
				anchors.margins: -60
				scale: 1 + Math.sin(root.t * 1.15) * 0.02
				onPaint: {
					var ctx = getContext("2d");
					var x = (width - hub.width) / 2;
					var y = (height - hub.height) / 2;
					var radius = hub.radius;

					ctx.clearRect(0, 0, width, height);
					ctx.fillStyle = "rgba(255, 211, 106, 0.32)";
					ctx.shadowColor = "rgba(255, 144, 30, 0.62)";
					ctx.shadowBlur = 34;
					ctx.beginPath();
					ctx.roundedRect(x, y, hub.width, hub.height, radius, radius);
					ctx.fill();
					ctx.shadowColor = "rgba(255, 225, 148, 0.9)";
					ctx.shadowBlur = 15;
					ctx.beginPath();
					ctx.roundedRect(x, y, hub.width, hub.height, radius, radius);
					ctx.fill();
				}
			}

			Rectangle {
				id: hub
				anchors.centerIn: parent
				width: 220
				height: 128
				radius: 32
				gradient: Gradient {
					GradientStop { position: 0; color: "#FFFDF5" }
					GradientStop { position: 0.58; color: "#FFF1B8" }
					GradientStop { position: 1; color: "#FFD36A" }
				}
				border.width: 2
				border.color: "#FFB52E"
				z: 120

				Image {
					x: 17
					y: 14
					width: 31
					height: 31
					source: "qrc:/assets/hex-browser.svg"
					fillMode: Image.PreserveAspectFit
				}

				Text {
					x: 57
					y: 13
					text: "hex-browser"
					color: "#152638"
					font.pixelSize: 14
					font.bold: true
				}

				Text {
					x: 57
					y: 32
					text: "RUNTIME HOST  ·  " + (root.selected + 1) + " / " + root.features.length
					color: "#7A5A27"
					font.pixelSize: 8
					font.bold: true
					font.letterSpacing: 0.7
				}

				Rectangle {
					x: 16
					y: 53
					width: parent.width - 32
					height: 1
					color: "#D99A32"
				}

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 62
					width: parent.width - 30
					text: root.selectedFeature.title
					color: "#17283A"
					font.pixelSize: 17
					font.bold: true
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
				}

				Text {
					anchors.horizontalCenter: parent.horizontalCenter
					y: 87
					width: parent.width - 34
					text: root.selectedFeature.body
					color: "#4D5964"
					font.pixelSize: 10
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					maximumLineCount: 2
					elide: Text.ElideRight
				}
			}

			Repeater {
				id: runtimeRepeater
				model: root.features

				Item {
					id: runtimeNode
					required property int index
					required property var modelData
					readonly property real angle: root.featureAngle(index)
					readonly property real depth: (Math.sin(angle) + 1) / 2
					readonly property real depthScale: 0.9 + depth * 0.14
					readonly property bool active: index === root.selected
					property real clickWobble: 0
					x: stage.orbitCenterX + Math.cos(angle) * stage.orbitRadiusX - width / 2
					y: stage.orbitCenterY + Math.sin(angle) * stage.orbitRadiusY - height / 2
					width: 82
					height: 70
					scale: depthScale * (active ? 1.2 : 1) * (1 + clickWobble)
					opacity: active ? 1 : 0.7 + depth * 0.3
					z: active ? 110 : 20 + Math.round(depth * 80)

					onScaleChanged: {
						if (active)
							orbitTrack.requestPaint();
					}
					onActiveChanged: {
						if (!active) {
							clickSpring.stop();
							clickWobble = 0;
						}
					}

					SpringAnimation {
						id: clickSpring
						target: runtimeNode
						property: "clickWobble"
						from: 0.06
						to: 0
						spring: 4
						damping: 0.2
						epsilon: 0.005
					}

					Rectangle {
						anchors.horizontalCenter: parent.horizontalCenter
						y: -7
						width: 72
						height: 64
						radius: 18
						color: "#30FFD166"
						opacity: runtimeNode.active ? 0.7 + Math.sin(root.t * 2.2) * 0.12 : 0
						scale: 1 + Math.sin(root.t * 1.7) * 0.035
					}

					Rectangle {
						anchors.horizontalCenter: parent.horizontalCenter
						width: root.planetCardSize.width
						height: root.planetCardSize.height
						radius: 12
						color: "#F7FAFC"
						border.width: runtimeNode.active ? 2 : 1
						border.color: runtimeNode.active ? root.orange : "#638296A7"

						Rectangle {
							anchors.fill: parent
							anchors.margins: -root.planetRingMargin
							radius: root.planetRingRadius
							color: "transparent"
							border.width: 2
							border.color: root.orange
							opacity: runtimeNode.active ? 0.45 + Math.sin(root.t * 2.2) * 0.12 : 0
						}

						Image {
							anchors.fill: parent
							anchors.margins: 8
							source: "qrc:/assets/" + runtimeNode.modelData.asset
							fillMode: Image.PreserveAspectFit
						}
					}

					Text {
						y: 55
						width: parent.width
						text: runtimeNode.modelData.title
						color: runtimeNode.active ? "#FFFFFF" : "#B8CBD6"
						font.pixelSize: 10
						fontSizeMode: Text.HorizontalFit
						minimumPixelSize: 8
						font.bold: runtimeNode.active
						horizontalAlignment: Text.AlignHCenter
						elide: Text.ElideRight
					}

					MouseArea {
						anchors.fill: parent
						onPressed: {
							root.selected = runtimeNode.index;
							root.nextAutoSelectionAt = root.t + root.interactionDelay;
							clickSpring.restart();
						}
					}
				}
			}
		}

		Text {
			x: 112
			y: 85
			text: "YOUR APP   ·   OUR RUNTIME EXPERTISE   ·   YOUR PRODUCT IN FOCUS"
			color: "#A9C0CC"
			font.pixelSize: 11
			font.bold: true
			font.letterSpacing: 0.8
		}
	}

	FrameAnimation {
		running: true
		onTriggered: {
			root.t = elapsedTime;
			if (root.t >= root.nextAutoSelectionAt) {
				root.selected = (root.selected + 1) % root.features.length;
				root.nextAutoSelectionAt = root.t + root.autoSelectionDelay;
			}
			orbitTrack.requestPaint();
		}
	}

	CodeLineBadge { lines: 356 }
}
