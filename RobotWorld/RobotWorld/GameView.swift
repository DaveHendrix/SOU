//
//  GameView.swift
//  RobotWorld
//
//  Created by David Hendrix on 1/31/16.
//  Copyright (c) 2016 RogueMinds.net. All rights reserved.
//

import SceneKit

class GameView: SCNView {
	func makeCameraActive(cameraNode :SCNNode) {
		self.pointOfView = cameraNode
	}
}
