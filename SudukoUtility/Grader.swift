//
//  Grader.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 10/8/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation


//MARK: Grader

extension SudokuPuzzle{
    private static let allOptions  =  Set<Int>(Array(1...9))
    fileprivate enum SolveType{
        case nakedSingle,hiddenSingle,nakedPair,hiddenPair,xWing,swordfish
    }
    fileprivate struct SolveData{
        let recurseCount : Int
        let currentPuzzle : SudokuPuzzle
    }
    fileprivate func _rate(solveData : SolveData) -> SolveData{
        if(solveData.currentPuzzle.isSolved()){
            return solveData
        }
        var puzzle = solveData.currentPuzzle
        //Stage 1 If any naked singles, add and recurse
        let nakedSingles = solveData.currentPuzzle.nakedSingles()
        if(nakedSingles.count > 0){
            for key in nakedSingles.keys{
                guard let value = nakedSingles[key] else {continue}
                puzzle.data[key] = value
            }
            return _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle))
        }
        //Stage 2 If any hidden singles, add and recurse
        let hiddenSingles = solveData.currentPuzzle.hiddenSingles()
        if(hiddenSingles.count > 0){
            for key in hiddenSingles.keys{
                guard let value = hiddenSingles[key] else {continue}
                puzzle.data[key] = value
            }
            return _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle))
        }
        //Stage  Find any naked pairs, triples or quads and update possible values, recurse
        
        return solveData
    }
    public func rate() throws -> DificultyRating{
        
        //let solvedData = _rate(solveData: SolveData(recurseCount: 0, currentPuzzle: self))
        
        
        return .medium
    }
    private enum HouseType : CaseIterable{
        case row,column,group
    }
    private struct House{
        let type : HouseType
        let houseIndex : Int
        let memberIndices : [Int]
        
    }
    private static var allHouses : [House] = {
        var houses : [House] = []
        for houseType in HouseType.allCases{
            for i in 0..<9{
                var indices : [Int] = []
                switch houseType{
                case .row:
                    let startIndex = i * 9
                    indices = Array<Int>(startIndex..<(startIndex + 9))
                    break
                case .column:
                    let base = Array(0..<9)
                    indices = base.map{i + ($0 * 9)}
                    break
                case .group:
                    //FIXME: Shitshow of magic numbers
                    let baseIndices = [0,1,2,9,10,11,18,19,20]  //group 0, use as base
                    let addBy = [0,3,6,27,30,33,54,57,60]
                    indices = baseIndices.map{$0 + addBy[i]}
                    break
                }
                houses.append(House(type: houseType, houseIndex: i, memberIndices: indices))
            }
        }
        return houses
    }()
    
    private static var houseToIndexMap : Dictionary<Int,[House]> = {
        
        var data : Dictionary<Int, [House]> = [:]
        for i in 0..<81{
            data[i] = Self.allHouses.filter{$0.memberIndices.contains(i)}
        }
        return data
    }()
    
    public var possibleValueMatrix : [Int : [Int]] {
        var dict : [Int : [Int]] = [:]
        for (i,v) in self.data.enumerated(){
            if v > 0{
                continue
            }
            guard let allHouses = Self.houseToIndexMap[i] else {
                continue
            }
            let allPossiblesInAllHouses = allHouses.map { (house) -> [Int] in
                return house.memberIndices.map{self.data[$0]}
            }.flatMap{$0}
            dict[i] = Array(SudokuPuzzle.allOptions.subtracting(Set<Int>(allPossiblesInAllHouses)))
        }
        return dict
    }
    enum HintType {
        case hidden, naked
    }
    struct HintResult : Hashable, Equatable{
        let type : HintType
        let indices : Set<Int>
        let values : Set<Int>
        static func == (lhs: Self, rhs: Self) -> Bool{
            return lhs.type == rhs.type && rhs.indices == lhs.indices && rhs.values == lhs.values
        }
    }
    private func houseCheck(_ house : House) -> Set<HintResult>{
        if(house.houseIndex == 2 && house.type == .row){
            print()
        }
        var hintResults : Set<HintResult> = Set()
        let possibles = possibleValueMatrix
        let freeSquareCount = house.memberIndices.filter{self.data[$0] == 0}.count
        let allPossibleValues = Array(Set(house.memberIndices.map{possibles[$0] ?? []}.flatMap{$0}))
        let combos = allPossibleValues.combinations.filter({$0.count < 5 && $0.count > 1}).map({Set($0)})
        for combo in combos{
            
            //naked sets
            let possibleNakeds = house.memberIndices.filter { (index) -> Bool in
                guard let p = possibles[index] else {return false}
                return Set(p).isSubset(of: combo)
            }
            if possibleNakeds.count == combo.count && possibleNakeds.count != freeSquareCount {
                hintResults.insert(HintResult(type: .naked, indices: Set(possibleNakeds),values: combo))
            }
            
            //hidden sets
            let possibleHiddens = house.memberIndices.filter{!combo.isDisjoint(with: Set(possibles[$0] ?? []))}
            if possibleHiddens.count == combo.count && possibleNakeds.count != freeSquareCount {
                hintResults.insert(HintResult(type: .hidden, indices: Set(possibleHiddens),values: combo))
            }
        }
        return hintResults
    }
    
    //Naked Single
    func nakedSingles() -> [Int : Int]{
        return self.possibleValueMatrix.mapValues { (arr) -> Int in
            if arr.count == 1{
                return arr.first!
            }
            return 0
        }.filter{ (_,v) -> Bool in
            return v != 0
        }
    }
    //Hidden Single
    func hiddenSingles() -> [Int : Int]{
        var hiddens : [Int : Int] = [:]
        for i in possibleValueMatrix.keys{
            guard let values = possibleValueMatrix[i] else{
                continue
            }
            guard let houses = Self.houseToIndexMap[i] else { continue }
            for house in houses{
                let allpossiblesNotIncludingCurrent = house.memberIndices.map { (index) -> [Int] in
                    guard let values = possibleValueMatrix[index], index != i else { return [] }
                    return values
                }.flatMap{$0}
                let hidden = Set<Int>(values).subtracting(allpossiblesNotIncludingCurrent)
                if(hidden.count == 1){
                    hiddens[i] = hidden.first!
                }
            }
            
        }
        
        return hiddens
    }
    
    
    //Naked Pairs/triples/quads
    
    //If n squares have n number of the same values its a naked pair,  ie only 2 cells have 3/9 they are a naked pair.  3 & 9 can only be in those two squares
    
    func nakedSets() -> [HintResult]{
        //if a square has only n numbers, if another peer square has the same numbers, its a naked pair and can elimintate those number sfrom all other squares
        return Self.allHouses.map{self.houseCheck($0)}.flatMap{$0}.filter{$0.type == .naked}
    }
    
    //Hidden Pairs/triples/quads
    func hiddenSets() -> [HintResult]{
        return Self.allHouses.map{self.houseCheck($0)}.flatMap{$0}.filter{$0.type == .hidden}

    }
    
    
    // X wing
    // Swordfish
}

private extension Array {
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

