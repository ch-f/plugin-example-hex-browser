// SPDX-License-Identifier: MIT
import QtQuick
import QtMultimedia

Rectangle {
	id: root
	anchors.fill: parent
	color: "#343434"

	readonly property string videoSource: "qrc:/assets/hexdev_logo_video.webm"
	readonly property string videoFileName: videoSource.substring(videoSource.lastIndexOf("/") + 1)
	readonly property real progress: video.duration > 0 ? video.position / video.duration : 0
	property bool paused: false
	property bool reverse: false
	readonly property string stateText: paused ? "paused" : (reverse ? "reverse" : "playing")

	function timeText(ms) {
		var seconds = Math.floor(ms / 1000);
		var centis = Math.floor((ms % 1000) / 10);
		return seconds + "." + ("0" + centis).slice(-2) + " s";
	}

	function togglePlayback() {
		paused = !paused;
		if (reverse)
			reverseTimer.running = !paused;
		else
			paused ? video.pause() : video.play();
	}

	function startReverse() {
		reverse = true;
		video.pause();
		if (!paused)
			reverseTimer.start();
	}

	function startForward() {
		reverse = false;
		reverseTimer.stop();
		video.seek(0);
		if (!paused)
			video.play();
	}

	Timer {
		id: reverseTimer
		interval: 33
		repeat: true
		onTriggered: {
			video.seek(Math.max(0, video.position - interval));
			if (video.position === 0)
				root.startForward();
		}
	}

	Rectangle {
		id: panel
		anchors.horizontalCenter: parent.horizontalCenter
		anchors { top: parent.top; bottom: parent.bottom }
		anchors.topMargin: 38
		anchors.bottomMargin: Math.min(120, Math.max(72, parent.height * 0.16))
		width: Math.min(parent.width * 0.86, 980)
		radius: 8
		color: "#343434"
		border.width: 1
		border.color: "#24FFFFFF"

		Item {
			id: mediaArea
			anchors { left: parent.left; right: parent.right; top: parent.top; bottom: telemetry.top }
			anchors.margins: 10

			Video {
				id: video
				anchors.centerIn: parent
				width: Math.min(parent.width, parent.height)
				height: width
				source: root.videoSource
				autoPlay: true
				fillMode: VideoOutput.PreserveAspectFit
				loops: 1

				onPositionChanged: {
					if (!root.reverse && !root.paused && duration > 0 && position >= duration - 40)
						root.startReverse();
				}

				MouseArea {
					anchors.fill: parent
					onClicked: root.togglePlayback()
				}
			}
		}

		Rectangle {
			id: telemetry
			anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
			height: Math.min(76, Math.max(62, parent.height * 0.14))
			color: "#282828"
			radius: parent.radius

			Rectangle {
				anchors { left: parent.left; right: parent.right; top: parent.top }
				height: 1
				color: "#30FFFFFF"
			}

			Column {
				anchors.fill: parent
				anchors.margins: 12
				spacing: 10

				Row {
					id: timeRow
					width: parent.width
					spacing: 18

					Text {
						width: 96
						text: root.stateText
						color: root.paused ? "#D7D7D7" : (root.reverse ? "#FFCF8A" : "#9BE8C1")
						font.pixelSize: 18
						font.bold: true
					}

					Text {
						width: parent.width - 96 - timeRow.spacing
						text: root.timeText(video.position) + " / " + root.timeText(video.duration)
						color: "#E6E6E6"
						font.pixelSize: 18
						font.family: "monospace"
						elide: Text.ElideRight
					}
				}

				Rectangle {
					width: parent.width
					height: 8
					radius: 4
					color: "#343434"

					Rectangle {
						width: parent.width * root.progress
						height: parent.height
						radius: parent.radius
						color: "#FF901E"
					}
				}
			}
		}
	}

	Item {
		id: videoCaption
		anchors.left: panel.left
		anchors.bottom: panel.top
		anchors.bottomMargin: 6
		width: panel.width
		height: videoFileName.implicitHeight

		Text {
			id: videoLabel
			anchors.left: parent.left
			anchors.baseline: videoFileName.baseline
			text: "video:"
			color: "#AAAAAA"
			font.pixelSize: 14
			font.bold: true
		}

		Text {
			id: videoFileName
			anchors.left: videoLabel.right
			anchors.leftMargin: 4
			width: Math.max(80, Math.min(280, parent.width - videoLabel.width - anchors.leftMargin))
			text: root.videoFileName
			color: "#AAAAAA"
			font.pixelSize: 14
			font.family: "monospace"
			elide: Text.ElideRight
		}
	}

	CodeLineBadge { lines: 161 }
}
