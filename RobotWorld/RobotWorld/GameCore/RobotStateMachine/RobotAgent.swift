//
//  RobotAgent.swift
//  RobotWorld
//
//  Created by David Hendrix on 2/9/16.
//  Copyright © 2016 RogueMinds.net. All rights reserved.
//	Abstract:
//		A simple subclass of `GKAgent2D` used by `TaskBot`s.
//

import GameplayKit
import SceneKit

// Encapsulates a Robot's current mandate, i.e. the aim that the Robot is setting out to achieve.

enum RobotMandate {
	case Wander				// Wander, building the map
	case Fetch				// Go to an item
}

// The robot's GameplayKit world view

// Several things to note:
// The SceneKit coordinate system is 3D, with the "y" axis pointing up.
// 0, 0, 0 is the center of the scene, and any manipulation of the UI
// (via dragging, for example) uses that center.
//    -x is to the left ("west"), +x to the right ("east")
//    -y is down, +y is up
//    -z is forward ("north"), and +z is back ("south")
// In contrast, a GKGridGraph is a 2D array of fixed size. Movement is constrained to this integer grid.

class RobotAgent: GKAgent2D, GKAgentDelegate {

	private var gridObstacles   : [GKGridGraphNode] = []
	private var obstacleObjects : [GKPolygonObstacle] = []
	private var wallObjects     : [GKPolygonObstacle] = []

	private var target     = MapPoint(x: 0.0, z: 0.0)

	var sceneNode          = SCNNode()
	var wanderGoal         = GKGoal(toWander: 0.25)
	var fetchGoal          = GKGoal()
	var avoidObstaclesGoal = GKGoal(toAvoidObstacles: [], maxPredictionTime: 1.0)
	var graph              = GKGridGraph()

	var mandate            = RobotMandate.Wander

	var worldWidth         = Float(0)
	var worldHeight        = Float(0)
	var worldOffsetX       = Int32(0)
	var worldOffsetY       = Int32(0)
	var sceneOffsetX       = Float(0.0)
	var sceneOffsetZ       = Float(0.0)

	func configure(newNode :SCNNode) {
		let newPosition = vector_float2(-Float(newNode.position.x), Float(newNode.position.z))
		sceneNode = newNode
		self.delegate = self
		self.position = newPosition
		self.maxSpeed = 0.5
		self.maxAcceleration = 0.75
		self.radius = 0.5

		self.behavior = GKBehavior(goal: wanderGoal, weight: 6)
	}

	// Since we're using a GKGridGraph we don't have to worry about enclosing the edges. The GameplayKit framework will constrain paths to the grid when pathfinding.

	func setWorldBounds(width: Float, height: Float) {
		worldWidth   = width
		worldHeight  = height
		sceneOffsetX = width / 2.0
		sceneOffsetZ = height / 2.0
		worldOffsetX = 0 - Int32(width / 2.0)
		worldOffsetY = 0 - Int32(height / 2.0)

		let northWall = polygonObstacle(0.0, y:  sceneOffsetZ - 1.0, width: width, height: 1.0)
		let southWall = polygonObstacle(0.0, y: -sceneOffsetZ + 0.0, width: width, height: 1.0)

		let eastWall  = polygonObstacle(-sceneOffsetX - 1.0, y: 0.0, width: 1.0, height: height)
		let westWall  = polygonObstacle( sceneOffsetX + 0.0, y: 0.0, width: 1.0, height: height)

		wallObjects = [northWall, southWall, eastWall, westWall]

		updateBehavior()
	}
	
