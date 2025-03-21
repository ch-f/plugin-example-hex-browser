// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
	anchors.fill: parent
	color: "white"

	Image {
		id: animatedImage
		anchors.centerIn: parent
		source: "qrc:/assets/dummy.png"
		opacity: 1
		scale: 0.1

		// Enable offscreen rendering and apply the drop shadow via MultiEffect
		layer.enabled: true
		layer.effect: MultiEffect {
			shadowEnabled: true
			shadowHorizontalOffset: 0
			shadowVerticalOffset: 8
			shadowBlur: 0.5 // (range: 0.0 to 1.0)
			shadowColor: "#40000000"
		}

		Behavior on opacity {
			NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
		}
		Behavior on scale {
			NumberAnimation { duration: 800; easing.type: Easing.OutBack }
		}

		Component.onCompleted: {
			opacity = 1;
			scale = 1;
		}

		SequentialAnimation on rotation {
			loops: Animation.Infinite
			NumberAnimation { to: 8; duration: 2000; easing.type: Easing.InOutQuad }
			NumberAnimation { to: -8; duration: 2000; easing.type: Easing.InOutQuad }
		}
	}
}
