// SPDX-License-Identifier: MIT
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: "white"
	gradient: Gradient {
		GradientStop { position: 0; color: "white" }
		GradientStop { position: 1; color: "#EEF5F8" }
	}

	property var blocks: [
		{ "letter": "h", "color": "#EC0000", "cutout": true },
		{ "letter": "e", "color": "#FF901E", "cutout": false },
		{ "letter": "x", "color": "#007F98", "cutout": true },
		{ "letter": "D", "color": "#003152", "cutout": true },
		{ "letter": "E", "color": "#000327", "cutout": true },
		{ "letter": "V", "color": "#EC0000", "cutout": true }
	]
	readonly property real blockSize: Math.max(34, Math.min(70, width / 9, height / 5))
	readonly property real ropeLength: Math.max(88, Math.min(185, height * 0.36))

	function resetExcept(index) {
		for (var i = 0; i < pendulums.count; ++i) {
			var pendulum = pendulums.itemAt(i);
			if (pendulum && i !== index)
				pendulum.angle = 0;
		}
	}

	function releaseBlock(index, angle) {
		var source = pendulums.itemAt(index);
		if (!source)
			return;

		if (Math.abs(angle) < 2) {
			source.angle = 0;
			return;
		}

		cradleAnimation.stop();
		cradleAnimation.sourceIndex = index;
		cradleAnimation.targetIndex = angle > 0 ? pendulums.count - 1 : 0;
		cradleAnimation.returnIndex = cradleAnimation.targetIndex === 0 ? pendulums.count - 1 : 0;
		cradleAnimation.direction = angle > 0 ? -1 : 1;
		cradleAnimation.power = Math.max(12, Math.min(34, Math.abs(angle)));
		cradleAnimation.start();
	}

	Item {
		anchors.centerIn: parent
		anchors.verticalCenterOffset: -16
		width: root.blockSize * root.blocks.length + 18
		height: root.ropeLength + root.blockSize + 34

		Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			width: parent.width
			height: 8
			radius: 4
			color: "#000327"
		}

		Row {
			anchors.top: parent.top
			anchors.topMargin: 8
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 0

			Repeater {
				id: pendulums
				model: root.blocks

				Item {
					id: pendulum
					width: root.blockSize
					height: root.ropeLength + root.blockSize
					property real angle: 0

					transform: Rotation {
						origin.x: pendulum.width / 2
						origin.y: 0
						angle: pendulum.angle
					}

					Rectangle {
						anchors.horizontalCenter: parent.horizontalCenter
						width: 2
						height: root.ropeLength
						color: "#7788949C"
					}

					Item {
						anchors.horizontalCenter: parent.horizontalCenter
						y: root.ropeLength - 1
						width: root.blockSize
						height: root.blockSize

						Canvas {
							anchors.fill: parent
							onWidthChanged: requestPaint()
							onHeightChanged: requestPaint()
							onPaint: {
								var ctx = getContext("2d");
								ctx.clearRect(0, 0, width, height);
								ctx.fillStyle = modelData.color;
								ctx.fillRect(0, 0, width, height);
								if (modelData.cutout) {
									ctx.globalCompositeOperation = "destination-out";
									ctx.font = "bold " + Math.round(width * 0.44) + "px sans-serif";
									ctx.textAlign = "center";
									ctx.textBaseline = "middle";
									ctx.fillText(modelData.letter, width / 2, height / 2);
									ctx.globalCompositeOperation = "source-over";
								}
							}
						}

						Text {
							anchors.centerIn: parent
							text: modelData.letter
							visible: !modelData.cutout
							color: "#000327"
							font.pixelSize: parent.width * 0.44
							font.bold: true
						}

						DragHandler {
							id: dragHandler
							target: null
							property real startAngle: 0

							onActiveChanged: {
								if (active) {
									startupAnimation.stop();
									cradleAnimation.stop();
									root.resetExcept(index);
									startAngle = pendulum.angle;
								} else {
									root.releaseBlock(index, pendulum.angle);
								}
							}
							onTranslationChanged: {
								if (active)
									pendulum.angle = Math.max(-38, Math.min(38, startAngle - activeTranslation.x / root.ropeLength * 60));
							}
						}
					}
				}
			}
		}
	}

	SequentialAnimation {
		id: startupAnimation

		ScriptAction { script: startupOut.target = pendulums.itemAt(0) }
		NumberAnimation { id: startupOut; property: "angle"; to: 24; duration: 520; easing.type: Easing.OutQuad }
		ScriptAction { script: root.releaseBlock(0, 24) }
	}

	SequentialAnimation {
		id: cradleAnimation
		property int sourceIndex: 0
		property int targetIndex: 0
		property int returnIndex: 0
		property real direction: 1
		property real power: 22

		ScriptAction {
			script: {
				root.resetExcept(cradleAnimation.sourceIndex);
				sourceIn.target = pendulums.itemAt(cradleAnimation.sourceIndex);
				targetOut.target = pendulums.itemAt(cradleAnimation.targetIndex);
				targetIn.target = pendulums.itemAt(cradleAnimation.targetIndex);
				echoOut.target = pendulums.itemAt(cradleAnimation.returnIndex);
				echoIn.target = pendulums.itemAt(cradleAnimation.returnIndex);
			}
		}
		NumberAnimation { id: sourceIn; property: "angle"; to: 0; duration: 320; easing.type: Easing.InQuad }
		NumberAnimation { id: targetOut; property: "angle"; to: cradleAnimation.direction * cradleAnimation.power; duration: 360; easing.type: Easing.OutQuad }
		NumberAnimation { id: targetIn; property: "angle"; to: 0; duration: 430; easing.type: Easing.InQuad }
		NumberAnimation { id: echoOut; property: "angle"; to: -cradleAnimation.direction * cradleAnimation.power * 0.45; duration: 330; easing.type: Easing.OutQuad }
		NumberAnimation { id: echoIn; property: "angle"; to: 0; duration: 390; easing.type: Easing.InQuad }
	}

	Component.onCompleted: startupAnimation.start()

	CodeLineBadge { lines: 166 }
}