	func setTarget (targetLocation: MapPoint) {
		let myLocation = vector_int2(x: Int32(self.position.x), y: Int32(self.position.y))
		guard let myNode : GKGridGraphNode = graph.nodeAtGridPosition(myLocation) else {
			return
		}

		target = targetLocation // Save for reuse in agentWillUpdate()

		let theirLocation = vector_int2(x: Int32(target.x), y: Int32(target.z))
		guard let targetNode : GKGridGraphNode = graph.nodeAtGridPosition(theirLocation) else {
			return
		}

		let pathNodes = graph.findPathFromNode(myNode, toNode: targetNode)
		var twoDeeNodes = [GKGraphNode2D]()

		for node in pathNodes {
			let graphNode = node as! GKGridGraphNode
			let newTwoDeeNode = GKGraphNode2D(point: vector_float2(x: Float(graphNode.gridPosition.x), y: Float(graphNode.gridPosition.y)))
			twoDeeNodes.append(newTwoDeeNode)
		}

		//	Exercise: How would you simplify this?
		if twoDeeNodes.count > 2 {
			let path = GKPath(graphNodes: twoDeeNodes, radius: 0.125)
			if path.numPoints >= 2 {
				fetchGoal = GKGoal(toFollowPath: path, maxPredictionTime: 1.5, forward: true)
			} else {
				// Refuse to seek coffee if we can't generate a decent path
				mandate = .Wander
				updateBehavior()
			}
		} else {
			// If we're already too close to the target, stop seeking
			mandate = .Wander
			updateBehavior()
		}
	}

	func setObstacles(locations: [MapPoint]) {
		gridObstacles.removeAll()
		obstacleObjects.removeAll()
		for location in locations {


			let obstaclePolygon = polygonObstacle(-location.x, y: location.z, width: 1.0, height: 1.0)
			obstacleObjects.append(obstaclePolygon)

			let gridObstacleLocation = vector_int2(x: Int32(location.x), y: Int32(location.z))
			guard let gridObstacle = graph.nodeAtGridPosition(gridObstacleLocation) else {
				continue
			}
			gridObstacles.append(gridObstacle)

		}
		graph.removeNodes(gridObstacles)

		updateBehavior()
	}

	func polygonObstacle(x: Float, y: Float, width: Float, height: Float) -> GKPolygonObstacle {
		let leftX   = x - (width  / 2.0)
		let bottomY = y - (height / 2.0)
		let rightX  = x + (width  / 2.0)
		let topY    = y + (height / 2.0)

		let points = [
			vector_float2(leftX, bottomY),
			vector_float2(leftX, topY),
			vector_float2(rightX, topY),
			vector_float2(rightX, bottomY),
			vector_float2(leftX, bottomY)
		]

		return GKPolygonObstacle(points: UnsafeMutablePointer(points), count: 5)
	}

	func updateBehavior() {
		if (worldHeight < 1.0) || (worldWidth < 1.0) {
			return
		}

		graph = GKGridGraph.init(fromGridStartingAt: vector_int2(x: worldOffsetX, y: worldOffsetY), width: Int32(worldWidth), height: Int32(worldHeight), diagonalsAllowed: false)

		graph.removeNodes(gridObstacles)

		let thingsToAvoid = obstacleObjects + wallObjects

		avoidObstaclesGoal = GKGoal(toAvoidObstacles: thingsToAvoid, maxPredictionTime: 1.0)

		var goalDictionary = [GKGoal : NSNumber]()

		switch mandate {
		case .Wander:
			goalDictionary[avoidObstaclesGoal] = 4
			goalDictionary[wanderGoal] = 3

		case .Fetch:
			goalDictionary[fetchGoal] = 10
		}

		self.behavior?.removeAllGoals()
		self.behavior = GKBehavior(weightedGoals: goalDictionary)
	}

	func agentWillUpdate(agent: GKAgent) {
	}

	func agentDidUpdate(_: GKAgent) {
		sceneNode.position.x = CGFloat(self.position.x)
		sceneNode.position.z = CGFloat(self.position.y)
		sceneNode.eulerAngles = SCNVector3(0.0, -self.rotation + Float(M_PI/2.0), 0.0)
		print ("loc x: \(self.position.x), y: \(self.position.y)")

		setTarget(target) // Reset the path and goal based on new position
	}

}
