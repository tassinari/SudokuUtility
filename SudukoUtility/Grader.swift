//
//  Grader.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 10/8/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation


//MARK: Grader


enum HintType {
    case nakedSingle,hiddenSingle,nakedSet,hiddenSet,xWing,swordfish
}

protocol HintResultProtocol {
    var type : HintType { get }
}
enum HintResult {
    case answers(AnswerHint)
    case possibles(PossiblesHint)
}
struct PossiblesHint : HintResultProtocol, Hashable, Equatable{
    var type: HintType
    let indices : Set<Int>
    let values : Set<Int>
    static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.type == rhs.type && rhs.indices == lhs.indices && rhs.values == lhs.values
    }
}
struct AnswerHint : HintResultProtocol{
    var type: HintType
    let answers : [Int: Int]
 
}

extension SudokuPuzzle{
    private static let allOptions  =  Set<Int>(Array(1...9))
   
    fileprivate struct SolveData{
        let recurseCount : Int
        let currentPuzzle : SudokuPuzzle
        let possibleValuesMatrix : [Int : [Int]]
        let solveLog : [HintResult]
    }
    fileprivate func _rate(solveData : SolveData) throws -> SolveData{
        if(solveData.currentPuzzle.isSolved()){
            return solveData
        }
        if(solveData.recurseCount > 100){
            throw SudokuPuzzleError(type: .ratingError, debugInfo: "Too many recursions while rating")
        }
        var puzzle = solveData.currentPuzzle
        //Stage 1 If any naked singles, add and recurse
        let nakedSingles = solveData.currentPuzzle.nakedSingles(possibles: solveData.possibleValuesMatrix)
        if(nakedSingles.answers.count > 0){
            for key in nakedSingles.answers.keys{
                guard let value = nakedSingles.answers[key] else {continue}
                puzzle.data[key] = value
            }
            var pastResult = solveData.solveLog
            pastResult.append(HintResult.answers(nakedSingles))
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle,possibleValuesMatrix: solveData.possibleValuesMatrix, solveLog: pastResult))
        }
        //Stage 2 If any hidden singles, add and recurse
        let hiddenSingles = solveData.currentPuzzle.hiddenSingles(possibles: solveData.possibleValuesMatrix)
        if(hiddenSingles.answers.count > 0){
            for key in hiddenSingles.answers.keys{
                guard let value = hiddenSingles.answers[key] else {continue}
                puzzle.data[key] = value
            }
            var pastResult = solveData.solveLog
            pastResult.append(HintResult.answers(hiddenSingles))
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle, possibleValuesMatrix: solveData.possibleValuesMatrix, solveLog: pastResult))
        }
        //Stage 3 Find any naked pairs, triples or quads and update possible values, recurse
        
        let nakedSets = solveData.currentPuzzle.nakedSets(possibles: solveData.possibleValuesMatrix)
        if(nakedSets.count > 0){
            
        }
        
        
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
    private func possibleValues(from: [Int]) -> [Int : [Int]]{
        var dict : [Int : [Int]] = [:]
        for (i,v) in from.enumerated(){
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
    public var possibleValueMatrix : [Int : [Int]] {
        return self.possibleValues(from: self.data)
    }
   
    
    
    
    
    private func houseCheck(_ house : House, possibles: [Int : [Int]]) -> Set<PossiblesHint>{
        
        var hintResults : Set<PossiblesHint> = Set()
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
                hintResults.insert(PossiblesHint(type: .nakedSet, indices: Set(possibleNakeds),values: combo))
            }
            
            //hidden sets
            let possibleHiddens = house.memberIndices.filter{!combo.isDisjoint(with: Set(possibles[$0] ?? []))}
            if possibleHiddens.count == combo.count && possibleNakeds.count != freeSquareCount {
                hintResults.insert(PossiblesHint(type: .hiddenSet, indices: Set(possibleHiddens),values: combo))
            }
        }
        return hintResults
    }
    
    //Naked Single
    func nakedSingles(possibles : [Int : [Int]]) -> AnswerHint{
        let data = possibles.mapValues { (arr) -> Int in
            if arr.count == 1{
                return arr.first!
            }
            return 0
        }.filter{ (_,v) -> Bool in
            return v != 0
        }
        return AnswerHint(type: .nakedSingle, answers: data)
    }
    @available(*, deprecated, message: "Deprecated, use nakedSingles(possibles: : [Int : [Int]])")
    func nakedSingles() -> AnswerHint{
        return self.nakedSingles(possibles: self.possibleValueMatrix)
    }
    //Hidden Single
    func hiddenSingles(possibles : [Int : [Int]]) -> AnswerHint{
        var hiddens : [Int : Int] = [:]
        for i in possibles.keys{
            guard let values = possibles[i] else{
                continue
            }
            guard let houses = Self.houseToIndexMap[i] else { continue }
            for house in houses{
                let allpossiblesNotIncludingCurrent = house.memberIndices.map { (index) -> [Int] in
                    guard let values = possibles[index], index != i else { return [] }
                    return values
                }.flatMap{$0}
                let hidden = Set<Int>(values).subtracting(allpossiblesNotIncludingCurrent)
                if(hidden.count == 1){
                    hiddens[i] = hidden.first!
                }
            }
            
        }
        
        return AnswerHint(type: .hiddenSingle, answers: hiddens)
    }
    @available(*, deprecated, message: "Deprecated, use hiddenSingles(possibles: : [Int : [Int]])")
    func hiddenSingles() -> AnswerHint{
        self.hiddenSingles(possibles: self.possibleValueMatrix)
    }
    
    
    //Naked Pairs/triples/quads
    
    //If n squares have n number of the same values its a naked pair,  ie only 2 cells have 3/9 they are a naked pair.  3 & 9 can only be in those two squares
    func nakedSets(possibles : [Int : [Int]]) -> [PossiblesHint]{
        //if a square has only n numbers, if another peer square has the same numbers, its a naked pair and can elimintate those number sfrom all other squares
        return Self.allHouses.map{self.houseCheck($0, possibles: possibles)}.flatMap{$0}.filter{$0.type == .nakedSet}
    }
    @available(*, deprecated, message: "Deprecated, use nakedSets(possibles: : [Int : [Int]])")
    func nakedSets() -> [PossiblesHint]{
        return self.nakedSets(possibles: self.possibleValueMatrix)
    }
    
    //Hidden Pairs/triples/quads
    func hiddenSets(possibles: [Int : [Int]]) -> [PossiblesHint]{
        return Self.allHouses.map{self.houseCheck($0, possibles: possibles)}.flatMap{$0}.filter{$0.type == .hiddenSet}

    }
    @available(*, deprecated, message: "Deprecated, use hiddenSets(possibles: : [Int : [Int]])")
    func hiddenSets() -> [PossiblesHint]{
        self.hiddenSets(possibles: self.possibleValueMatrix)

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

