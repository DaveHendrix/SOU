//: # SOU Swift Workshop - February 11th, 2016

import Cocoa
import SceneKit

// Constants
let a = "Some String"
let b = 5
let c = 18.2

let d : Double = 5
let e = Double(5)

//let e = d * 2















// Variables
var f = "Another String"

// A string variable initialized with a literal
var str = "Hello"

// Appending strings
str = str + ", World!"

// Standard string functions
str = str.stringByReplacingOccurrencesOfString("!", withString: "...")
str += " I'm waiting for my coffee."

// Chaining
str = "Hello, World!"
str = str.stringByReplacingOccurrencesOfString("!", withString: "...") + " I'm waiting for my coffee."

// Constants

let theWorld = "The world is flat"

let anotherString = theWorld.stringByReplacingOccurrencesOfString("flat", withString: "round")

// theWorld = theWorld.stringByReplacingOccurrencesOfString("flat", withString: "round")




// Arrays

// A one dimensional array
let sampleArray = [1, 2, 3, 4, 5]

sampleArray

// A two dimensional array
let anotherArray = [[1,2,3],
					[4,5,6],
					[7,8,9]]

anotherArray

anotherArray[0]		// The first element of this array is another array

anotherArray[2][1]	// Which element does this access?







// For loops


for x in 0...100 {
	let y = x*x
}


// Note debugging/inspecting capabilities of playgrounds...



for x in 1..<5 {
	print ("The value of x is: \(x)")
}



// Iteration over an array

for subArray in anotherArray {
	print (subArray)
}









// Modern capabilities like "flatmap":

//// Using flatMap to flatten the two dimensional array
//let flatArray = anotherArray.flatMap() {
//	$0.map {
//		$0 * $0 // While flattening, square each number
//	}
//}
//
//flatArray










// Fun with constants and literals (and extensions)

// Directions, in degrees
let north     =   0.0
let northEast =  45.0
let east      =  90.0
let southEast = 135.0
let south     = 180.0
let southWest = 215.0
let west      = 270.0
let northWest = 315.0

// Create an array of directions
let directions = [north, northEast, east, southEast, south, southWest, west, northWest]

// Create an empty array
var cardinalDirections = [Double]()

// Create and fill an array with a single value
var arrayOfTens = [Double](count: 30, repeatedValue: 10.0)

for direction in directions where ((direction % 90.0) < 2.0) {
	cardinalDirections.append(direction)
}

cardinalDirections



// Dictionaries

let namedDirections = [ "North"     : north,
                        "NorthEast" : northEast,
                        "East"      : east,
                        "SouthEast" : southEast,
                        "South"     : south,
                        "SouthWest" : southWest,
                        "West"      : west,
                        "NorthWest" : northWest ];

// (more on dictionaries and optionals in a minute)









// Built in types are first-class citizens

// Using extensions to add functionality to classes, structs, and other data types


// Extend Swift's "Double" type to provide handy methods to
// convert degrees to radians and radians to degrees

extension Double {
	var asRadians: Double {
		return (self * M_PI) / 180.0
	}
	var asDegrees: Double {
		return (self / M_PI) * 180.0
	}
}

let rad = northWest.asRadians
let deg = rad.asDegrees


//let heading = namedDirections["NorthWest"].asRadians








// Extensions work with literals for the basic types, too.


//// Directions, in radians
//let north     =   0.0.asRadians
//let northEast =  45.0.asRadians
//let east      =  90.0.asRadians
//let southEast = 135.0.asRadians
//let south     = 180.0.asRadians
//let southWest = 215.0.asRadians
//let west      = 270.0.asRadians
//let northWest = 315.0.asRadians

extension Double {
	var isCardinalDirectionInDegrees: Bool {
		if (self % 90.0) < 0.5 {
			return true
		} else {
			return false
		}
	}
}

cardinalDirections.removeAll()

for direction in directions where direction.isCardinalDirectionInDegrees {
	cardinalDirections.append(direction)
}

cardinalDirections







// Objective-C bridging lets us use Cocoa classes...

let URL = NSURL(string: "https://www.rogueminds.net/simplemap.txt")!
do {
	let webMap = try NSString(contentsOfURL: URL, encoding: NSASCIIStringEncoding)
	let lines = webMap.componentsSeparatedByString("\u{0a}")
} catch {
	print ("Not fetched")
}



