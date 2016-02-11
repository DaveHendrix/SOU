//
//  Game.swift
//  RobotWorld
//
//  Abstract:
//  Main class to handle game logic that isn't specific to individual entities
//
//  Created by David Hendrix on 1/31/16.
//  Copyright (c) 2016 RogueMinds.net. All rights reserved.
//

import SceneKit

struct MapPoint {
	var x: Float
	var z: Float
}

enum TileType : Character {
	case Open          = " "
	case Player01Start = "1"
	case Player02Start = "2"
	case Player03Start = "3"
	case Player04Start = "4"
	case Player05Start = "5"
	case Player06Start = "6"
	case Player07Start = "7"
	case Player08Start = "8"
	case Player09Start = "9"
	case Player10Start = "A"
	case Player11Start = "B"
	case Player12Start = "C"
	case Player13Start = "D"
	case Player14Start = "E"
	case Player15Start = "F"
	case Player16Start = "G"
	case Player17Start = "H"
	case Player18Start = "I"
	case Player19Start = "J"
	case Player20Start = "K"
	case Wall          = "w"
	case Tree          = "t"
	case Coffee        = "c"
	case RocketFuel    = "f"
	case MedicalBag    = "m"
	case BandAids      = "b"
	case Ship          = "r"
}

extension Character {
	var asTileType: TileType {
		switch (self) {
		case " ": 	return TileType.Open
		case "1":	return TileType.Player01Start
		case "2":	return TileType.Player02Start
		case "3":	return TileType.Player03Start
		case "4":	return TileType.Player04Start
		case "5":	return TileType.Player05Start
		case "6":	return TileType.Player06Start
		case "7":	return TileType.Player07Start
		case "8":	return TileType.Player08Start
		case "9":	return TileType.Player09Start
		case "A":	return TileType.Player10Start
		case "B":	return TileType.Player11Start
		case "C":	return TileType.Player12Start
		case "D":	return TileType.Player13Start
		case "E":	return TileType.Player14Start
		case "F":	return TileType.Player15Start
		case "G":	return TileType.Player16Start
		case "H":	return TileType.Player17Start
		case "I":	return TileType.Player18Start
		case "J":	return TileType.Player19Start
		case "K":	return TileType.Player20Start
		case "w":	return TileType.Wall
		case "t":	return TileType.Tree
		case "c":	return TileType.Coffee
		case "f":	return TileType.RocketFuel
		case "m":	return TileType.MedicalBag
		case "b":	return TileType.BandAids
		case "r":	return TileType.Ship
		default:	return TileType.Open
		}
	}
}

class Game {
	var level : GameLevel

	var walls           = [MapPoint]()
	var trees           = [MapPoint]()
	var coffee          = [MapPoint]()
	var medicalSupplies = [MapPoint]()
	var fuelDepots      = [MapPoint]()

	var width           = Float()
	var height          = Float()

	var visibleObstacles = [MapPoint]()
	
	init(levelNumber: Int) {
		print ("Loading game level \(levelNumber)")
		self.level           = GameLevel(levelNumber: levelNumber)
		self.walls           = level.scanMapForTileTypes(TileType.Wall)
		self.trees           = level.scanMapForTileTypes(TileType.Tree)
		self.coffee          = level.scanMapForTileTypes(TileType.Coffee)
		self.medicalSupplies = level.scanMapForTileTypes(TileType.MedicalBag)
		self.fuelDepots      = level.scanMapForTileTypes(TileType.RocketFuel)
		self.visibleObstacles = level.visibleObstacles

		self.width  = Float(level.width)
		self.height = Float(level.height)
	}	
}


