// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Effects

Rectangle {
	id: root
	anchors.fill: parent
	color: "white"

	property real swingPhase: 0
	property real swingAmplitude: 8
	property real logoScale: 0.1
	property real logoRotation: 0
	property bool zooming: false
	property real zoomStartScale: 1
	readonly property url logoSource: "qrc:/assets/hexdev_logo.svg"
	readonly property real dragScale: 0.25
	readonly property real minLogoScale: 0.1
	readonly property real maxLogoScale: 2.0

	Component.onCompleted: logoScale = 1

	function clamp(value, minValue, maxValue) {
		return Math.max(minValue, Math.min(maxValue, value));
	}

	function setZooming(active) {
		zooming = active;
		if (active)
			zoomStartScale = logoScale;
		else
			logoScale = 1;
	}

	function setZoomScale(scale) {
		logoScale = clamp(scale, minLogoScale, maxLogoScale);
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.SizeVerCursor

		property real startY: 0

		onPressed: function(mouse) {
			root.setZooming(true);
			startY = mouse.y;
		}
		onPositionChanged: function(mouse) {
			if (pressed)
				root.setZoomScale(root.zoomStartScale + (startY - mouse.y) / Math.max(root.height * 0.5, 160));
		}
		onReleased: root.setZooming(false)
		onCanceled: root.setZooming(false)
	}

	Item {
		id: logo
		anchors.centerIn: parent
		anchors.verticalCenterOffset: -28
		width: Math.min(parent.width * 0.68, parent.height * 0.58, 330)
		height: width
		scale: root.logoScale

		Behavior on scale {
			enabled: !root.zooming
			NumberAnimation { duration: 800; easing.type: Easing.OutBack }
		}

		Image {
			anchors.centerIn: parent
			anchors.verticalCenterOffset: 8
			width: parent.width
			height: width
			source: root.logoSource
			fillMode: Image.PreserveAspectFit
			rotation: root.logoRotation
			opacity: 0.22
			layer.enabled: true
			layer.effect: MultiEffect {
				blurEnabled: true
				blur: 0.55
				colorization: 1
				colorizationColor: "#000000"
			}
		}

		Image {
			anchors.fill: parent
			source: root.logoSource
			fillMode: Image.PreserveAspectFit
			rotation: root.logoRotation
		}

		TapHandler {
			id: pressHandler
		}

		PinchHandler {
			target: null

			onActiveChanged: {
				root.setZooming(active);
			}
			onActiveScaleChanged: {
				if (active)
					root.setZoomScale(root.zoomStartScale * activeScale);
			}
		}

		DragHandler {
			id: dragHandler
			target: null

			property real startRotation: 0
			property real grabX: 0
			property real grabY: 0

			onActiveChanged: {
				if (active) {
					startRotation = root.logoRotation;
					grabX = centroid.pressPosition.x - logo.width / 2;
					grabY = centroid.pressPosition.y - logo.height / 2;
				} else {
					root.swingAmplitude = Math.max(8, Math.abs(root.logoRotation));
					root.swingPhase = root.logoRotation < 0 ? -Math.PI / 2 : Math.PI / 2;
				}
			}
			onTranslationChanged: {
				if (active) {
					var radius = Math.max(logo.width, logo.height) / 2;
					var dragAngle = (grabX * activeTranslation.y - grabY * activeTranslation.x) / radius;
					root.logoRotation = root.clamp(startRotation + dragAngle * root.dragScale, -32, 32);
				}
			}
		}
	}

	Timer {
		interval: 16
		repeat: true
		running: !root.zooming && !pressHandler.pressed && !dragHandler.active
		onTriggered: {
			root.swingPhase += 0.04;
			root.swingAmplitude += (8 - root.swingAmplitude) * 0.01;
			root.logoRotation = Math.sin(root.swingPhase) * root.swingAmplitude;
		}
	}

	CodeLineBadge { lines: 129 }
}
