//
//  Block.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 3/02/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//

import SpriteKit

let NumberOfColors: UInt32 = 6

// Enumeration of type Int and implements protocol Printable
enum BlockColor: Int, Printable {
    
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    // Filename for colors
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    // Computed property to adhere to Printable protocol. When you print BlockColor(0), you will get "blue"
    var description: String {
        return self.spriteName
    }
    
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

// Hashable allows Block to be stored in Array2D
class Block: Hashable, Printable {
    
    // Constants
    let color: BlockColor
    
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode? // Visual element of Block to be used by GameScene to render and animate block
    
    // Shortens file getter code from Block.color.spriteName to Block.spriteName
    var spriteName: String {
        return color.spriteName
    }
    
    // Use exclusive-or to generate unique hash value for each block
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // Printable to print Block. When you print Block, you will get Blue: [4, 3]
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column: Int, row: Int, color: BlockColor) {
        self.column = column
        self.row = row
        self.color  = color
    }
}

// Custom operator to be used in Hashable
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}