//
//  GameScene.swift
//  RobotWorld
//
//  Abstract:
//  Minimal SCNScene subclass to abstract game logic from scene content.
//
//  Created by David Hendrix on 1/31/16.
//  Copyright (c) 2016 RogueMinds.net. All rights reserved.
//

import SceneKit
import GameplayKit

class GameScene {

	var scene       = SCNScene()

	var wall        = SCNNode()
	var tree1       = SCNNode()
	var tree2       = SCNNode()
	var tree3       = SCNNode()
	var kiosk       = SCNNode()
	var bandAids    = SCNNode()
	var medicalBag  = SCNNode()
	var fuelVending = SCNNode()
	var ship        = SCNNode()

	var defaultCam  = SCNNode()
	var playerCam   = SCNNode()
	var skyCam      = SCNNode()
	var coffeeCam   = SCNNode()

	var players     = [SCNNode()]

	func loadGame(game: Game, gameView: GameView?) {
		// create a new scene
		scene = SCNScene(named: "art.scnassets/basic.scn")!

		// create and add a camera to the scene
		defaultCam = SCNNode()
		defaultCam.camera = SCNCamera()

		// place the camera
		defaultCam.position = SCNVector3(x: 0, y: 8, z: -15.0)
		defaultCam.eulerAngles = SCNVector3(x:-CGFloat(M_PI/4.0), y: CGFloat(M_PI), z:0.0)

		scene.rootNode.addChildNode(defaultCam)

		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLightTypeOmni
		lightNode.position = SCNVector3(x: 0, y: 20, z: 10)
		scene.rootNode.addChildNode(lightNode)

		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = NSColor.lightGrayColor()
		scene.rootNode.addChildNode(ambientLightNode)

		// retrieve references to cameras
		playerCam = scene.rootNode.childNodeWithName("playerCam", recursively: true)!
		skyCam    = scene.rootNode.childNodeWithName("skyCam", recursively: true)!
		coffeeCam = scene.rootNode.childNodeWithName("coffeeCam", recursively: true)!

		// retrieve the player node
		players[0] = scene.rootNode.childNodeWithName("player1", recursively: true)!

		// Set player starting location based on spot marked in ASCII map
		let playerX = game.level.players[0].x
		let playerZ = game.level.players[0].z
		players[0].position = SCNVector3(x: CGFloat(playerX), y: 0, z: CGFloat(playerZ))

//		// Add a second copy of the robot at 0,0,0
//		let newRobot = players[0].clone()
//		newRobot.position = SCNVector3(x: CGFloat(0.0), y: 0, z: CGFloat(0.0))
//		scene.rootNode.addChildNode(newRobot)
//
//		// Rotate the first robot
//		let animation = CABasicAnimation(keyPath: "rotation")
//		animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
//		animation.duration = 15.0
//		animation.repeatCount = MAXFLOAT //repeat forever
//		players[0].addAnimation(animation, forKey: nil)

		// set the scene to the view
		gameView!.scene = scene

		// allows the user to manipulate the camera
		gameView!.allowsCameraControl = true

		// show statistics such as fps and timing information
		gameView!.showsStatistics = true

		// configure the view
		gameView!.backgroundColor = NSColor.blackColor()

		// create walls
		let northWall = SCNNode(geometry: SCNBox(width: CGFloat(game.level.width) + 2.0, height: 1.0, length: 1.0, chamferRadius: 0.15))
		northWall.position = SCNVector3(x: 0.0, y: 0.0, z: -CGFloat((game.level.height/2.0) + 0.5))

		let southWall = northWall.clone()
		southWall.position = SCNVector3(x: 0.0, y: 0.0, z: CGFloat(game.level.height/2.0 + 0.5))

		let westWall = SCNNode(geometry: SCNBox(width: 1.0, height: 1.0, length: CGFloat(game.level.height) + 2.0, chamferRadius: 0.15))
		westWall.position = SCNVector3(x: -CGFloat(game.level.width/2.0 + 0.5), y: 0.0, z: 0.0)

		let eastWall = westWall.clone()
		eastWall.position = SCNVector3(x:  CGFloat(game.level.width/2.0 + 0.5), y: 0.0, z: 0.0)

		scene.rootNode.addChildNode(northWall)
		scene.rootNode.addChildNode(southWall)
		scene.rootNode.addChildNode(westWall)
		scene.rootNode.addChildNode(eastWall)

		populateItemsOfType(TileType.Tree,       atLocations: game.level.trees)
		populateItemsOfType(TileType.Wall,       atLocations: game.level.walls)
		populateItemsOfType(TileType.Coffee,     atLocations: game.level.coffeeKiosks)
		populateItemsOfType(TileType.BandAids,   atLocations: game.level.bandAids)
		populateItemsOfType(TileType.MedicalBag, atLocations: game.level.medicalBags)
		populateItemsOfType(TileType.RocketFuel, atLocations: game.level.fuelDepots)
		populateItemsOfType(TileType.Ship,       atLocations: game.level.ships)
	}

	func populateItemsOfType(type: TileType, atLocations locations: [MapPoint]) {
		
		var elevation = CGFloat(0.0)

		for point in locations {
			let node: SCNNode

			switch type {

			case TileType.Tree:
				node = self.tree2.clone()
				
			case TileType.Coffee:
				node = self.kiosk.clone()

			case TileType.BandAids:
				node = self.bandAids.clone()

			case TileType.MedicalBag:
				node = self.medicalBag.clone()

			case TileType.RocketFuel:
				node = self.fuelVending.clone()

			case TileType.Ship:
				node = self.ship.clone()

			default:
				node = self.wall.clone()

			}
			node.position = SCNVector3Make(CGFloat(point.x), elevation, CGFloat(point.z))

//			// Add a red glow to the cofee stand
//			if type == TileType.Coffee {
//				let material = node.geometry!.firstMaterial!
//				material.emission.contents = NSColor.redColor()
//			}

//			// Add a red glow to *only* the coffee stand
//			if type == TileType.Coffee {
//				//	Replace the coffee kiosk's geometry so we can isolate the material
//				let coffeeGeometry = SCNGeometry.init(sources: node.geometry!.geometrySources, elements: node.geometry!.geometryElements)
//				let material = coffeeGeometry.firstMaterial!
//				material.emission.contents = NSColor.redColor()
//				node.geometry = coffeeGeometry
//			}

			scene.rootNode.addChildNode(node)
		}
	}
	
	init() {
		guard let parts = SCNScene(named: "art.scnassets/parts.scn") else {
			return
		}

		let partsRoot = parts.rootNode

		wall        = partsRoot.childNodeWithName("Wall",           recursively: true)!
		tree1       = partsRoot.childNodeWithName("ConicTree",      recursively: true)!
		tree2       = partsRoot.childNodeWithName("SphericalTree",  recursively: true)!
		tree3       = partsRoot.childNodeWithName("Shrub",          recursively: true)!
		kiosk       = partsRoot.childNodeWithName("CoffeeKiosk",    recursively: true)!
		bandAids    = partsRoot.childNodeWithName("BandAids",       recursively: true)!
		medicalBag  = partsRoot.childNodeWithName("MedicalBag",     recursively: true)!
		fuelVending = partsRoot.childNodeWithName("VendingMachine", recursively: true)!
		ship        = partsRoot.childNodeWithName("Ship",           recursively: true)!
	}
}
