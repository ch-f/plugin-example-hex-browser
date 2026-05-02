// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Item {
	id: fadeContainer
	anchors.fill: parent

	// Holds the URL of the current page displayed.
	property string currentSource: ""
	property string pendingSource: ""
	property var currentLoader: null
	property var loaders: []
	property var retainedLoaders: ({})

	// Initiates a crossfade transition from the current
	// page to the page specified by newSource
	function switchTo(newSource) {
		newSource = String(newSource)
		if (newSource === currentSource)
			return

		if (fadeIn.target !== null || crossFadeAnimation.running) {
			pendingSource = newSource
			return
		}

		var newLoader = loaderFor(newSource)
		if (currentLoader === null) {
			currentSource = newSource
			currentLoader = newLoader
			newLoader.source = newSource
			newLoader.opacity = 1
			newLoader.z = 1
			return
		}

		// Load the new page in an inactive loader.
		fadeOut.target = currentLoader
		fadeIn.target = newLoader
		newLoader.opacity = 0
		newLoader.z = 2
		if (String(newLoader.source) !== newSource)
			newLoader.source = newSource

		if (newLoader.status === Loader.Ready)
			crossFadeAnimation.start()
	}

	function loaderFor(source) {
		if (retainedLoaders[source])
			return retainedLoaders[source]

		for (var i = 0; i < loaders.length; ++i) {
			if (String(loaders[i].source) === source)
				return loaders[i]
		}

		for (var j = 0; j < loaders.length; ++j) {
			if (loaders[j] !== currentLoader && !retains(loaders[j]))
				return loaders[j]
		}

		return createLoader()
	}

	function createLoader() {
		var loader = loaderComponent.createObject(fadeContainer)
		loaders.push(loader)
		return loader
	}

	function retains(loader) {
		return loader.item && loader.item.retainAfterFade === true
	}

	function release(loader) {
		if (retains(loader)) {
			retainedLoaders[String(loader.source)] = loader
		} else {
			loader.source = ""
		}

		loader.opacity = 0
		loader.z = 0
	}

	function startWhenReady(loader) {
		if (loader === fadeIn.target && loader.status === Loader.Ready && !crossFadeAnimation.running)
			crossFadeAnimation.start()
	}

	function finishFade() {
		var oldLoader = fadeOut.target
		var newLoader = fadeIn.target
		if (!oldLoader || !newLoader)
			return

		// Keep the already-loaded incoming page alive as the active page.
		currentSource = String(newLoader.source)
		currentLoader = newLoader
		newLoader.opacity = 1
		newLoader.z = 1
		release(oldLoader)

		fadeOut.target = null
		fadeIn.target = null

		if (pendingSource !== "") {
			var source = pendingSource
			pendingSource = ""
			switchTo(source)
		}
	}

	Component {
		id: loaderComponent

		Loader {
			id: pageLoader
			anchors.fill: parent
			opacity: 0
			enabled: opacity > 0.01
			asynchronous: true
			onStatusChanged: fadeContainer.startWhenReady(pageLoader)
		}
	}

	ParallelAnimation {
		id: crossFadeAnimation
		PropertyAnimation { id: fadeOut; property: "opacity"; to: 0; duration: 600; easing.type: Easing.InOutQuad }
		PropertyAnimation { id: fadeIn; property: "opacity"; to: 1; duration: 600; easing.type: Easing.InOutQuad }
		onStopped: fadeContainer.finishFade()
	}
}
