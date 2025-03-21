// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls

Rectangle {
	id: testPattern
	anchors.fill: parent
	// Full-screen gradient background (from black to white)
	gradient: Gradient {
		GradientStop { position: 0; color: "black" }
		GradientStop { position: 1; color: "white" }
	}

	// Red border frame: a transparent rectangle with a red border 5 pixels wide
	Rectangle {
		anchors.fill: parent
		color: "transparent"
		border.color: "red"
		border.width: 5
	}

	// Horizontal red line forming the cross
	Rectangle {
		x: 5 // start just inside the left border
		y: testPattern.height/2 - 2.5
		width: testPattern.width - 10    // subtract left and right borders (5+5)
		height: 5
		color: "red"
	}

	// Vertical red line forming the cross
	Rectangle {
		x: testPattern.width/2 - 2.5
		y: 5 // start just inside the top border
		width: 5
		height: testPattern.height - 10 // subtract top and bottom borders
		color: "red"
	}
}
