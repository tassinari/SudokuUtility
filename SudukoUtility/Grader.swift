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
        case .xWing: return "X Wing"
        case .swordfish: return "Swordfish"
        case .lockedCandidate: return "Locked Candidate"
       
        }
      }
}
public typealias Possibles = [Int : [Int]]

public protocol HintResultProtocol {
    var type : HintType { get }
}


public struct PossibleHighlights : Equatable, Hashable{
    public let index : Int
    public let positiveHighlights : [Int]
    public let negativeHighlights : [Int]
    
    public static func == (lhs: PossibleHighlights, rhs: PossibleHighlights) -> Bool {
        return lhs.index == rhs.index && Set(lhs.positiveHighlights) == Set(rhs.positiveHighlights) && Set(lhs.negativeHighlights) == Set(rhs.negativeHighlights)
    }
    
    
}
public enum HighlightType  : Equatable, Hashable{
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
    public var wrappedIndex : Int? {
        switch self {
        case .house:
            return nil
        case .index(let i):
            return i
        }
    }
}
public struct HintAnswer : Equatable, Hashable{
    public let index : Int
    public let value : Int
}
public struct Hint : HintResultProtocol, Equatable, Hashable{
    public static func == (lhs: Hint, rhs: Hint) -> Bool {
        return lhs.answer == rhs.answer && rhs.type == lhs.type && rhs.highlights == lhs.highlights && rhs.possiblesHighlights == lhs.possiblesHighlights
    }
    
    public var type: HintType
    public let possiblesHighlights : [PossibleHighlights]
    public let highlights : [HighlightType]
    public let answer : HintAnswer?
    
    public var order : Int {
        switch type{
        
        case .nakedSingle,.lockedCandidate, .hiddenSingle, .xWing:
            return 1
        case .nakedSet, .hiddenSet:
            return  Set(self.possiblesHighlights.map{$0.positiveHighlights}.flatMap { $0 }).count
        case .swordfish:
            return 2  //?
        }
    }
    public var orderTypeString : String {
        switch self.order{
        case 1:
            return "Single"
        case 2:
            return "Double"
        case 3:
            return "Triple"
        case 4:
            return "Quad"
        default :
            return ""
        }
    }
    public var orderString : String {
        switch self.order{
        case 1:
            return "one"
        case 2:
            return "two"
        case 3:
            return "three"
        case 4:
            return "four"
        default :
            return ""
        }
    }
    public var enumeratedPositiveString : String {
        let p = Set(self.possiblesHighlights.map{$0.positiveHighlights}.flatMap{$0})
        return self.enumeratedValues(Array(p))
    }
    public var enumeratedNegativeString : String {
        let p = Set(self.possiblesHighlights.map{$0.negativeHighlights}.flatMap{$0})
        return self.enumeratedValues(Array(p))
    }
    private func enumeratedValues(_ arr : [Int]) -> String{
        var str = ""
        for (i,v) in arr.enumerated() {
            str += (i == 0) ? "\(v)" :  ",\(v)"
        }
        return str
    }
    
    
}

//MARK: Debug descriptions
extension Hint : CustomDebugStringConvertible{
    public var debugDescription: String {
        var answer = ""
        if let an = self.answer{
            answer = "Answer(index: \(an.index),value: \(an.value))"
        }else{
            answer = "nil"
        }
        var high = self.highlights.reduce("[") { (str, ht) -> String in
            if(str.count == 1){
                return str + ht.debugDescription
            }
            return str + ", " + ht.debugDescription
        }
        high += "]"
        var ts = ""
        switch self.type {
        case .nakedSingle:
            ts = ".nakedSingle"
        case .lockedCandidate:
            ts = ".lockedCandidate"
        case .hiddenSingle:
            ts = ".hiddenSingle"
        case .nakedSet:
            ts = ".nakedSet"
        case .hiddenSet:
            ts = ".hiddenSet"
        case .xWing:
            ts = ".xWing"
        case .swordfish:
            ts = ".swordfish"
        }
        return "Hint(type: \(ts), possiblesHighlights: \(self.possiblesHighlights.debugDescription), highlights: \(high), answer: \(answer))"
    }
    
    
}

