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

		// Keep frame strokes, but reset to one active stroke when the user draws.
		property var strokes: []
		property var frameStrokes: []
		property int frameStrokeIndex: 0
		property int framePointIndex: 0
		property bool userHasDrawn: false

		function sideStroke(side, margin, count, wobble) {
			var points = [];
			for (var i = 0; i < count; ++i) {
				var t = i / (count - 1);
				var drift = Math.sin(t * Math.PI * 3 + side) * wobble + (Math.random() - 0.5) * wobble;
				var bow = Math.sin(t * Math.PI) * wobble * 0.7;
				if (side === 0)
					points.push({ x: margin + (width - margin * 2) * t, y: margin + drift + bow });
				else if (side === 1)
					points.push({ x: width - margin + drift - bow, y: margin + (height - margin * 2) * t });
				else if (side === 2)
					points.push({ x: width - margin - (width - margin * 2) * t, y: height - margin + drift - bow });
				else
					points.push({ x: margin + drift + bow, y: height - margin - (height - margin * 2) * t });
			}
			return points;
		}

		function makeFrame() {
			var margin = Math.min(width, height) * 0.08;
			frameStrokes = [];
			for (var side = 0; side < 4; ++side)
				frameStrokes.push({ points: sideStroke(side, margin, 34, 3.0), color: "#EC0000", width: 4 });
		}

		function drawNextFramePoint() {
			if (userHasDrawn || width <= 0 || height <= 0)
				return;
			if (frameStrokes.length === 0)
				makeFrame();
			if (frameStrokeIndex >= frameStrokes.length) {
				frameTimer.stop();
				return;
			}
			if (framePointIndex === 0)
				strokes.push({ points: [], color: frameStrokes[frameStrokeIndex].color, width: frameStrokes[frameStrokeIndex].width });
			strokes[strokes.length - 1].points.push(frameStrokes[frameStrokeIndex].points[framePointIndex++]);
			if (framePointIndex >= frameStrokes[frameStrokeIndex].points.length) {
				frameStrokeIndex++;
				framePointIndex = 0;
			}
			requestPaint();
		}

		function startUserStroke(x, y) {
			userHasDrawn = true;
			frameTimer.stop();
			frameStrokes = [];
			frameStrokeIndex = 0;
			framePointIndex = 0;
			strokes = [{ points: [{ x: x, y: y }], color: "red", width: 4 }];
			requestPaint();
		}

		function addUserPoint(x, y) {
			if (strokes.length === 0)
				return;
			strokes[strokes.length - 1].points.push({ x: x, y: y });
			requestPaint();
		}

		onPaint: {
			var ctx = getContext("2d");
			ctx.clearRect(0, 0, width, height);
			ctx.lineCap = "round";
			ctx.lineJoin = "round";
			for (var s = 0; s < strokes.length; ++s) {
				if (strokes[s].points.length === 0)
					continue;
				ctx.strokeStyle = strokes[s].color;
				ctx.lineWidth = strokes[s].width;
				ctx.beginPath();
				ctx.moveTo(strokes[s].points[0].x, strokes[s].points[0].y);
				for (var i = 1; i < strokes[s].points.length - 1; ++i) {
					var next = strokes[s].points[i + 1];
					ctx.quadraticCurveTo(strokes[s].points[i].x, strokes[s].points[i].y, (strokes[s].points[i].x + next.x) * 0.5, (strokes[s].points[i].y + next.y) * 0.5);
				}
				if (strokes[s].points.length > 1)
					ctx.lineTo(strokes[s].points[strokes[s].points.length - 1].x, strokes[s].points[strokes[s].points.length - 1].y);
				ctx.stroke();
			}
		}

		Timer {
			id: frameTimer
			interval: 22
			repeat: true
			running: true
			onTriggered: drawingCanvas.drawNextFramePoint()
		}

		// MouseArea to record drawing input
		MouseArea {
			anchors.fill: parent
			onPressed: function(mouse) {
				drawingCanvas.startUserStroke(mouse.x, mouse.y);
			}
			onPositionChanged: function(mouse) {
				if (pressed)
					drawingCanvas.addUserPoint(mouse.x, mouse.y);
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
		visible: !drawingCanvas.userHasDrawn
	}

	CodeLineBadge { lines: 135 }
}