//: ## About The Sample Project
//:
//: The Swift project we'll be modifying attempts to implement the logic for a very simplistic game in which our robotic hero gathers resources necessary to go on a trip. Later refinements of the game introduce a multi-player version in which robots join (and/or switch) teams to share knowledge and complete the quest more quickly. (Though if they meet at the coffee kiosk, they might all hang out together for a while, and cross-team knowledge transfer might happen.)
//:
//: The SceneKit coordinate system:
//: ![](3d_coordinate_system_2x.png)
//: ## Entities and Components
//:
//: ### The World
//: * An underlying infinite plane along the x/z with y=0.0 (the world is flat, for our purposes)
//:     * (x: 0.0, y: 0.0, z: 0.0) is the center of the world
//: * Walls that enforce the playable area of the world (so the players can't wander away)
//:     * Defined as low boxes, 300 units out from the center
//: * A clock that fires causing periodic updates

struct World {
	let groundPlane = SCNNode()	// The "floor"

	let northWall = SCNNode()	//	Walls around the world
	let eastWall = SCNNode()
	let southWall = SCNNode()
	let westWall = SCNNode()
}


//: ### Our "RoboHero" player
//: Each robot has:
//: * An identifier
//: * An appearance (color, texture, etc.)
//: * A starting location
//: * A current heading and velocity
//: * A set of goals, some of which must be completed in a particular order.
//: * A state machine that controls behavior and current goal/goals
//: * A list of things it has discovered (obstacles, MacGuffins, other robots)
//:
//: In the networked version, robots will start as the member of a (random?) team. All team members will be told about all discoveries by any member, as they happen.

class RoboHero {
	let identifier = "Sparks"
	let appearance = NSColor.init(red: 1.0, green: 0.25, blue: 0.5, alpha: 1.0)
	let currentLocation = SCNVector3Make(-100.0, 0.0, -100.0)
	let heading = west.asRadians
}

RoboHero.init()

//:
//: ### Obstacles
//: * Simple, non-movable objects that include various kinds of "trees", "rocks", etc.
//:
//: ### The [MacGuffins](https://en.wikipedia.org/wiki/MacGuffin)
//: These are the items the RoboHero is searching for. The robot begins knowing nothing. The current list includes:
//: * Coffee Kiosk (just one)
//: * Rocket Fuel vending machine (several)
//: * Medical Supplies (several) -- might be a duffle bag containing supplies, or just a box of Band-Aids
//: * Rocket - TBD (one per player, one per team, or only one for everybody?)
//:
//: ### Rules
//: * The robot can only see a fixed distance while moving
//: * When stopped, the robot can scan farther tiles.
//: * The robot must find a way around obstacles.
//: * The robot should procede towards its next MacGuffin(s) (if known)
//: * If the location of the next MacGuffin(s) is/are unknown, the robot should explore
//: * MacGuffins are both goals *and* obstacles.
//:
//: #### Clarification of "both goals and obstacles" - with the Coffee Kiosk an example:
//: Robots don't actually enter the coffee kiosk, the goal is to just stand in an area in front of it.
//: When the robot gets close enough to one of the MacGuffins to "see" it, they then learn the "target location(s)" associated with the actual goal.
//:
//: ### Goals
//: * The robot must first acquire coffee before it can claim any other goal has been met.
//: 	* Reaching the coffee kiosk causes the robot to wait for a random period of time (range TBD)
//: 	* In the networked version, while at the coffee kiosk:
//: 		* If one or more other robots are there, it will increase the time spent by a random amount
//: 		* There is a chance during each turn that it will learn all the discoveries made by other nearby robots
//: 		* There is a chance during each turn that it will switch to the team of one of the other nearby robots
//:
//: ## Random Implementation Notes:
//: Need to determine how we will indicate the area that the robot has already explored, current visiblity limit, etc.
//: * Simple circle at ground plane attached to robot to indicate scanning distance?
//: * Mark robot's path with colored triangles at previous position

/*:

# Definitions:

[MacGuffin](https://en.wikipedia.org/wiki/MacGuffin) - https://en.wikipedia.org/wiki/MacGuffin


# Apple Documentation:


## Swift Language:

<FIXME:>

## Swift Open Source Project:

[Swift.org](https://swift.org)


## Frameworks:


### GameplayKit:

[The GameplayKit Programming Guide](https://developer.apple.com/library/mac/documentation/General/Conceptual/GameplayKit_Guide)

[The GameplayKit Framework Reference](https://developer.apple.com/library/mac/documentation/GameplayKit/Reference/GameplayKit_Framework)

[Directory of all GameplayKit Documentation](https://developer.apple.com/library/mac/navigation/#section=Frameworks&topic=GameplayKit)

### SceneKit:

[The SceneKit Programming Guide](https://developer.apple.com/library/mac/documentation/3DDrawing/Conceptual/SceneKit_PG/Introduction/)

[The SceneKit Framework Reference](https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SceneKit_Framework/)

[Directory of all SceneKit Documentation](https://developer.apple.com/library/mac/navigation/#section=Frameworks&topic=SceneKit)

*/