extension HighlightType : CustomDebugStringConvertible{
    public var debugDescription: String {
        switch self{
        case .house(let h):
            return "HighlightType.house(\(House(type: h.type, houseIndex: h.houseIndex)))"
        case .index(let i):
            return "HighlightType.index(\(i))"
        }
    }
    
    
}
extension PossibleHighlights : CustomDebugStringConvertible{
    public var debugDescription: String {
        var pos = self.positiveHighlights.reduce("[") { (str, i) -> String in
            if self.positiveHighlights.first! == i{
                return str + String(i)
            }else{
                return str + ", " + String(i)
            }
            
        }
        var neg = self.negativeHighlights.reduce("[") { (str, i) -> String in
            if self.negativeHighlights.first! == i{
                return str + String(i)
            }else{
                return str + ", " + String(i)
            }
        }
        pos += "]"
        neg += "]"
        return "PossibleHighlights(index: \(self.index), positiveHighlights: \(pos), negativeHighlights : \(neg))"
    }
    
   
}


extension SudokuPuzzle{
    private static let allOptions  =  Set<Int>(Array(1...9))
   
    internal struct SolveData{
        let recurseCount : Int
        let currentPuzzle : SudokuPuzzle
        let possibleValuesMatrix : Possibles
        let solveLog : [Hint]
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
        if(nakedSingles.count > 0){
            for hint in nakedSingles{
                if let answer = hint.answer{
                    puzzle.data[answer.index] = answer.value
                }
                
            }
            var pastResult = solveData.solveLog
            pastResult.append(contentsOf: nakedSingles)
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle,possibleValuesMatrix: puzzle.possibleValueMatrix, solveLog: pastResult))
        }
        //Stage 2 If any hidden singles, add and recurse
        //FIXME: naked singles and hidden singles logic is almost exactly same, there is a generic opportunity here
        let hiddenSingles = solveData.currentPuzzle.hiddenSingles(possibles: solveData.possibleValuesMatrix)
        if(hiddenSingles.count > 0){
            for hint in hiddenSingles{
                if let answer = hint.answer{
                    puzzle.data[answer.index] = answer.value
                }
            }
            var pastResult = solveData.solveLog
            pastResult.append(contentsOf: hiddenSingles)
            //print("hidden singles - \(hiddenSingles.answers.count)")
            return try _rate(solveData: SolveData(recurseCount: solveData.recurseCount + 1, currentPuzzle: puzzle, possibleValuesMatrix: puzzle.possibleValueMatrix, solveLog: pastResult))
        }
        //Stage 3 & 4 & 5 Find any naked/Hidden pairs, triples or quads, xwings and update possible values, recurse
        let types : [HintType] = [.nakedSet,.hiddenSet,.lockedCandidate, .xWing]
        var modifiedPossibles = solveData.possibleValuesMatrix
        var cumulatedpassedResults : [Hint] = []
        var recurse = false
        for type in types{
            
            var sets : [Hint] = []
            switch type {
            case .hiddenSet:
                sets = solveData.currentPuzzle.hiddenSets(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForHints(possibles: modifiedPossibles, hints: sets)
            case .nakedSet:
                sets = solveData.currentPuzzle.nakedSets(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForHints(possibles: modifiedPossibles, hints: sets)
            case .lockedCandidate:
                sets = solveData.currentPuzzle.lockedCandidate(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForHints(possibles: modifiedPossibles, hints: sets)
            case .xWing:
                sets = solveData.currentPuzzle.xwing(possibles: solveData.possibleValuesMatrix)
                modifiedPossibles = self.modifyPossiblesForHints(possibles: modifiedPossibles, hints: sets)
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
                cumulatedpassedResults.append(contentsOf: sets)
                recurse = true
                
            }
            if(modifiedPossibles != solveData.possibleValuesMatrix){
                cumulatedpassedResults.append(contentsOf: sets)
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
    public func hint(possibles : Possibles) -> Hint?{
        
       
        //naked singles
        let nakedSingles = self.nakedSingles(possibles: possibles)
        if nakedSingles.count > 0 {
            return nakedSingles.first!
        }
        //hidden singles
        let hiddenSingles = self.hiddenSingles(possibles: possibles)
        if hiddenSingles.count > 0 {
            return hiddenSingles.first!
        }
        
       //Naked set
        let nakedsets = self.nakedSets(possibles: possibles)
        if nakedsets.count > 0{
            return nakedsets.first!
        }
        //hidden set
        let hiddednsets = self.hiddenSets(possibles: possibles)
        if hiddednsets.count > 0 {
            return hiddednsets.first!
        }
        
       //Locked candidate
        let locked   = self.lockedCandidate(possibles: possibles)
        if locked.count > 0{
            return locked.first!
        }
        //X wing
        let xwing = self.xwing(possibles:possibles)
        if xwing.count > 0{
            return xwing.first!
        }
        
        return nil
    }
    private func modifyPossiblesForHints(possibles : Possibles, hints : [Hint]) -> Possibles {
        var modifiedPossibles : Possibles = possibles
        for hint in hints{
            for hl in hint.possiblesHighlights{
                guard var possiblesAtIndex = possibles[hl.index] else {continue}
                possiblesAtIndex.removeAll(where: {hl.negativeHighlights.contains($0)})
                modifiedPossibles[hl.index] = possiblesAtIndex
            }
        }
        return modifiedPossibles
    }

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
            
            switch hint.type{
            
            case .hiddenSingle:
                score += 200
                break
            case .nakedSingle:
                score += 100
                break
                
            case .hiddenSet:
                score += 200 * (hint.possiblesHighlights.first?.positiveHighlights.count ?? 1)
                break
            case .nakedSet:
                score += 150 * (hint.possiblesHighlights.first?.positiveHighlights.count ?? 1)
                break
            case .lockedCandidate:
                score += 300
                break
            case .xWing:
                score += 800
                break
            case.swordfish:
                //FIXME: implement
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
   
    
    
    
    
    private func houseCheck( house : House, possibles: Possibles, type : HintType) -> Set<Hint>{
        
        var hintResults : Set<Hint> = Set()
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
                    let otherIndices = house.memberIndices.filter({!possibleNakeds.contains($0)})
                    let otherPMValues = Set(otherIndices.map { possibles[$0] ?? []}.flatMap{$0})
                    
                    if otherPMValues.intersection(combo).count > 0{
                        var possibleHighlights = possibleNakeds.map{ PossibleHighlights(index: $0, positiveHighlights: Array(combo), negativeHighlights: []) }
                        let possibleNegatives = otherIndices.filter { (index) -> Bool in
                            return Set(possibles[index] ?? []).intersection(combo).count > 0
                        }.map { (index) -> PossibleHighlights in
                            let negs = Set( possibles[index] ?? []).intersection(combo)
                            return PossibleHighlights(index: index, positiveHighlights: [], negativeHighlights: Array(negs))
                        }
                        possibleHighlights.append(contentsOf: possibleNegatives)
                        hintResults.insert(Hint(type: .nakedSet, possiblesHighlights: possibleHighlights, highlights: [HighlightType.house(house)], answer: nil))
                       
                    }
                    
                }
                
            case .hiddenSet:
                //hidden sets
                let possibleHiddens = house.memberIndices.filter{!combo.isDisjoint(with: Set(possibles[$0] ?? []))}
                if possibleHiddens.count == combo.count && possibleHiddens.count != freeSquareCount {
                    //Check if truly hidden, ie at least 1 extra value must be present in set
                    var trulyHidden = true
                    let allPossiblesValuesInCombosIndices = Set(possibleHiddens.map{possibles[$0] ?? []}.flatMap{$0})
                    trulyHidden = combo.isStrictSubset(of: allPossiblesValuesInCombosIndices )
                    if(trulyHidden){
                        let possibleHighlights = house.memberIndices.filter{ return Set( possibles[$0] ?? []).intersection(combo).count > 0 }.map { (index) -> PossibleHighlights in
                            var posHighs : [Int] = []
                            var negHighs : [Int] = []
                            if possibleHiddens.contains(index){
                                posHighs.append(contentsOf: combo)
                            }else{
                                negHighs.append(contentsOf: combo)
                            }
                            return PossibleHighlights(index: index, positiveHighlights: posHighs, negativeHighlights: negHighs)
                        }
                        hintResults.insert(Hint(type: .hiddenSet, possiblesHighlights: possibleHighlights, highlights: [HighlightType.house(house)], answer: nil))
                    }
                }
                   
            default:
                break
            }
            
        }
        return hintResults
    }
    
    //MARK: Naked Single
    func nakedSingles(possibles : Possibles) -> [Hint]{
        let singles = possibles.reduce(Array<Hint>()) { (hints, arg1) -> [Hint] in
            var mutableHints = hints
            let (key, arr) = arg1
            if arr.count == 1{
                mutableHints.append(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(key)], answer: HintAnswer(index: key, value: arr.first!)))
            }
            return mutableHints
        }
        return singles
    }
   
    //MARK: Hidden Single
    func hiddenSingles(possibles : Possibles) -> [Hint]{
        var hints : [Hint] = []
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
                    hints.append(Hint(type: .hiddenSingle, possiblesHighlights: [PossibleHighlights(index: i, positiveHighlights: [hidden.first!], negativeHighlights: [])], highlights: [HighlightType.house(house)], answer: HintAnswer(index: i, value: hidden.first!)))
                }
            }
        }
        return hints
    }
   
    
    //MARK: locked candidates
    func lockedCandidate(possibles : Possibles) -> [Hint]{
        //check single locked
        var locked : [Hint] = []
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
                            let negativeIndices = other.memberIndices.filter{ possibles[$0]?.contains(i) ?? false && !house.memberIndices.contains($0)}
                            var possibleHighlights : [PossibleHighlights] = indices.map{ PossibleHighlights(index: $0, positiveHighlights: [i], negativeHighlights: [])}
                            let negs : [PossibleHighlights] = negativeIndices.map{ PossibleHighlights(index: $0, positiveHighlights: [], negativeHighlights: [i])}
                            possibleHighlights.append(contentsOf: negs)
                            locked.append(Hint(type: .lockedCandidate, possiblesHighlights:possibleHighlights, highlights: [HighlightType.house(house),HighlightType.house(other)], answer: nil))
                        }
                        
                    }
                }
            }
        }
        return  locked
    }
    
    //MARK: Naked Pairs/triples/quads
    
    //If n squares have n number of the same values its a naked pair,  ie only 2 cells have 3/9 they are a naked pair.  3 & 9 can only be in those two squares
    func nakedSets(possibles : Possibles) -> [Hint]{
        //if a square has only n numbers, if another peer square has the same numbers, its a naked pair and can elimintate those number sfrom all other squares
        //FIXME: naked sets and hidden are called and filtered, do in one batch
        return Self.allHouses.map{self.houseCheck(house: $0, possibles: possibles, type: .nakedSet)}.flatMap{$0}.filter{$0.type == .nakedSet}
    }
   
    
    //MARK: Hidden Pairs/triples/quads
    func hiddenSets(possibles: Possibles) -> [Hint]{
        return Self.allHouses.map{self.houseCheck(house: $0, possibles: possibles, type: .hiddenSet)}.flatMap{$0}.filter{$0.type == .hiddenSet}

    }
    
    /*
     https://www.sudocue.net/guide.php#XWing
     “When all candidates for a certain digit within N rows lie within N columns, all candidates for this digit in these columns can be removed, except those that lie within the defining rows.”
     */
    
    //MARK: X wing
    
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

    internal func xwing(possibles : Possibles) -> [Hint]{
        let types : [xWingDirection] = [xWingDirection(direction: .row),xWingDirection(direction: .column)]
        var resultsHolder : [[Hint]] = []
        
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
            let myResult = candidates.reduce(Array<Hint>()) { (xwingResults, possible) -> [Hint] in
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
                            let hint = Hint(type: .xWing, possiblesHighlights: [], highlights: [], answer: nil)
                           // let hint = PossiblesHint(type: .xWing, indices: Set(colIndicesThatMatchCross), values: Set([possible.value]), house: colhouse)
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





