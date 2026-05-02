// SPDX-License-Identifier: MIT
import QtQuick

Rectangle {
	id: root
	anchors.fill: parent
	color: "#F5F8FA"
	gradient: Gradient {
		GradientStop { position: 0; color: "#FFFFFF" }
		GradientStop { position: 1; color: "#E8F0F4" }
	}

	property real t: 0
	readonly property real load: 72 + Math.sin(t * 0.58) * 5
	readonly property real coolant: 286 + Math.sin(t * 0.41 + 0.7) * 7
	readonly property real pressure: 154 + Math.sin(t * 0.52 + 1.2) * 4
	readonly property real level: 0.56 + Math.sin(t * 0.47 + 2.4) * 0.06
	readonly property real control: 0.64 + Math.sin(t * 0.62 + 0.4) * 0.14
	readonly property real pulse: 0.55 + Math.sin(t * 4.2) * 0.45
	readonly property real primaryActivity: blinkActivity(0.7, 4.1)
	readonly property real feedwaterActivity: blinkActivity(1.1, 0.4)
	readonly property real rodActivity: blinkActivity(0.9, 2.2)
	readonly property real vacuumActivity: blinkActivity(0.55, 5.6)
	property int logIndex: 0
	property int typeIndex: 0
	property int typePause: 0
	property var consoleLines: []
	property string activeConsoleMessage: ""
	property string typedLine: ""
	property bool simulationRunning: true
	readonly property string consoleText: consoleLines.concat(activeConsoleMessage === "" ? [] : ["> " + typedLine]).join("\n")
	readonly property var consoleMessages: [
		"OK",
		"processing",
		"await valve CV-101 trim window",
		"sample primary loop pressure",
		"feedwater correction accepted",
		"rod drive delta within band",
		"pump P-201 torque envelope accepted",
		"steam header model updated after turbine load request",
		"condenser vacuum drift compensated",
		"governor demand synchronized",
		"await stable level feedback from LT-204",
		"processing secondary-loop heat balance",
		"OK - interlocks remain armed",
		"setpoint write queued for FV-203",
		"checking CV-301 response curve"
	]
	readonly property color red: "#EC0000"
	readonly property color orange: "#FF901E"
	readonly property color night: "#000327"
	readonly property color deep: "#003152"
	readonly property color sea: "#007F98"

	function blinkActivity(speed, phase) {
		return Math.sin(t * speed + phase) > 0.55 ? 1.0 : 0.0;
	}

	function startConsoleLine() {
		activeConsoleMessage = consoleMessages[logIndex % consoleMessages.length];
		typedLine = "";
		typeIndex = 0;
		typePause = 0;
		logIndex++;
	}

	function advanceConsole() {
		if (activeConsoleMessage === "") {
			startConsoleLine();
		} else if (typeIndex < activeConsoleMessage.length) {
			typedLine += activeConsoleMessage.charAt(typeIndex);
			typeIndex++;
		} else if (typePause < 18) {
			typePause++;
		} else {
			var lines = consoleLines.slice(-40);
			lines.push("> " + activeConsoleMessage);
			consoleLines = lines;
			startConsoleLine();
		}
	}

	component Panel: Rectangle {
		default property alias content: body.data
		property string title: ""

		radius: 10
		color: "#FBFFFFFF"
		border.width: 1
		border.color: "#24315266"

		Text {
			x: 18
			y: 13
			text: parent.title
			color: root.deep
			font.pixelSize: 15
			font.bold: true
		}

		Item {
			id: body
			anchors { fill: parent; margins: 18; topMargin: 44 }
		}
	}

	component Metric: Rectangle {
		required property string label
		required property string value
		required property color accent

		width: 112
		height: 68
		radius: 7
		color: "#FFFFFF"
		border.width: 1
		border.color: "#1F003152"

		Rectangle {
			anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
			width: 5
			radius: 2
			color: parent.accent
		}

		Text {
			x: 16
			y: 10
			text: parent.label
			color: "#52626B"
			font.pixelSize: 12
		}

		Text {
			x: 16
			y: 34
			text: parent.value
			color: root.night
			font.pixelSize: 18
			font.bold: true
		}
	}

	component StatusLine: Row {
		required property string label
		required property string value
		required property color accent
		property real activity: 1
		property bool binary: false
		property bool dark: false
		property real lineWidth: 220
		readonly property real labelWidth: Math.min(118, Math.max(58, width * 0.52))

		width: lineWidth
		height: 24
		spacing: 10

		Rectangle {
			width: 13
			height: 13
			radius: 7
			anchors.verticalCenter: parent.verticalCenter
			color: parent.binary && parent.activity <= 0.5 ? "#FFFFFF" : parent.accent
			opacity: parent.binary ? 1 : 0.42 + 0.58 * parent.activity
			border.width: 1
			border.color: "#44000327"
		}

		Text {
			width: parent.labelWidth
			anchors.verticalCenter: parent.verticalCenter
			text: parent.label
			color: parent.dark ? "#E7F0F5" : root.deep
			font.pixelSize: 13
			font.bold: true
			elide: Text.ElideRight
		}

		Text {
			width: parent.width - parent.labelWidth - 33
			anchors.verticalCenter: parent.verticalCenter
			text: parent.value
			color: parent.dark ? "#B8CAD3" : "#41515A"
			font.pixelSize: 13
			elide: Text.ElideRight
		}
	}

	component Pipe: Item {
		id: pipe
		required property real length
		property color accent: root.sea
		property bool vertical: false
		property bool reverse: false
		property int dots: 6
		property real speed: 0.22

		width: vertical ? 16 : length
		height: vertical ? length : 16

		Rectangle {
			anchors.fill: parent
			radius: 8
			color: "#D8E4EA"
		}

		Rectangle {
			anchors.fill: parent
			anchors.margins: 4
			radius: 5
			color: pipe.accent
			opacity: 0.25
		}

		Repeater {
			model: pipe.dots
			Rectangle {
				width: 7
				height: 7
				radius: 4
				color: pipe.accent
				opacity: 0.72
				readonly property real p: (root.t * pipe.speed + index / pipe.dots) % 1
				readonly property real pos: (pipe.reverse ? 1 - p : p) * (pipe.length - width)
				x: pipe.vertical ? pipe.width / 2 - width / 2 : pos
				y: pipe.vertical ? pos : pipe.height / 2 - height / 2
			}
		}
	}

	component Tank: Rectangle {
		id: tank
		default property alias content: body.data
		required property string label
		property real fill: 0.5
		property real fillOpacity: 0.5
		property color borderColor: root.deep
		property color labelColor: root.deep

		radius: 16
		color: "#FFFFFF"
		border.width: 2
		border.color: borderColor
		clip: true

		Item {
			anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
			height: parent.height * tank.fill
			clip: true

			Rectangle {
				anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
				height: parent.height + tank.radius
				radius: tank.radius
				color: root.sea
				opacity: tank.fillOpacity
			}
		}

		Item {
			id: body
			anchors.fill: parent
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 16
			text: tank.label
			color: tank.labelColor
			font.pixelSize: 14
			font.bold: true
		}
	}

	component Valve: Item {
		required property string label
		required property real open
		property color accent: root.red

		width: 62
		height: 66

		Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 38
			height: 38
			radius: 19
			color: "#FFFFFF"
			border.width: 2
			border.color: root.deep
		}

		Rectangle {
			anchors.horizontalCenter: parent.horizontalCenter
			y: 17
			width: 34
			height: 6
			radius: 3
			color: parent.accent
			rotation: -70 + parent.open * 140
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			y: 44
			text: parent.label
			color: root.deep
			font.pixelSize: 12
			font.bold: true
		}
	}

	component RotorUnit: Rectangle {
		id: unit
		required property string label
		property bool labelBelow: false
		property color bladeColor: root.sea
		property real bladeWidth: 54
		property real bladeHeight: 7
		property real spin: 200
		property color textColor: root.deep
		property int textSize: 12

		radius: height / 2
		color: "#FFFFFF"
		border.width: 2
		border.color: root.deep

		Repeater {
			model: 3
			Rectangle {
				anchors.centerIn: unit
				width: unit.bladeWidth
				height: unit.bladeHeight
				radius: height / 2
				color: unit.bladeColor
				rotation: root.t * unit.spin + index * 60
			}
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter
			y: unit.labelBelow ? parent.height + 6 : (parent.height - height) / 2
			text: unit.label
			color: unit.textColor
			font.pixelSize: unit.textSize
			font.bold: true
		}
	}

	Timer {
		interval: 16
		repeat: true
		running: root.simulationRunning
		onTriggered: root.t += interval / 1000
	}

	Timer {
		interval: 55
		repeat: true
		running: root.simulationRunning
		onTriggered: root.advanceConsole()
	}

	Component.onCompleted: {
		root.startConsoleLine();
	}

	Item {
		id: viewport
		anchors.fill: parent
		anchors.topMargin: 34
		anchors.bottomMargin: 34
	}

	Item {
		id: board
		width: 1100
		height: 612
		anchors.centerIn: viewport
		scale: Math.min(viewport.width / width, viewport.height / height)
		transformOrigin: Item.Center

		Rectangle {
			anchors.fill: parent
			radius: 14
			color: "#F9FCFD"
			border.width: 1
			border.color: "#26315266"
		}

		Rectangle {
			x: 22
			y: 20
			width: 1056
			height: 64
			radius: 10
			color: root.night

			Text {
				x: 22
				anchors.verticalCenter: parent.verticalCenter
				text: "Process Control Simulation"
				color: "#FFFFFF"
				font.pixelSize: 24
				font.bold: true
			}

			Row {
				anchors.right: parent.right
				anchors.rightMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				spacing: 14
				StatusLine { label: "Trip"; value: "armed"; accent: root.red; activity: root.pulse; dark: true; lineWidth: 168 }
				StatusLine { label: "Governor"; value: "tracking"; accent: root.orange; activity: 0.75 + root.pulse * 0.25; dark: true; lineWidth: 180 }
				StatusLine { label: "Output"; value: Math.round(root.load) + "%"; accent: root.sea; activity: 1; dark: true; lineWidth: 148 }
			}
		}

		Panel {
			x: 22
			y: 104
			width: 760
			height: 408
			title: "Primary and Secondary Loop"

			Item {
				anchors.fill: parent
				transform: Translate { y: -54 }

				Tank {
					id: vessel
					x: 30
					y: 76
					width: 128
					height: 236
					radius: 18
					label: "REACTOR"
					labelColor: "#FFFFFF"
					fill: root.level
					fillOpacity: 0.58

					Repeater {
						model: 5
						Rectangle {
							x: 26 + index * 16
							y: 28 + Math.sin(root.t * 0.7 + index) * 5
							width: 8
							height: 118
							radius: 3
							color: root.red
						}
					}
				}

				Rectangle {
					id: steam
					x: 292
					y: 70
					width: 140
					height: 244
					radius: 22
					color: "#FFFFFF"
					border.width: 2
					border.color: root.deep

					Repeater {
						model: 4
						Item {
							x: 28 + index * 20
							y: 42
							width: 26
							height: 150
							Rectangle { x: 0; y: 0; width: 7; height: 70; radius: 4; color: root.red; rotation: -9 }
							Rectangle { x: 16; y: 55; width: 7; height: 82; radius: 4; color: root.red; rotation: 11 }
						}
					}

					Rectangle {
						x: 24
						y: 160 + Math.sin(root.t * 1.1) * 5
						width: 92
						height: 4
						radius: 2
						color: root.sea
						rotation: Math.sin(root.t * 1.1) * 5
					}

					Repeater {
						model: 8
						Rectangle {
							readonly property real travel: 114
							readonly property real p: (root.t * 0.18 + index / 8) % 1
							width: 4 + index % 3
							height: width
							radius: width / 2
							x: 22 + index * 12
							y: 148 - p * travel
							color: root.sea
							opacity: 0.1 + p * 0.22
						}
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.bottom: parent.bottom
						anchors.bottomMargin: 16
						text: "STEAM"
						color: root.deep
						font.pixelSize: 14
						font.bold: true
					}
				}

				Pipe { x: 156; y: 134; length: 138; accent: root.red; speed: 0.28 }
				Pipe { x: 160; y: 244; length: 73; accent: root.orange; reverse: true; speed: 0.2 }
				Pipe { x: 217; y: 134; length: 110; vertical: true; accent: root.orange; reverse: true }
				Valve { label: "CV-101"; x: 194; y: 123; open: root.control; accent: root.red }
				Valve { label: "FV-203"; x: 194; y: 233; open: 0.55 + Math.sin(root.t * 0.54) * 0.16; accent: root.orange }

				RotorUnit {
					id: pump
					x: 172
					y: 306
					width: 76
					height: 76
					label: "P-201"
					labelBelow: true
					spin: 220
				}

				Pipe { x: pump.x + pump.width - 2; y: pump.y + 30; length: 132; accent: root.sea; speed: 0.25; dots: 4 }
				Pipe { x: steam.x + steam.width - 2; y: 128; length: 122; accent: root.orange; speed: 0.32 }
				Pipe { x: 552; y: 128; length: 48; accent: root.orange; speed: 0.32 }

				RotorUnit {
					id: turbine
					x: 552
					y: 88
					width: 128
					height: 92
					radius: 12
					color: root.deep
					border.width: 0
					label: "TURBINE"
					bladeWidth: 86
					bladeColor: root.orange
					spin: 190
					textColor: "#FFFFFF"
					textSize: 14
				}

				Tank {
					id: condenser
					x: 522
					y: 270
					width: 178
					height: 84
					radius: 12
					label: "CONDENSER"
					borderColor: root.sea
					fill: 0.46 + Math.sin(root.t * 0.66) * 0.04
					fillOpacity: 0.48
				}

				Pipe { x: turbine.x + 56; y: turbine.y + turbine.height - 1; length: condenser.y - turbine.y - turbine.height + 4; vertical: true; accent: root.sea }
				Pipe { x: 370; y: condenser.y + 31; length: condenser.x - 370; accent: root.sea; reverse: true; speed: 0.22 }
				Pipe { x: 370; y: condenser.y + 31; length: pump.y + 46 - condenser.y - 31; vertical: true; accent: root.sea; reverse: true; dots: 3 }
				Valve { label: "CV-301"; x: 424; y: 292; open: 0.7 + Math.sin(root.t * 0.5) * 0.1; accent: root.sea }
			}
		}

		Panel {
			x: 804
			y: 104
			width: 274
			height: 408
			title: "Control Loops"

			Grid {
				columns: 2
				spacing: 10
				Metric { label: "Load"; value: Math.round(root.load) + " %"; accent: root.red }
				Metric { label: "Coolant"; value: Math.round(root.coolant) + " C"; accent: root.orange }
				Metric { label: "Pressure"; value: Math.round(root.pressure) + " bar"; accent: root.deep }
				Metric { label: "Level"; value: Math.round(root.level * 100) + " %"; accent: root.sea }
			}

			Column {
				x: 0
				y: 160
				spacing: 12
				StatusLine { label: "Primary pump"; value: "running"; accent: root.sea; activity: root.primaryActivity; binary: true; lineWidth: 238 }
				StatusLine { label: "Feedwater"; value: "modulating"; accent: root.orange; activity: root.feedwaterActivity; binary: true; lineWidth: 238 }
				StatusLine { label: "Rod drive"; value: "tracking"; accent: root.red; activity: root.rodActivity; binary: true; lineWidth: 238 }
				StatusLine { label: "Vacuum"; value: "stable"; accent: root.deep; activity: root.vacuumActivity; binary: true; lineWidth: 238 }
			}

			Rectangle {
				x: 0
				y: 300
				width: 238
				height: 58
				radius: 8
				color: "#EDF5F8"
				border.width: 1
				border.color: "#22007F98"

				Text {
					x: 14
					y: 9
					text: "Valve command"
					color: root.deep
					font.pixelSize: 13
					font.bold: true
				}

				Rectangle {
					x: 14
					y: 34
					width: 210
					height: 9
					radius: 5
					color: "#D2E1E8"

					Rectangle {
						width: parent.width * root.control
						height: parent.height
						radius: 5
						color: root.sea
					}
				}
			}
		}

		Rectangle {
			x: 804
			y: 526
			width: 274
			height: 64
			radius: 10
			color: "#FBFFFFFF"
			border.width: 1
			border.color: "#24315266"

			Row {
				anchors.centerIn: parent
				spacing: 16

				Rectangle {
					width: 104
					height: 38
					radius: 7
					color: root.red
					opacity: root.simulationRunning ? 1 : 0.65

					Text {
						anchors.centerIn: parent
						text: "Stop"
						color: "#FFFFFF"
						font.pixelSize: 15
						font.bold: true
					}

					MouseArea {
						anchors.fill: parent
						onClicked: root.simulationRunning = false
					}
				}

				Rectangle {
					width: 104
					height: 38
					radius: 7
					color: root.sea
					opacity: root.simulationRunning ? 0.65 : 1

					Text {
						anchors.centerIn: parent
						text: "Start"
						color: "#FFFFFF"
						font.pixelSize: 15
						font.bold: true
					}

					MouseArea {
						anchors.fill: parent
						onClicked: root.simulationRunning = true
					}
				}
			}
		}

		Rectangle {
			x: 22
			y: 526
			width: 760
			height: 64
			radius: 10
			clip: true
			color: "#FFFFFF"
			border.width: 1
			border.color: "#24315266"

			Text {
				x: 14
				y: 8
				text: "CONTROL CONSOLE"
				color: root.deep
				font.pixelSize: 11
				font.bold: true
			}

			Item {
				id: consoleWindow
				x: 14
				y: 25
				width: parent.width - 28
				height: parent.height - 33
				clip: true

				Text {
					width: parent.width
					y: Math.min(0, parent.height - height)
					text: root.consoleText
					color: root.night
					font.pixelSize: 12
					font.family: "monospace"
					lineHeight: 1.05
					Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
				}
			}
		}

	}

	CodeLineBadge { lines: 654 }
}
