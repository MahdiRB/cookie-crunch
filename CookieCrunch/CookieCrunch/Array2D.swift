//
//  Array2D.swift
//  CookieCrunch
//
//  Created by Katherine Fang on 10/27/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

struct Array2D<T>: Printable {
    let columns: Int
    let rows: Int
    private var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
    
    var description: String {
        return array.description
    }
}
