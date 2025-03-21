// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtMultimedia

Rectangle {
	id: container
	anchors.fill: parent
	color: "#343434"

	// The frame that holds the video
	Rectangle {
		id: videoFrame
		// Using 70% of the parent's width/height, frame (margin)
		width: parent.width * 0.6
		height: parent.height * 0.6
		anchors.centerIn: parent
		color: "transparent"   // Frame background "color"

		Video {
			id: videoPlayer
			anchors.fill: parent
			source: "qrc:/assets/hexdev_logo_video.webm"
			autoPlay: true
			fillMode: VideoOutput.PreserveAspectCrop
			loops: MediaPlayer.Infinite

			// click toggles play/pause
			MouseArea {
				anchors.fill: parent
				onClicked: {
						videoPlayer.playbackState === MediaPlayer.PlayingState ? videoPlayer.pause() : videoPlayer.play()
				}
			}
		}
	}
}
