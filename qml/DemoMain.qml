// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window 2.15

Item {
	id: root
	anchors.fill: parent

	// Define the two lists for OpenGL and non-OpenGL systems.
	property var pageListWithOpenGL: [
		"qrc:/Page1.qml",
		"qrc:/Page2.qml",
		"qrc:/Page3.qml",
		"qrc:/Page4.qml",
		"qrc:/Page5.qml",
		"qrc:/Page7.qml",
		"qrc:/Page8.qml",
		"qrc:/Page9.qml",
		"qrc:/Page10.qml",
		"qrc:/Page11.qml",
		"qrc:/Page12.qml",
		"qrc:/Page13.qml",
	]
	property var pageListNoOpenGL: [
		"qrc:/Page1.qml",
		"qrc:/Page2.qml",
		"qrc:/Page5.qml",
		"qrc:/Page7.qml",
		"qrc:/Page8.qml",
		"qrc:/Page10.qml",
		"qrc:/Page11.qml",
		"qrc:/Page12.qml",
		"qrc:/Page13.qml",
	]
	// This property will be assigned one of the lists.
	property var pageList: []
	property int currentIndex: 0

	Component.onCompleted: {
		var openGLSupported = Helper.hasOpenGLSupport();
		var qtMultimediaSupported = Helper.hasQtMultimediaSupport();

		console.log("OpenGL supported:", openGLSupported);
		console.log("QtMultimedia supported:", qtMultimediaSupported);

		var pages = openGLSupported ? pageListWithOpenGL.slice() : pageListNoOpenGL.slice();
		if (openGLSupported && qtMultimediaSupported)
			pages.splice(5, 0, "qrc:/Page6.qml");
		pageList = pages;

		// Initialize the FadeContainer with the first page.
		fadeBox.switchTo(pageList[currentIndex])
	}

	// FadeContainer (defined in FadeContainer.qml) that loads/fades between QML pages.
	FadeContainer {
		id: fadeBox
		anchors.fill: parent
	}

	// Observe page presses without taking the event from the loaded page.
	// Drag handling stays page-local, so long drags owned by a child MouseArea
	// may still outlive this timer reset.
	MouseArea {
		anchors.fill: fadeBox
		acceptedButtons: Qt.AllButtons
		propagateComposedEvents: true
		onPressed: function(mouse) {
			root.resetSwitchTimer()
			mouse.accepted = false
		}
	}

	PointHandler {
		acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchScreen | PointerDevice.TouchPad | PointerDevice.Stylus
		onActiveChanged: {
			if (pauseButton.checked)
				return

			active ? switchTimer.stop() : root.resetSwitchTimer()
		}
	}

	// Timer to switch pages automatically every 5 seconds.
	Timer {
		id: switchTimer
		interval: 5000  // 5 seconds
		repeat: true
		running: true
		onTriggered: nextPage()
	}

	// Row with navigation controls.
	Row {
		id: controlRow
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 12
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: 60

		// BACK BUTTON
		Button {
			text: "Back"
			scale: 1.5
			onClicked: {
				root.resetSwitchTimer()
				previousPage()
			}
		}

		// PAUSE BUTTON to toggle auto-switching.
		Button {
			id: pauseButton
			text: "Pause"
			scale: 1.5
			checkable: true
			onToggled: {
				switchTimer.running = !pauseButton.checked
			}
		}

		// NEXT BUTTON
		Button {
			text: "Next"
			scale: 1.5
			onClicked: {
				root.resetSwitchTimer()
				nextPage()
			}
		}
	}

	// Row to display the current page indicator.
	Row {
		id: controlRow2
		anchors.bottom: controlRow.top
		anchors.bottomMargin: 12
		anchors.horizontalCenter: controlRow.horizontalCenter
		spacing: 20

		Label {
			id: pageIndicator
			text: qsTr("Page ") + (currentIndex + 1) + " / " + pageList.length
			color: "black"
			background: Rectangle {
				color: "white"
				radius: 4
			}
		}
	}

	// Functions for page navigation.
	function nextPage() {
		currentIndex = (currentIndex + 1) % pageList.length;
		fadeBox.switchTo(pageList[currentIndex]);
	}

	function previousPage() {
		currentIndex = (currentIndex - 1 + pageList.length) % pageList.length;
		fadeBox.switchTo(pageList[currentIndex]);
	}

	function resetSwitchTimer() {
		if (!pauseButton.checked)
			switchTimer.restart()
	}
}
