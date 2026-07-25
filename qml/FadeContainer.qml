// SPDX-License-Identifier: MIT
import QtQuick

Item {
	id: fadeContainer
	anchors.fill: parent

	property string requestedSource: ""
	property Loader currentLoader: null
	property Loader incomingLoader: null
	readonly property string currentSource:
		currentLoader === null ? "" : String(currentLoader.source)

	function switchTo(newSource) {
		newSource = String(newSource)
		if (newSource === "")
			return

		requestedSource = newSource
		advance()
	}

	function advance() {
		if (requestedSource === "" || incomingLoader !== null
				|| (currentLoader !== null && currentLoader.status === Loader.Loading))
			return

		if (requestedSource === currentSource)
			return

		if (currentLoader === null) {
			currentLoader = firstLoader
			currentLoader.opacity = 1
			currentLoader.z = 1
			currentLoader.source = requestedSource
			return
		}

		incomingLoader = currentLoader === firstLoader ? secondLoader : firstLoader
		incomingLoader.opacity = 0
		incomingLoader.z = 2
		incomingLoader.source = requestedSource
	}

	function handleStatus(loader) {
		if (loader.status === Loader.Error) {
			fail(loader)
			return
		}

		if (loader.status !== Loader.Ready)
			return

		if (loader === currentLoader) {
			advance()
			return
		}

		if (loader !== incomingLoader)
			return

		// Drop a superseded page before it ever becomes visible.
		if (String(loader.source) !== requestedSource) {
			incomingLoader = null
			release(loader)
			advance()
		} else {
			crossFadeAnimation.start()
		}
	}

	function release(loader) {
		loader.opacity = 0
		loader.z = 0
		loader.source = ""
	}

	function fail(loader) {
		var failedSource = String(loader.source)
		if (loader === incomingLoader) {
			incomingLoader = null
			release(loader)
			if (requestedSource === failedSource)
				requestedSource = currentSource
		} else if (loader === currentLoader) {
			currentLoader = null
			release(loader)
			if (requestedSource === failedSource)
				requestedSource = ""
		} else {
			return
		}

		console.warn("Failed to load page:", failedSource)
		advance()
	}

	function finishFade() {
		var oldLoader = currentLoader
		if (incomingLoader === null)
			return

		currentLoader = incomingLoader
		incomingLoader = null
		currentLoader.opacity = 1
		currentLoader.z = 1
		release(oldLoader)
		advance()
	}

	Loader {
		id: firstLoader
		anchors.fill: parent
		opacity: 0
		enabled: opacity > 0.01
		asynchronous: true
		onStatusChanged: fadeContainer.handleStatus(firstLoader)
	}

	Loader {
		id: secondLoader
		anchors.fill: parent
		opacity: 0
		enabled: opacity > 0.01
		asynchronous: true
		onStatusChanged: fadeContainer.handleStatus(secondLoader)
	}

	ParallelAnimation {
		id: crossFadeAnimation
		PropertyAnimation { target: fadeContainer.currentLoader; property: "opacity"; to: 0; duration: 600; easing.type: Easing.InOutQuad }
		PropertyAnimation { target: fadeContainer.incomingLoader; property: "opacity"; to: 1; duration: 600; easing.type: Easing.InOutQuad }
		onFinished: fadeContainer.finishFade()
	}
}
