// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Item {
	id: fadeContainer
	anchors.fill: parent

	// Holds the URL of the current page displayed.
	property url currentSource: ""

	// Initiates a crossfade transition from the current
	// page to the page specified by newSource
	function switchTo(newSource) {
		if (newSource === currentSource)
			return
		// Load the new page in nextLoader
		nextLoader.source = newSource
		nextLoader.opacity = 0
		// Start the crossfade animation
		crossFadeAnimation.start()
	}

	// The activeLoader displays the current page
	Loader {
		id: activeLoader
		anchors.fill: parent
		source: fadeContainer.currentSource
		opacity: 1
		asynchronous: true
	}

	// The nextLoader will load the incoming page
	Loader {
		id: nextLoader
		anchors.fill: parent
		opacity: 0
		asynchronous: true
	}

	// Crossfade the active and next loader
	ParallelAnimation {
		id: crossFadeAnimation
		PropertyAnimation { target: activeLoader; property: "opacity"; to: 0; duration: 600; easing.type: Easing.InOutQuad }
		PropertyAnimation { target: nextLoader; property: "opacity"; to: 1; duration: 600; easing.type: Easing.InOutQuad }
		onStopped: {
			// After animation completes, update the currentSource and swap loaders
			fadeContainer.currentSource = nextLoader.source
			activeLoader.source = nextLoader.source
			activeLoader.opacity = 1
			nextLoader.source = ""
			nextLoader.opacity = 0
		}
	}
}
