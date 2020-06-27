//
//  Suduko.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation

struct Coordinate : Equatable{
    var row : UInt8
    var column : UInt8
    var value : UInt8?
    
    var index : UInt8 {
        return row * 9 + column
    }
    init(idx : UInt8, size: UInt8) {
        self.row = idx % size
        self.column = idx / size
    }
    init(row : UInt8, column: UInt8) {
        self.row = row
        self.column = column
    }
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column && lhs.value == rhs.value
    }
}
struct RawSudukoData{
    
    var size : UInt8 = 9
    let data : [UInt8]
    
    func coordinate(forIndex: UInt8) -> Coordinate{
        
        return Coordinate(row: forIndex % size, column: forIndex / size)
    }
    

}


func groupFromIndex(index : UInt8)-> UInt8{
    
    let nChunkIndex = index / 3;
    let row = nChunkIndex / 9;
    let column = nChunkIndex % 3;
    return column + row * 3;
}

