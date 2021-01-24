//
//  Utilities.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 12/23/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation

//MARK: Utility functions

extension SudokuPuzzle{
    
    static func groupFrom(index : Int ) -> Int{
        let nChunkIndex = index / 3;
        let row = nChunkIndex / 9;
        let column = nChunkIndex % 3;
        return column + row * 3;
    }
    static func columnFrom(index : Int ) -> Int{
        return index % 9
    }
    static func rowFrom(index : Int ) -> Int{
        return index / 9
    }
    static func indexOf( row: Int, column : Int) -> Int{
        return row * 9 + column
    }
    public static func membersOf(house : HouseType, houseNumber: Int)-> [Int]{
        var indices : [Int] = []
        switch house{
        case .row:
            let startIndex = houseNumber * 9
            indices = Array<Int>(startIndex..<(startIndex + 9))
            break
        case .column:
            let base = Array(0..<9)
            indices = base.map{houseNumber + ($0 * 9)}
            break
        case .group:
            //FIXME: Shitshow of magic numbers
            let baseIndices = [0,1,2,9,10,11,18,19,20]  //group 0, use as base
            let addBy = [0,3,6,27,30,33,54,57,60]
            indices = baseIndices.map{$0 + addBy[houseNumber]}
            break
        }
        return indices
    }
    static func housesFor(index : Int)-> [House]{
        let row = index / 9
        let col = index % 9
        let group = groupFrom(index: index)
        let rowHouse = House(type: .row, houseIndex: row)
        let colHouse = House(type: .column, houseIndex: col)
        let groupHouse = House(type: .group, houseIndex: group)
        return [rowHouse, colHouse, groupHouse]
    }
    
}

public enum HouseType : CaseIterable{
    case row,column,group
}
public struct House : Hashable, Equatable, CustomStringConvertible{
    public var description: String {
        switch self.type{
        
        case .row:
            return "row"
        case .column:
            return "column"
        case .group:
            return "group"
        }
    }
    
    public let type : HouseType
    public let houseIndex : Int
    public var memberIndices : [Int] {
        return SudokuPuzzle.membersOf(house: self.type, houseNumber: self.houseIndex)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.type == rhs.type && rhs.houseIndex == lhs.houseIndex && rhs.memberIndices == lhs.memberIndices
    }
    
}

internal extension Array {
    var combinations: [[Element]] {
        if count == 0 {
            return [self]
        }
        else {
            let tail = Array(self[1..<endIndex])
            let head = self[0]

            let first = tail.combinations
            let rest = first.map { $0 + [head] }

            return first + rest
        }
    }
}

internal struct CountedSet<T : Hashable>{
    
    var data : Dictionary< T,  Int> = [:]
    init(withArray : [T]){
        for item in withArray{
            if(data[item] != nil ){
                data[item] = data[item]! + 1
            }else{
                data[item] = 1
            }
        }
    }
    
    func count(of : T) -> Int{
        return data[of] ?? 0
    }
}
