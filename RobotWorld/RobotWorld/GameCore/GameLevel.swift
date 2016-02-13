//
//  GameLevel.swift
//  RobotWorld
//
//  Abstract:
//  Model class for a level (in this sample, the only level) in the game.
//
//  Created by David Hendrix on 1/31/16.
//  Copyright (c) 2016 RogueMinds.net. All rights reserved.
//

import GameplayKit

class GameLevel {
	
	var width  = 0.0
	var height = 0.0
	
	// Array of strings with ASCII characters that indicate positions of objects
	var asciiMap     = [String]()

	// Robots
	var players      = [MapPoint]()
	
	// Obstacles
	var walls        = [MapPoint]()
	var trees        = [MapPoint]()

	// MacGuffins
	var coffeeKiosks = [MapPoint]()
	var fuelDepots   = [MapPoint]()
	var medicalBags  = [MapPoint]()
	var bandAids     = [MapPoint]()
	var ships        = [MapPoint]()

	var visibleObstacles = [MapPoint]()

	func loadMap() -> [String] {
		// Currently assumes static array of strings define the map. What if this was a file
		// retrieved from a server someplace like: https://www.rogueminds.net/simplemap.txt

		var map = [String]()

//			map = [ "                 t             tttttt    ",
//					"   t            t t  2       tt      tt  ",
//					"    t    3     t t t t      t       r  t ",
//					"  tt          t t t t t     t            ",
//					" t   b  t          t        t  4       t ",
//					"   t      t                  tt      tt  ",
//					"      t  ttt ttttt             ttttt     ",
//					" tttt    t       t      b                ",
//					"    t    t   f   t                       ",
//					"   r t   t       t        ttttttttt      ",
//					"     t   ttttttttt  m     t       t      ",
//					"     t                b    t   b  t      ",
//					"   tt tt     t  tttttttt          t      ",
//					"   t    t     t  t  m t   t  t    t     b",
//					"  b       ttt tt  t  t    tt  t   t      ",
//					"            t   t  t      t t     t      ",
//					" t         ttt  tt tttttttt ttttt t      ",
//					"  t  1  t  tt             t       t      ",
//					"   t    t  t  tt tt  tttt   tt tt        ",
//					"    t   tttt   t t    t      ttttttt     ",
//					"     t         t        t t        t     ",
//					"      t    t tttt www t t t tttttt  t    ",
//					"         ttt   t        t   t       t t  ",
//					"           t   tttttttttt t t   ttttt t  ",
//					"  t     t  t           t    t         t  ",
//					"  t tttt   ttttttttt   tttttt     ttt t  ",
//					"     t        t    t        t  t         ",
//					"      t      wwwwwwww  www     ttt       ",
//					"       t                      t          ",
//					"        t    w t       t w   t           ",
//					"       tt    w           w  t            ",
//					"         tt  w     c                f    ",
//					"    t        w           w      m        ",
//					"      t      w t       t w               ",
//					"  t t                    w               ",
//					"             wwwwwwwwwwwww     t         ",
//					"    t t t         t t              r     ",
//					"  t       t   t       t      t           ",
//					"    t  m         t                       ",
//					"    t     t   f                 t        "
//			]
		map = [
			" 1   w",
			"t   m ",
			"      ",
			"tt   c"
		]
		return map
	}
	
	func scanMapForTileTypes(desiredType: TileType) -> [MapPoint] {

		var points = [MapPoint]()

		var yPosition = -Float(self.height / 2.0) + 0.5
		
		for textLine in self.asciiMap {
			var xPosition = -Float(self.width / 2.0) + 0.5
			for character in textLine.characters {
				if character.asTileType == desiredType {
					points.append(MapPoint(x: xPosition, z: yPosition))
				}
				xPosition += 1.0
			}
			yPosition += 1.0
		}
		return points
	}

	func determineSizeFromMap() -> (width: Double, height: Double) {
		let rows    = asciiMap.count
		let columns = asciiMap[0].characters.count
		return (Double(columns), Double(rows))
	}

	init(levelNumber: Int) {
		// Load the map
		asciiMap = loadMap()
		
		let size = determineSizeFromMap()
		
		width        = size.width
		height       = size.height

		// Build arrays of location coordinates for all the types of things the
		// map contains.
		walls        = scanMapForTileTypes(TileType.Wall)
		trees        = scanMapForTileTypes(TileType.Tree)

		visibleObstacles  = walls
		visibleObstacles += trees

		coffeeKiosks = scanMapForTileTypes(TileType.Coffee)
		fuelDepots   = scanMapForTileTypes(TileType.RocketFuel)
		medicalBags  = scanMapForTileTypes(TileType.MedicalBag)
		bandAids     = scanMapForTileTypes(TileType.BandAids)
		ships        = scanMapForTileTypes(TileType.Ship)

		players     = scanMapForTileTypes(TileType.Player01Start)
	}
}
