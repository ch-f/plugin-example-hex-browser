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
		// "qrc:/Page6.qml", // disabled qtmedia
		"qrc:/Page7.qml",
	]
	property var pageListNoOpenGL: [
		"qrc:/Page1.qml",
		"qrc:/Page2.qml",
		"qrc:/Page5.qml",
		"qrc:/Page7.qml",
	]
	// This property will be assigned one of the lists.
	property var pageList: []
	property int currentIndex: 0

	Component.onCompleted: {
		console.log("OpenGL supported:", Helper.hasOpenGLSupport());
		if (Helper.hasOpenGLSupport()) {
			pageList = pageListWithOpenGL;
		} else {
			pageList = pageListNoOpenGL;
		}
		// Initialize the FadeContainer with the first page.
		fadeBox.switchTo(pageList[currentIndex])
	}

	// FadeContainer (defined in FadeContainer.qml) that loads/fades between QML pages.
	FadeContainer {
		id: fadeBox
		anchors.fill: parent
		// Initially load the page from pageList.
		currentSource: pageList.length > 0 ? pageList[currentIndex] : ""
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
				if (!pauseButton.checked)
					switchTimer.restart()
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
				if (!pauseButton.checked)
					switchTimer.restart()
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
}
