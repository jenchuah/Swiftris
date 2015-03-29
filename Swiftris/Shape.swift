//
//  Shape.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 5/02/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//
//  Shape class. Each shape is made out of multiple blocks. 
//  Properties: Shape has orientation, blockRowColumnPositions, bottomBlocksForOrientation, and bottomBlocks (returns bottomBlocksForOrientation for given orientation)
//  Actions: Shapes can be rotated, lowerByOneRow, shiftBy, and moveTo, random(generates random shape)


import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, Printable {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description:String {
        switch self {
        case .Zero:
            return "0"
            
        case .Ninety:
            return "90"
        
        case .OneEighty:
            return "180"
            
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    static func rotate(orientation:Orientation, clockwise:Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}

let NumShapeTypes:  UInt32 = 7

// Shape indexes
let FirstBlockIdx:  Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx:  Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, Printable {
    // The color of the shape
    let color:BlockColor
    
    // The blocks comprising the shape
    var blocks = Array<Block>()
    
    // The current orientation of the shape
    var orientation: Orientation
    
    // The column and row representing the shape's anchor point
    var column, row: Int
    
    // Required Overrides
    
    /* #1 Dictionary [...]
       Tuple Array <(...)>
       Example:
       let arrayOfDiffs = blockRowColumnPositions[Orientation.0]!
       let columnDifference = arrayOfDiffs[0].columnDiff
    */
    //Subclasses must override this property
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    // #2
    // Subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    // #3 Bottom blocks of a shape at its current orientation
    var bottomBlocks: Array<Block> {
        if let bottomBlocks = bottomBlocksForOrientations[orientation] {
            return bottomBlocks
        }
        return []
    }
    
    // Hashable
    var hashValue: Int {
        // reduce<S:Sequence, U>(sequence: S, initial: U, combine: (U, S.GeneratorType.Element) -> U) -> U
        // Iterate through entire blocks array
        // XOR each block's hashValue together to create a single hashValue for the Shape they comprise
        return reduce(blocks, 0) { $0.hashValue ^ $1.hashValue }
    }
    
    // Printable
    var description: String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        initializeBlocks()
    }
    
    convenience init(column: Int, row: Int) {
        self.init(column: column, row: row, color: BlockColor.random(), orientation: Orientation.random())
    }
    
    // final = cannot be overriden
    final func initializeBlocks() {
        // let blockRowColumnTranslations = blockRowColumnPositions[orientation]
        // if blockRowColumnTranslations != nil
        if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
            for i in 0..<blockRowColumnTranslations.count { //[(0,0), (0,1), (1,0), (1,1)]
                let blockRow = row + blockRowColumnTranslations[i].rowDiff
                let blockColumn = column + blockRowColumnTranslations[i].columnDiff
                let newBlock = Block(column: blockColumn, row: blockRow, color: color)
                blocks.append(newBlock)
            }
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        if let blockRowColumnTranslations:Array<(columnDiff:Int, rowDiff:Int)> = blockRowColumnPositions[orientation] {
            // Define variable idx and content at index. This saves us the added step of recovering it from the array, let tuple = blockRowColumnTranslation[idx]. We loop through the blocks and assign them their row and column based on the translations provided by the Tetromino subclass.
            for (idx, (columnDiff:Int, rowDiff:Int)) in enumerate(blockRowColumnTranslations) {
                blocks[idx].column = column + columnDiff
                blocks[idx].row = row + rowDiff
            }
        }
    }
    
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: true)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: false)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows: 0)
    }
    
    final func shiftBy(columns:Int, rows:Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    final func moveTo(column:Int, row:Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    final class func random(startingColumn:Int, startingRow:Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
        
        case 0:
            return SquareShape(column:startingColumn, row:startingRow)
        case 1:
            return LineShape(column:startingColumn, row:startingRow)
        case 2:
            return TShape(column:startingColumn, row:startingRow)
        case 3:
            return LShape(column:startingColumn, row:startingRow)
        case 4:
            return JShape(column:startingColumn, row:startingRow)
        case 5:
            return SShape(column:startingColumn, row:startingRow)
        default:
            return ZShape(column:startingColumn, row:startingRow)
        
        }
    }    
}

func == (lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}


