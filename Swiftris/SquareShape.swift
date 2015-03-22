//
//  SquareShape.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 24/02/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//

class SquareShape:Shape {
    /*

    | 0•| 1 |
    | 2 | 3 |
    
    • marks the row/column indicator for the shape
    
    */
    
    //Subclasses must simply provide the distance of each block from the shape's row and column location with respect to each possible orientation
    override var blockRowColumnPositions: [Orientation:Array<(columnDiff:Int, rowDiff:Int)>] {
        return [
            Orientation.Zero:       [(0,0), (0,1), (1,0), (1,1)],
            Orientation.Ninety:     [(0,0), (0,1), (1,0), (1,1)],
            Orientation.OneEighty:  [(0,0), (0,1), (1,0), (1,1)],
            Orientation.TwoSeventy: [(0,0), (0,1), (1,0), (1,1)]
        ]
    }
    
    // The square shape will not rotate
    override var bottomBlocksForOrientations: [Orientation:Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
    
}
