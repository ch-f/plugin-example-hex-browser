// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
	anchors.fill: parent
	color: "white"

	Canvas {
		id: drawingCanvas
		anchors.fill: parent
		// Using a framebuffer object as the render target (reduce flicker)
		renderTarget: Canvas.FramebufferObject

		// Enable offscreen rendering and apply a drop shadow effect to the whole canvas
		layer.enabled: true
		layer.effect: MultiEffect {
			shadowEnabled: true
			shadowHorizontalOffset: 0
			shadowVerticalOffset: 8
			shadowBlur: 0.5 // shadowBlur between 0.0 (no blur) and 1.0 (full blur)
			shadowColor: "#40000000"
		}

		// Store the current drawn path (an array of points)
		property var drawingPath: []

		onPaint: {
			var ctx = getContext("2d");
			ctx.clearRect(0, 0, width, height);
			ctx.strokeStyle = "red";
			ctx.lineWidth = 4;
			ctx.lineCap = "round";
			if (drawingPath.length > 0) {
				ctx.beginPath();
				ctx.moveTo(drawingPath[0].x, drawingPath[0].y);
				for (var i = 1; i < drawingPath.length; i++) {
					ctx.lineTo(drawingPath[i].x, drawingPath[i].y);
				}
				ctx.stroke();
			}
		}

		// MouseArea to record drawing input
		MouseArea {
			anchors.fill: parent
			onPressed: function(mouse) {
				drawingCanvas.drawingPath = [];
				drawingCanvas.drawingPath.push({ x: mouse.x, y: mouse.y });
				drawingCanvas.requestPaint();
			}
			onPositionChanged: function(mouse) {
				drawingCanvas.drawingPath.push({ x: mouse.x, y: mouse.y });
				drawingCanvas.requestPaint();
			}
		}

		// Apply the same rotation animation as before
		Behavior on rotation {
			NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
		}
		SequentialAnimation on rotation {
			loops: Animation.Infinite
			NumberAnimation { to: 3; duration: 2000; easing.type: Easing.InOutQuad }
			NumberAnimation { to: -3; duration: 2000; easing.type: Easing.InOutQuad }
		}
	}

	// Display a message until the user starts drawing
	Text {
		anchors.centerIn: parent
		text: "Draw on me"
		font.pointSize: 24
		color: "grey"
		visible: drawingCanvas.drawingPath.length === 0
	}
}
