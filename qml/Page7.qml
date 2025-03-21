import QtQuick 2.15
import QtQuick.Window 2.15

Rectangle {
	id: root
	anchors.fill: parent
	color: "black"

	// Holds each active pointer's list of (x,y) positions
	property var pointerPaths: ({})

	Text {
		id: textPrompt
		anchors.centerIn: parent
		text: "Draw on me"
		font.pointSize: 24
		color: "#b6b6b6"
		visible: true
	}

	Canvas {
		id: drawCanvas
		anchors.fill: parent

		onPaint: {
			var ctx = getContext("2d")
			ctx.clearRect(0, 0, width, height)

			// Draw each pointer's path
			for (var pointerId in pointerPaths) {
				var points = pointerPaths[pointerId]
				if (points.length > 1) {
					ctx.beginPath()
					ctx.moveTo(points[0].x, points[0].y)
					for (var i = 1; i < points.length; i++) {
						ctx.lineTo(points[i].x, points[i].y)
					}
					ctx.lineWidth = 3
					ctx.strokeStyle = "red"
					ctx.stroke()
				}

				// Draw a dot at the last known position
				if (points.length > 0) {
					var last = points[points.length - 1]
					ctx.beginPath()
					ctx.arc(last.x, last.y, 10, 0, 2 * Math.PI)
					ctx.fillStyle = "red"
					ctx.fill()
				}
			}
		}
	}

	MultiPointTouchArea {
		anchors.fill: parent

		// Called when a new touch point is pressed
		onPressed: function (touchPoints) {
			textPrompt.visible = false
			for (var i = 0; i < touchPoints.length; i++) {
				var tp = touchPoints[i]
				var id = tp.pointId

				//console.log("Pressed pointer", id, "at x:", tp.x, "y:", tp.y)

				// Create an array for this pointer if necessary
				if (!root.pointerPaths[id]) {
					root.pointerPaths[id] = []
				}
				// Push the current coordinate
				root.pointerPaths[id].push({x: tp.x, y: tp.y})
			}
			drawCanvas.requestPaint()
		}

		// Called when a touch point moves
		onUpdated: function (touchPoints) {
			for (var i = 0; i < touchPoints.length; i++) {
				var tp = touchPoints[i]
				var id = tp.pointId

				// Make sure an array exists
				if (!root.pointerPaths[id]) {
					root.pointerPaths[id] = []
				}
				root.pointerPaths[id].push({x: tp.x, y: tp.y})

				//console.log("Updated pointer", id, "at x:", tp.x, "y:", tp.y)
			}
			drawCanvas.requestPaint()
		}

		// Called when a touch point is released
		onReleased: function (touchPoints) {
			for (var i = 0; i < touchPoints.length; i++) {
				var tp = touchPoints[i]
				var id = tp.pointId

				//console.log("Released pointer", id, "at x:", tp.x, "y:", tp.y)

				if (!root.pointerPaths[id]) {
					root.pointerPaths[id] = []
				}
				// Final coordinate update before the touch point disappears
				root.pointerPaths[id].push({x: tp.x, y: tp.y})
			}
			drawCanvas.requestPaint()
		}
	}
}
