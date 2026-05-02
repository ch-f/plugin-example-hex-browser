// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick3D
import QtQuick3D.AssetUtils

Rectangle {
	id: root
	anchors.fill: parent
	color: "#202020"

	property real spinX: 0
	property real spinY: 0.3
	readonly property real dragScale: 0.5
	readonly property bool activePage: parent !== null && parent.opacity >= 0.99
	readonly property bool retainAfterFade: true

	function xDragDirection(yRotation) {
		return Math.cos(yRotation * Math.PI / 180) < 0 ? -1 : 1;
	}

	View3D {
		anchors.fill: parent
		camera: camera

		environment: SceneEnvironment {
			clearColor: root.color
			backgroundMode: SceneEnvironment.Color
			antialiasingMode: SceneEnvironment.MSAA
			antialiasingQuality: SceneEnvironment.High
			tonemapMode: SceneEnvironment.TonemapModeAces
			specularAAEnabled: true
			aoEnabled: true
			aoStrength: 38
			aoDistance: 24
			aoSoftness: 18
		}

		PerspectiveCamera {
			id: camera
			z: 350
		}

		DirectionalLight {
			eulerRotation.x: -50
			eulerRotation.y: -35
			brightness: 1.35
			color: "#FFF2DD"
			ambientColor: "#323232"
		}

		DirectionalLight {
			eulerRotation.x: 18
			eulerRotation.y: 145
			brightness: 0.28
			color: "#f4f8fe"
		}

		PointLight {
			x: 105
			y: 45
			z: -80
			brightness: 55
			color: "#d3e3fb"
		}

		SpotLight {
			x: -32
			y: 68
			z: 245
			eulerRotation.x: -14
			eulerRotation.y: -7
			brightness: 11
			coneAngle: 20
			innerConeAngle: 5
		}

		Node {
			id: modelRoot
			eulerRotation.x: 90
			scale: Qt.vector3d(180, 180, 180)

			RuntimeLoader {
				source: "qrc:/assets/hexdev_logo.glb"
			}
		}
	}

	Timer {
		interval: 16
		repeat: true
		running: root.activePage && !pressHandler.pressed && !dragHandler.active
		onTriggered: {
			modelRoot.eulerRotation.x += root.spinX;
			modelRoot.eulerRotation.y += root.spinY;
		}
	}

	TapHandler {
		id: pressHandler
	}

	DragHandler {
		id: dragHandler
		target: null

		property vector3d startRotation
		property real xDirection: 1
		property real lastX: 0
		property real lastY: 0

		onActiveChanged: {
			if (active) {
				startRotation = modelRoot.eulerRotation;
				xDirection = root.xDragDirection(startRotation.y);
				lastX = 0;
				lastY = 0;
			} else {
				if (Math.abs(root.spinX) < 0.01 && Math.abs(root.spinY) < 0.01)
					root.spinY = 0.15;
			}
		}
		onTranslationChanged: {
			if (active) {
				var dx = activeTranslation.x - lastX;
				var dy = activeTranslation.y - lastY;

				modelRoot.eulerRotation.x = startRotation.x + activeTranslation.y * root.dragScale * xDirection;
				modelRoot.eulerRotation.y = startRotation.y + activeTranslation.x * root.dragScale;
				root.spinX = dy * root.dragScale * xDirection;
				root.spinY = dx * root.dragScale;
				lastX = activeTranslation.x;
				lastY = activeTranslation.y;
			}
		}
	}

	CodeLineBadge { lines: 118 }
}
