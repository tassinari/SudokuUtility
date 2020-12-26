//
//  Grader.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 10/8/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation


//MARK: Grader


public enum HintType : CustomStringConvertible{
    case nakedSingle,lockedCandidate,hiddenSingle,nakedSet,hiddenSet,xWing,swordfish
    
    public var description : String {
        switch self {
        
        case .nakedSingle: return "Naked single"
        case .hiddenSingle: return "Hidden single"
        case .nakedSet: return "Naked set"
        case .hiddenSet: return "Hidden set"
        case .xWing: return "x wing"
        case .swordfish: return "swordfish"
        case .lockedCandidate: return "Locked Candidate"
       
        }
      }
}
public typealias Possibles = [Int : [Int]]

public protocol HintResultProtocol {
    var type : HintType { get }
}
public enum HintResult {
    case answers(AnswerHint)
    case possibles(PossiblesHint)
}
public struct PossiblesHint : HintResultProtocol, Hashable, Equatable{
    public var type: HintType
    let indices : Set<Int>
    let values : Set<Int>
    let house : House
    public static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.type == rhs.type && rhs.indices == lhs.indices && rhs.values == lhs.values && rhs.house == lhs.house
    }
}
public enum AnswerDataType {
    case house (House)
    case index (Int)
    
    public var wrappedHouse : House? {
        switch self {
        case .house(let h):
            return h
        case .index:
            return nil
        }
    }
}
public struct AnswerData{
    public let value : Int
    public let dataType : AnswerDataType
}
public struct AnswerHint : HintResultProtocol{
    
    public var type: HintType
    public let answers : [Int: AnswerData]
 
}


extension SudokuPuzzle{
    private static let allOptions  =  Set<Int>(Array(1...9))
   
