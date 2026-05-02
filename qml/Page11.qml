// SPDX-License-Identifier: MIT
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: night
	gradient: Gradient {
		GradientStop { position: 0; color: "#000327" }
		GradientStop { position: 0.56; color: "#003152" }
		GradientStop { position: 1; color: "#007F98" }
	}

	readonly property color red: "#EC0000"
	readonly property color orange: "#FF901E"
	readonly property color night: "#000327"
	readonly property color deep: "#003152"
	readonly property color sea: "#007F98"
	readonly property var signalColors: [red, orange, sea, "#FFFFFF"]
	readonly property int ledRiseMs: 800
	readonly property int ledFlashMs: 200
	readonly property int ledPauseMs: 300
	readonly property int ledDimMs: 2000
	property real t: 0
	property real focusX: width * 0.5
	property real focusY: height * 0.5
	property bool grabbed: false

	function node(index, count) {
		var a = t * (0.22 + (index % 3) * 0.04) + index * Math.PI * 2 / count;
		var r = Math.min(width, height) * (0.24 + (index % 5) * 0.026);
		return {
			x: width * 0.5 + Math.cos(a) * r,
			y: height * 0.5 + Math.sin(a * 1.18) * r * 0.72
		};
	}

	function steer(x, y) {
		grabbed = true;
		focusX = Math.max(40, Math.min(width - 40, x));
		focusY = Math.max(40, Math.min(height - 40, y));
		field.requestPaint();
	}

	function ease(value) {
		var v = Math.max(0, Math.min(1, value));
		return v * v * (3 - 2 * v);
	}

	function ledLevel(index) {
		var step = ledRiseMs + ledFlashMs + ledPauseMs;
		var dimStart = step * 2 + ledRiseMs + ledFlashMs;
		var ms = (t * 1000) % (dimStart + ledDimMs);
		var local = ms - index * step;

		if (ms >= dimStart)
			return 1 - ease((ms - dimStart) / ledDimMs);
		if (local < 0)
			return 0;
		if (local < ledRiseMs)
			return ease(local / ledRiseMs);
		if (local < ledRiseMs + ledFlashMs)
			return ease((local - ledRiseMs) / ledFlashMs);
		return 1;
	}

	Canvas {
		id: field
		anchors.fill: parent
		antialiasing: true

		onPaint: {
			var ctx = getContext("2d");
			var w = width;
			var h = height;
			var cx = w * 0.5;
			var cy = h * 0.5;
			var count = 18;

			ctx.clearRect(0, 0, w, h);

			var glow = ctx.createRadialGradient(root.focusX, root.focusY, 8, root.focusX, root.focusY, Math.min(w, h) * 0.42);
			glow.addColorStop(0, "rgba(255,144,30,0.34)");
			glow.addColorStop(0.48, "rgba(236,0,0,0.12)");
			glow.addColorStop(1, "rgba(0,127,152,0)");
			ctx.fillStyle = glow;
			ctx.fillRect(0, 0, w, h);

			ctx.lineCap = "round";
			for (var ring = 0; ring < 4; ++ring) {
				ctx.beginPath();
				ctx.arc(cx, cy, Math.min(w, h) * (0.18 + ring * 0.075), 0, Math.PI * 2);
				ctx.strokeStyle = "rgba(255,255,255," + (0.08 - ring * 0.012) + ")";
				ctx.lineWidth = 1.2;
				ctx.stroke();
			}

			for (var i = 0; i < count; ++i) {
				var p = root.node(i, count);
				var color = root.signalColors[i % root.signalColors.length];
				var phase = (Math.sin(root.t * 1.7 + i) + 1) * 0.5;
				var px = p.x + (root.focusX - p.x) * phase;
				var py = p.y + (root.focusY - p.y) * phase;

				ctx.beginPath();
				ctx.moveTo(p.x, p.y);
				ctx.lineTo(root.focusX, root.focusY);
				ctx.strokeStyle = "rgba(255,255,255,0.13)";
				ctx.lineWidth = 1;
				ctx.stroke();

				ctx.beginPath();
				ctx.arc(px, py, 3.2 + phase * 2.4, 0, Math.PI * 2);
				ctx.fillStyle = color;
				ctx.globalAlpha = 0.48 + phase * 0.42;
				ctx.fill();
				ctx.globalAlpha = 1;

				ctx.beginPath();
				ctx.arc(p.x, p.y, 5 + Math.sin(root.t * 2 + i) * 1.2, 0, Math.PI * 2);
				ctx.fillStyle = color;
				ctx.fill();
			}

			for (var ripple = 0; ripple < 4; ++ripple) {
				var r = ((root.t * 74 + ripple * 64) % 256) + 24;
				ctx.beginPath();
				ctx.arc(root.focusX, root.focusY, r, 0, Math.PI * 2);
				ctx.strokeStyle = "rgba(255,255,255," + (0.16 * (1 - r / 304)) + ")";
				ctx.lineWidth = 2;
				ctx.stroke();
			}
		}
	}

	Rectangle {
		id: coreGlow
		width: Math.min(parent.width, parent.height) * 0.18
		height: width
		radius: width * 0.5
		anchors.centerIn: parent
		color: "#44FFFFFF"
		scale: 1 + Math.sin(root.t * 2.2) * 0.08 + (root.grabbed ? 0.1 : 0)
	}

	Image {
		id: logo
		width: Math.min(parent.width, parent.height) * 0.18
		height: width
		anchors.centerIn: parent
		source: "qrc:/assets/hexdev_logo.svg"
		fillMode: Image.PreserveAspectFit
		rotation: Math.sin(root.t * 0.7) * 4
		scale: 1 + Math.sin(root.t * 1.6) * 0.035
	}

	Column {
		x: 32
		y: 54
		spacing: 4

		Text {
			text: "Tempo2Market"
			color: "#F4F8FA"
			font.pixelSize: 30
			font.bold: true
		}
		Text {
			text: "Stop reinventing. Start innovating."
			color: "#C8D8DE"
			font.pixelSize: 14
		}
	}

	Row {
		anchors {
			right: parent.right
			top: parent.top
			margins: 44
			topMargin: 58
		}
		spacing: 10

		Repeater {
			model: ["BUILD", "SECURE", "SHIP"]
			Rectangle {
				width: 86
				height: 30
				radius: 5
				color: "#24FFFFFF"
				border.width: 1
				border.color: "#33FFFFFF"

				readonly property real led: root.ledLevel(index)

				Rectangle {
					width: 14
					height: 14
					radius: 7
					x: 7
					anchors.verticalCenter: parent.verticalCenter
					color: "#FFFFFF"
					opacity: parent.led * 0.16
				}
				Rectangle {
					width: 13
					height: 13
					radius: 7
					x: 7.5
					anchors.verticalCenter: parent.verticalCenter
					color: root.signalColors[index]
					opacity: 0.08 + parent.led * 0.42
				}
				Rectangle {
					width: 10
					height: 10
					radius: 5
					x: 9
					anchors.verticalCenter: parent.verticalCenter
					color: root.signalColors[index]
					opacity: 0.2 + parent.led * 0.8
				}
				Text {
					anchors.centerIn: parent
					text: modelData
					color: "#E7F0F5"
					font.pixelSize: 12
					font.bold: true
				}
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onPressed: function(mouse) { root.steer(mouse.x, mouse.y) }
		onPositionChanged: function(mouse) {
			if (pressed)
				root.steer(mouse.x, mouse.y)
		}
		onReleased: root.grabbed = false
	}

	Timer {
		interval: 16
		repeat: true
		running: true
		onTriggered: {
			root.t += 0.016;
			if (!root.grabbed) {
				root.focusX = root.width * (0.5 + Math.sin(root.t * 0.51) * 0.23);
				root.focusY = root.height * (0.5 + Math.cos(root.t * 0.39) * 0.18);
			}
			field.requestPaint();
		}
	}

	CodeLineBadge { lines: 231 }
}
