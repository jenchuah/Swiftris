//
//  Array2D.swift
//  Swiftris
//
//  Created by Jen Min Chuah on 31/01/2015.
//  Copyright (c) 2015 Lovely Birds. All rights reserved.
//

// Define class for array
// Note: Generic arrays in Swift are of type struct (passed by value, henced copied), not class (passed by reference)
//       Our game logic require a single copy of this data structure to persist across the entire game - so no copies
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    // Array of <T> typed parameter to store any data
    // ? means optional value. Used for empty spots
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        // Instantiate array
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    // Custom double value subscript for array[column, row]
    // Note: Default subscript for array in Swift is single-valued, ie. array[index]
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}