    internal struct SolveData{
        let recurseCount : Int
        let currentPuzzle : SudokuPuzzle
        let possibleValuesMatrix : Possibles
        let solveLog : [HintResult]
    }
    internal func _rate(solveData : SolveData) throws -> SolveData{
        if(solveData.currentPuzzle.isSolved()){
            return solveData
        }
        if(solveData.recurseCount > 300){
            throw SudokuPuzzleError(type: .ratingError, debugInfo: "Too many recursions while rating")
        }
        var puzzle = solveData.currentPuzzle
        //Stage 1 If any naked singles, add and recurse
        let nakedSingles = solveData.currentPuzzle.nakedSingles(possibles: solveData.possibleValuesMatrix)
        if(nakedSingles.answers.count > 0){
            for key in nakedSingles.answers.keys{
                guard let answerData = nakedSingles.answers[key] else {continue}
                puzzle.data[key] = answerData.value
            }
            var pastResult = solveData.solveLog
            pastResult.append(HintResult.answers(nakedSingles))
            //print("naked singles - \(nakedSingles.answers.count)")
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle,possibleValuesMatrix: puzzle.possibleValueMatrix, solveLog: pastResult))
        }
        //Stage 2 If any hidden singles, add and recurse
        let hiddenSingles = solveData.currentPuzzle.hiddenSingles(possibles: solveData.possibleValuesMatrix)
        if(hiddenSingles.answers.count > 0){
            for key in hiddenSingles.answers.keys{
                guard let answerData = hiddenSingles.answers[key] else {continue}
                puzzle.data[key] = answerData.value
            }
            var pastResult = solveData.solveLog
            pastResult.append(HintResult.answers(hiddenSingles))
            //print("hidden singles - \(hiddenSingles.answers.count)")
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle, possibleValuesMatrix: puzzle.possibleValueMatrix, solveLog: pastResult))
        }
        //Stage 3 & 4 & 5 Find any naked/Hidden pairs, triples or quads, xwings and update possible values, recurse
        let types : [HintType] = [.nakedSet,.hiddenSet,.lockedCandidate, .xWing]
        var modifiedPossibles = solveData.possibleValuesMatrix
        var cumulatedpassedResults : [HintResult] = []
        var recurse = false
        for type in types{
            
            var sets : [PossiblesHint] = []
            switch type {
            case .hiddenSet:
                sets = solveData.currentPuzzle.hiddenSets(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForHidden(possibles: modifiedPossibles, hints: sets)
            case .nakedSet:
                sets = solveData.currentPuzzle.nakedSets(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForNaked(possibles: modifiedPossibles, hints: sets)
            case .lockedCandidate:
                sets = solveData.currentPuzzle.lockedCandidate(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForNaked(possibles: modifiedPossibles, hints: sets)
            case .xWing:
                sets = solveData.currentPuzzle.xwing(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForNaked(possibles: modifiedPossibles, hints: sets)
            default:
                break
            }
            
            //Check modified possibles for cells with 1 value and recurse
            let singles = modifiedPossibles.filter({$0.value.count == 1})
            if(singles.count > 0){
                for key in singles.keys{
                    let value = singles[key]!.first!
                    puzzle.data[key] = value
                    modifiedPossibles.removeValue(forKey: key)
                    
                    //remove the value from all houses!
                    if let houses = Self.houseToIndexMap[key]{
                        for house in houses{
                            for index in house.memberIndices{
                                if(modifiedPossibles[index]?.contains(value) ?? false){
                                    var values = modifiedPossibles[index] ?? []
                                    values.removeAll { (i) -> Bool in
                                        return i  == value
                                    }
                                    modifiedPossibles[index] = values
                                }
                            }
                        }
                    }
                    
                    
                }
                // There is a change in possibles so now recurse
                cumulatedpassedResults.append(contentsOf: sets.map{HintResult.possibles($0)})
                recurse = true
                
            }
            if(modifiedPossibles != solveData.possibleValuesMatrix){
                cumulatedpassedResults.append(contentsOf: sets.map{HintResult.possibles($0)})
                recurse = true
            }
        }
        if(recurse){
            let count = solveData.recurseCount + cumulatedpassedResults.count
            let pastResult = solveData.solveLog + cumulatedpassedResults
            return try _rate(solveData: SolveData(recurseCount: count , currentPuzzle: puzzle, possibleValuesMatrix: modifiedPossibles, solveLog: pastResult))
        }
        
        
        return solveData
    }
    
    //FIXME: Combine with the _rate function to extract out the hint result
    public func hint() -> HintResult{
        //naked singles
        let nakedSingles = self.nakedSingles(possibles: self.possibleValueMatrix)
        if nakedSingles.answers.count > 0 {
            return HintResult.answers(nakedSingles)
        }
        //hidden singles
        let hiddenSingles = self.hiddenSingles(possibles: self.possibleValueMatrix)
        if hiddenSingles.answers.count > 0 {
            return HintResult.answers(hiddenSingles)
        }
        //hidden set
        let hiddednsets = self.hiddenSets(possibles: possibleValueMatrix)
        if hiddednsets.count > 0 {
            return HintResult.possibles(hiddednsets.first!)
        }
           
       //Naked set
        let nakedsets = self.nakedSets(possibles: possibleValueMatrix)
        if nakedsets.count > 0{
            return HintResult.possibles(nakedsets.first!)
        }
       //Locked candidate
        let locked   = self.lockedCandidate(possibles: possibleValueMatrix)
        if locked.count > 0{
            return HintResult.possibles(locked.first!)
        }
        //X wing
        let xwing = self.xwing(possibles: possibleValueMatrix)
        if xwing.count > 0{
            return HintResult.possibles(xwing.first!)
        }
        
        return HintResult.answers(nakedSingles)
    }
    private func modifyPossiblesForHidden(possibles : Possibles, hints : [PossiblesHint]) -> Possibles {
        var modifiedPossibles : Possibles = possibles
        for set in hints{
            
            //clear out all non values from the indices cells
            for index in set.indices{
                guard var possiblesAtIndex = possibles[index] else {continue}
                possiblesAtIndex.removeAll(where: {!set.values.contains($0)})
                modifiedPossibles[index] = possiblesAtIndex
            }
            //clear out values from non indices cells
            for index in Set(set.house.memberIndices).subtracting(set.indices){
                guard var possiblesAtIndex = possibles[index] else {continue}
                possiblesAtIndex.removeAll(where: {set.values.contains($0)})
                modifiedPossibles[index] = possiblesAtIndex
            }
        }
        return modifiedPossibles
    }
    private func modifyPossiblesForNaked(possibles : Possibles, hints : [PossiblesHint]) -> Possibles{
        var modifiedPossibles : Possibles = possibles
        for set in hints{
            for index in Set(set.house.memberIndices).subtracting(set.indices){
                guard var possiblesAtIndex = possibles[index] else {continue}
                possiblesAtIndex.removeAll(where: {set.values.contains($0)})
                modifiedPossibles[index] = possiblesAtIndex
            }
        }
        return modifiedPossibles
    }
    
//    internal func rate() throws -> SolveData{
//        
//        let solvedData = try _rate(solveData: SolveData(recurseCount: 0, currentPuzzle: self, possibleValuesMatrix: self.possibleValueMatrix, solveLog: []))
//        
//       // print(solvedData.currentPuzzle.description)
//        return solvedData
//    }
    public func rate() throws -> DificultyRating{
        return try internalRate().3
    }
    internal func internalRate() throws -> (Int,Int,SolveData,DificultyRating){
        
        let solvedData = try _rate(solveData: SolveData(recurseCount: 0, currentPuzzle: self, possibleValuesMatrix: self.possibleValueMatrix, solveLog: []))
        
        let solved = try self.solvedCopy()
      
        
        /*
         Naked single 100
         HiddenSingle 200
         Naked Pair 200
         Hidden Pair 300
         Naked Triple 400
         Hidden Triple 400
         Naked Quad 500
         Hidden Quad 600
         Locked Candidate 300
         X Wing 800
         
         */
        var score = 0
        for hint in solvedData.solveLog{
            
            switch hint{
            case .answers(let answers):
                switch answers.type{
                case .hiddenSingle:
                    score += 200
                    break
                case .nakedSingle:
                    score += 100
                    break
                default:
                    break
                }
                break
            case .possibles(let possibles):
                switch possibles.type {
                case .hiddenSet:
                    score += 200 * (possibles.indices.count)
                    break
                case .nakedSet:
                    score += 150 * (possibles.indices.count)
                    break
                case .lockedCandidate:
                    score += 300
                    break
                case .xWing:
                    score += 800
                    break
                default:
                    break
                }
                break
            }
        }
        var rating : DificultyRating = .hard
        if(solvedData.currentPuzzle.data != solved.data){
            score += 10000
        }
        switch score{
        case 0..<2200:
            rating = .easy
            break
        case 2200..<2901:
            rating = .medium
            break
        case 2901..<10000:
            rating = .hard
            break
        case 10001..<21900:
            rating = .extraHard
            break
        default:
            rating = .extraHard
            break
            //return.extraHard
        }
        return (solvedData.solveLog.count, score,solvedData,rating)
    }
    
    private static var allHouses : [House] = {
        var houses : [House] = []
        for houseType in HouseType.allCases{
            for i in 0..<9{
                houses.append(House(type: houseType, houseIndex: i))
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
    
    private func possibleValues(from: [Int]) -> Possibles{
        var dict : Possibles = [:]
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

    public var possibleValueMatrix : Possibles {
        return self.possibleValues(from: self.data)
    }
   
    
    
    
    
    private func houseCheck( house : House, possibles: Possibles, type : HintType) -> Set<PossiblesHint>{
        
        var hintResults : Set<PossiblesHint> = Set()
        let freeSquareCount = house.memberIndices.filter{self.data[$0] == 0}.count
        let allPossibleValues = Array(Set(house.memberIndices.map{possibles[$0] ?? []}.flatMap{$0}))
        let combos = allPossibleValues.combinations.filter({$0.count < 5 && $0.count > 1}).map({Set($0)})
        for combo in combos{
            switch type{
            case .nakedSet:
                //naked sets
                let possibleNakeds = house.memberIndices.filter { (index) -> Bool in
                    guard let p = possibles[index] else {return false}
                    return Set(p).isSubset(of: combo)
                }
                if possibleNakeds.count == combo.count && possibleNakeds.count != freeSquareCount {
                    hintResults.insert(PossiblesHint(type: .nakedSet, indices: Set(possibleNakeds),values: combo, house: house))
                }
                
            case .hiddenSet:
                //hidden sets
                let possibleHiddens = house.memberIndices.filter{!combo.isDisjoint(with: Set(possibles[$0] ?? []))}
                if possibleHiddens.count == combo.count && possibleHiddens.count != freeSquareCount {
                    hintResults.insert(PossiblesHint(type: .hiddenSet, indices: Set(possibleHiddens),values: combo, house: house))
                }
            default:
                break
            }
            
        }
        return hintResults
    }
    
    //Naked Single
    func nakedSingles(possibles : Possibles) -> AnswerHint{
        let mappedTupples = possibles.map { (key,arr) -> (Int, AnswerData) in
            if arr.count == 1{
                return (key,AnswerData(value: arr.first!, dataType: AnswerDataType.index(key)))
            }
            return (key,AnswerData(value: 0, dataType: AnswerDataType.index(key)))
        }.filter{ data -> Bool in
            return data.1.value != 0
        }
        
        return AnswerHint(type: .nakedSingle, answers: Dictionary(uniqueKeysWithValues: mappedTupples))
    }
   
    //Hidden Single
    func hiddenSingles(possibles : Possibles) -> AnswerHint{
        var hiddens : [Int : AnswerData] = [:]
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
                    hiddens[i] = AnswerData(value: hidden.first!, dataType: AnswerDataType.house(house))
                }
            }
            
        }
        
        return AnswerHint(type: .hiddenSingle, answers: hiddens)
    }
   
    
    //locked candidates
    func lockedCandidate(possibles : Possibles) -> [PossiblesHint]{
        //check single locked
        var locked : [PossiblesHint] = []
        for house in Self.allHouses{
            let countedSet = CountedSet(withArray: house.memberIndices.map{possibles[$0] ?? []}.flatMap{$0})
            for i in 1...9{
                if(countedSet.count(of: i) == 2){
                    let indices : [Int] = house.memberIndices.filter { (index) -> Bool in
                        return possibles[index]?.contains(i) ?? false
                    }
                    let otherHouses = Self.allHouses.filter { (candidateHouse) -> Bool in
                        if candidateHouse == house { return false }
                        return Set(indices).isSubset(of: candidateHouse.memberIndices)
                    }
                    for other in otherHouses{
                        let otherPossibles = Set(other.memberIndices).subtracting(indices).map{possibles[$0] ?? []}.flatMap{$0}
                        if(Set(otherPossibles).contains(i)){
                            locked.append(PossiblesHint(type: .lockedCandidate, indices: Set(indices), values: Set(arrayLiteral: i), house: other))
                        }
                        
                    }
                }
            }
        }
        return  locked
    }
    
    //Naked Pairs/triples/quads
    
    //If n squares have n number of the same values its a naked pair,  ie only 2 cells have 3/9 they are a naked pair.  3 & 9 can only be in those two squares
    func nakedSets(possibles : Possibles) -> [PossiblesHint]{
        //if a square has only n numbers, if another peer square has the same numbers, its a naked pair and can elimintate those number sfrom all other squares
        //FIXME: naked sets and hidden are called and filtered, do in one batch
        return Self.allHouses.map{self.houseCheck(house: $0, possibles: possibles, type: .nakedSet)}.flatMap{$0}.filter{$0.type == .nakedSet}
    }
   
    
    //Hidden Pairs/triples/quads
    func hiddenSets(possibles: Possibles) -> [PossiblesHint]{
        return Self.allHouses.map{self.houseCheck(house: $0, possibles: possibles, type: .hiddenSet)}.flatMap{$0}.filter{$0.type == .hiddenSet}

    }
    
    /*
     https://www.sudocue.net/guide.php#XWing
     “When all candidates for a certain digit within N rows lie within N columns, all candidates for this digit in these columns can be removed, except those that lie within the defining rows.”
     */
    
    // X wing
    
    fileprivate struct XWingPossible{
        let house : House
        let value : Int
        let indices : [Int]
    
    }
    fileprivate struct xWingDirection{
        let direction : HouseType
        var opposite : HouseType{
            switch direction {
            case .row:
                return .column
            case .column:
                return .row
            default:
                return .row
            }
        }
        func crossItem(_ i : Int)-> Int{
            switch direction {
            case .row:
                return i % 9
            case .column:
                return i / 9
            default:
                return 0
            }
        }
    }

    internal func xwing(possibles : Possibles) -> [PossiblesHint]{
        let types : [xWingDirection] = [xWingDirection(direction: .row),xWingDirection(direction: .column)]
        var resultsHolder : [[PossiblesHint]] = []
        
        for xtype in types{
            let rows = Self.allHouses.filter({$0.type == xtype.direction})
            var candidates : [XWingPossible] = []
            for house in rows{
                let allKeysOfRow = possibles.keys.filter{house.memberIndices.contains($0)}
                let allValuesOfRow = allKeysOfRow.map{possibles[$0] ?? []}.flatMap{$0}
                let countedSet = CountedSet(withArray: allValuesOfRow)
                for i in 1...9{
                    if(countedSet.count(of: i) == 2){
                        let indices : [Int] = house.memberIndices.filter { (index) -> Bool in
                            return possibles[index]?.contains(i) ?? false
                        }
                        candidates.append(XWingPossible(house: house, value: i, indices: indices))
                    }
                }
            }
            //if candidates.count > 1, check that the columns align
            if(candidates.count < 2){
                //nothing found
                return []
            }
            let myResult = candidates.reduce(Array<PossiblesHint>()) { (xwingResults, possible) -> [PossiblesHint] in
                guard possible.indices.count == 2 else  { return xwingResults}
                var mutableresults = xwingResults
                let match = candidates.filter { (candidate) -> Bool in
                    if candidate.house == possible.house { return false} //dont include itsself as a match
                    return candidate.value == possible.value &&  candidate.indices.map{xtype.crossItem($0)} == possible.indices.map{xtype.crossItem($0)}
                }
                if match.count > 0{
                    //either match or possible, grab the columns and make a Possible hint from that house
                    //indices have to be the column indices that cross the rows
                    let allCrossIndices = possible.indices + match.first!.indices
                    for index in possible.indices{
                        //get column house
                        if let colhouse = Self.houseToIndexMap[index]?.filter({$0.type == xtype.opposite}).first {
                            let colIndicesThatMatchCross = allCrossIndices.filter{colhouse.memberIndices.contains($0)}
                            let hint = PossiblesHint(type: .xWing, indices: Set(colIndicesThatMatchCross), values: Set([possible.value]), house: colhouse)
                            if(!mutableresults.contains(hint)){
                                mutableresults.append(hint)
                            }
                        }
                    }
                }
                return mutableresults
            }
            resultsHolder.append(myResult)
        }
        return resultsHolder.flatMap{$0}
    }
    
    // Swordfish
}





