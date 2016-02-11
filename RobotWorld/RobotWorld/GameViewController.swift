//
//  GameViewController.swift
//  RobotWorld
//
//  Created by David Hendrix on 1/31/16.
//  Copyright (c) 2016 RogueMinds.net. All rights reserved.
//

import GameKit
import QuartzCore
import SceneKit

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    @IBOutlet weak var gameView: GameView!
	
	let game = Game(levelNumber: 0)

	var shouldRun = false
	var scene = GameScene()

	var robotAgent = RobotAgent()
	var agentSystem = GKComponentSystem.init(componentClass: RobotAgent.self)
	var lastUpdateTime = NSTimeInterval(0.0)

//	var stopGoal:       GKGoal

    override func awakeFromNib() {
		
		//  Create the internal representation of the world
		
		//	Load the basic scene (from "basic.scn") into the window's view
		scene.loadGame(game, gameView: self.gameView)
		gameView.makeCameraActive(scene.defaultCam)
		gameView.delegate = self

		//  Load the GameplayKit Agent with details about our robot
		robotAgent.configure(scene.players[0])
		robotAgent.setWorldBounds(game.width, height: game.height)
		robotAgent.setObstacles(game.visibleObstacles)

		agentSystem.addComponent(robotAgent)
    }
	
	
	@IBAction func switchToDefaultCam(sender: AnyObject) {
		gameView.makeCameraActive(scene.defaultCam)
	}
	
	@IBAction func switchToShoulderCam(sender: AnyObject) {
		gameView.makeCameraActive(scene.playerCam)
	}
	
	@IBAction func switchToSkyCam(sender: AnyObject) {
		gameView.makeCameraActive(scene.skyCam)
	}
	
	@IBAction func switchToCoffeeCam(sender: AnyObject) {
		gameView.makeCameraActive(scene.coffeeCam)
	}

	@IBAction func play(sender: AnyObject) {
		shouldRun = true
		gameView.play(sender)
	}
	
	@IBAction func pause(sender: AnyObject) {
		shouldRun = false
		gameView.stop(sender)
		lastUpdateTime = NSTimeInterval(0.0)
	}

	@IBAction func seekCoffee(sender: AnyObject) {
		robotAgent.setTarget(game.coffee[0])
		robotAgent.mandate = RobotMandate.Fetch
		robotAgent.updateBehavior()
	}

	@IBAction func wander(sender: AnyObject) {
		robotAgent.mandate = RobotMandate.Wander
		robotAgent.updateBehavior()
	}

	// MARK: SCNSceneRendererDelegate Conformance (Game Loop)
	
	// SceneKit calls this method exactly once per frame, so long as the SCNView object (or other SCNSceneRenderer object) displaying the scene is not paused.
	// Implement this method to add game logic to the rendering loop. Any changes you make to the scene graph during this method are immediately reflected in the displayed scene.

	func renderer(renderer: SCNSceneRenderer, updateAtTime currentTime: NSTimeInterval) {
		if lastUpdateTime == NSTimeInterval(0.0) {
			lastUpdateTime = currentTime
		}
		let deltaTime = currentTime - lastUpdateTime
		lastUpdateTime = currentTime
		self.agentSystem.updateWithDeltaTime(deltaTime)
		renderer.playing = shouldRun
		if shouldRun == false {
			lastUpdateTime = NSTimeInterval(0.0)
		}

	}
	
	func renderer(renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: NSTimeInterval) {
	}

}
