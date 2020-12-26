//
//  Sudoku.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 7/19/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation
public enum DificultyRating : Int16{
    case notRated = 0, easy = 1,medium = 2, hard = 3 , extraHard = 4
    
    public var userLocalizedStringValue : String{
        switch self {
        case .notRated:
            return "Not Rated"
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        case .extraHard:
            return "Extra Hard"
        
        }
    }
}

struct SudokuPuzzleError : Error  {
    
    enum SudokuPuzzleErrorType{
        case noSolutions, multipleSolutions, unsolvable, ratingError
    }
    var localizedDescription : String {
        return debugInfo
    }
    
    let type : SudokuPuzzleErrorType
    let debugInfo :String
}
//MARK: SudokuPuzzle
///
/// The main data strucure used to represent, solve, check, and rate a suduko puzzle.

   /// - Note: The puzzle is stored as an [Int] with size being the number of rows and columns.  The data is 1 based, 0 indicates a blank space, 1-9 indicate the filled values.
   

public struct SudokuPuzzle{
    public var data : [Int]
    var size : Int
    private var _givens : [Int]?
    public var givens : [Int] {
       return _givens ?? []
    }
    private var _data : [Int] {
        return data.map{$0 - 1}
    }
    internal init(data : [Int]){
        self.data = data
        self.size = 9
        _givens = self.determineGivens()
    }
    private init(){
        
        self.data = []
        self.size = 9
        
    }
    public func originalPuzzle() -> SudokuPuzzle{
        var  newData : [Int] = Array(repeating: 0, count: 81)
        for (i,v) in self.data.enumerated(){
            newData[i] = self.givens.contains(i) ? v : 0
        }
        return SudokuPuzzle(data: newData)
    }
}

//MARK: Solving utilties
extension SudokuPuzzle{
    
    public func solvedCopy() throws -> SudokuPuzzle{
        
        let solvedColumns = filledColumns()
        if(solvedColumns.count  > 0){
            SudokuPuzzle.solver.setPartialSolution(columns: solvedColumns)
        }
        
        do {
            try SudokuPuzzle.solver.solve(random: false) { (answers) -> Bool in
                   return true
            }
            if(solvedColumns.count  > 0){
                SudokuPuzzle.solver.clearPartialSolution(columns: solvedColumns)
            }
            
            guard let solution = SudokuPuzzle.solver.solutionSet.first else {
                throw SudokuPuzzleError(type: .noSolutions, debugInfo: "No solutions found")
            }
            var filledRows : [Int] = []
            for (i,v) in self._data.enumerated(){
                if(v > -1){
                    filledRows.append(matrixRowfromSuduko(row: i / size, col: i % size, value: v, size: size ))
                }
            }
            var rows = solution.map{$0.coordinate.row}
            rows.append(contentsOf: filledRows)
            return SudokuPuzzle.sudukoPuzzleFromRows(rows)
        } catch let e {
            throw e
        }
    }
    internal func _uniquelySolvable() throws -> (Bool,[[Int]]){
        //need to check if partial and set
        let solvedColumns = filledColumns()
        if(solvedColumns.count  > 0){
            SudokuPuzzle.solver.setPartialSolution(columns: filledColumns())
        }
        var myAnswers : [[Int]] = []
        do {
            try SudokuPuzzle.solver.solve(random: true) { (answers) -> Bool in
                myAnswers.append(answers.last!)
                return answers.count > 1
            }
            if(solvedColumns.count  > 0){
                SudokuPuzzle.solver.clearPartialSolution(columns: filledColumns())
            }
            return (SudokuPuzzle.solver.solutionSet.count == 1, myAnswers)
            
        } catch let e {
            throw e
        }
    }
    public func uniquelySolvable() throws -> Bool{
        
        return try _uniquelySolvable().0
    }
    public func errors() -> [(Int,Int)]{
        
        return []
    }
   
    public func disallowedValuesForCurrentState(atIndex: Int)-> [Int]{
        var r : [Int] = []
        let atindexRow = atIndex / size
        let atindexCol = atIndex % size
        let atindexGroup = SudokuPuzzle.groupFrom(index: atIndex)
        for i in 0..<self.data.count{
            let row = i / size
            let col = i % size
            let group = SudokuPuzzle.groupFrom(index: i)
            let check = self.data[i] != 0 && (atindexRow == row || atindexCol == col || atindexGroup == group)
            if(check){
                r.append(self.data[i])
            }
            
            
        }
        return r
    }
    public func isSolved() -> Bool{
        
        //check every item is a number
        if self.data.contains(0){
            return false
        }
        
        //check 4 constraints
        var rowArray : [[Int]] = [[Int]](repeating: [], count: size)
        var colArray : [[Int]] = [[Int]](repeating: [], count: size)
        var groupArray : [[Int]] = [[Int]](repeating: [], count: size)
        for i in 0..<self.data.count{
            let row = i / size
            let col = i % size
            let group = SudokuPuzzle.groupFrom(index: i)
            rowArray[row].append(self.data[i])
            colArray[col].append(self.data[i])
            groupArray[group].append(self.data[i])
            
            
        }
        let allRowsGood = !rowArray.map { $0.reduce(0,+) == 45 }.contains(false)  //sum each row and check for a false
        let allColsGood = !colArray.map { $0.reduce(0,+) == 45 }.contains(false)  //sum each col and check for a false
        let allGroupsGood = !groupArray.map { $0.reduce(0,+) == 45 }.contains(false)  //sum each group and check for a false
        
        return allRowsGood && allColsGood && allGroupsGood
    }
    internal func filledColumns() -> [Int]{
        var cols : [Int] = []
        for (i, v) in self._data.enumerated(){
            if( v != -1){
                let c = matrixColumnsfromIndex(i)
                cols.append(contentsOf: c)
            }
        }
        return cols
    }
    private func matrixColumnsfromIndex(_ index : Int) -> [Int]{
        var colNums : [Int] = []
        let sizeSquared = size * size
        let row = index / size
        let col = index % size
        let value = _data[index]
        let group = SudokuPuzzle.groupFrom(index: index)
        for constraint in ConstraintType.allCases{
            switch constraint {
            case .cellConstraint:
                colNums.append(  SudokuPuzzle.indexOf( row: row, column: col))
                break
            case .rowConstraint:
                colNums.append( sizeSquared + row * size + value)
                break
            case .columnConstraint:
                colNums.append( 2 * sizeSquared + col * size + value)
                break
            case .groupConstaint:
                colNums.append( 3 * sizeSquared + group * size + value)
                break
            }
        }
        return colNums
    }
    private static func sudukoPuzzleFromRows(_ rows : [Int]) -> SudokuPuzzle{
        var data : [Int] = [Int](repeating: 0, count: 81)
        for rowNumber in rows{
            let all = SudokuPuzzle.rowValues(forRow: rowNumber, size: 9)
            let indx = indexOf( row: all.0, column: all.1)
            data[indx] = all.2 + 1
        }
        return SudokuPuzzle(data: data)
    }
    private func matrixRowfromSuduko( row : Int, col : Int, value : Int, size : Int) -> Int{
        return (size * size) * row + (col * size) + (col / (size * size)) % 9 + value
    }
    private static func rowValues(forRow: Int, size: Int) -> (Int,Int,Int){
           
           let value = forRow % size
           let row = (forRow / (size * size)) % size
           let col = (forRow / size) % size
           return (row, col, value)
       }
}

//MARK: SudokuPuzzle Description
extension SudokuPuzzle : CustomStringConvertible{
    public var description: String {
        var str = ""
        for (i,_) in data.enumerated(){
            str.append(String("\(data[i]) "))
             //if in column size, add a new line
            if i % size  == size - 1  && i / size != size - 1{
                str.append("\n")
            }
        }
        return str
    }
    var debugDescription: String {
        var i = 0
        return data.reduce("[ ") { (tally, val) -> String in
            var x = tally
            
            x.append(String(val))
            if i < self.data.count - 1{
                x.append(" , ")
            }
            i += 1
            return x
        } + " ]"
    }
    
    
}
//MARK: Creating utilties
extension SudokuPuzzle{
    //TODO: this shouldnt throw, if a puzzle cant be created we have deeper problems
    public static func createSquare(ofSize : Int) throws -> SudokuPuzzle{
           //
           var answers : [Int] = []
        try SudokuPuzzle.solver.solve(random: true) { (answer) -> Bool in
               answers = answer.first ?? []
               return true
           }
           if answers.count == 0{
               throw SudokuPuzzleError(type: .noSolutions, debugInfo: "createSquare was unable to create a puzzle.  An empty array was returned from DancingLinks solve")
           }
           return sudukoPuzzleFromRows(answers)
    }
    private func determineGivens() -> [Int]{
        var givenindices : [Int] = []
        for (i,v) in self.data.enumerated(){
            if(v > 0){
                givenindices.append(i)
            }
        }
       return givenindices
    }

    public static func creatPuzzle() throws -> SudokuPuzzle{
        
        return try createSquare(ofSize: 9).subtractTilGood(0)

    }
    fileprivate static let maxAttemptsWhileSubtracting = 5
    
    private func subtractTilGood(_ recurseNumber : Int) -> SudokuPuzzle{
        var randoms = [Int](0..<80).shuffled()
        var history : [[Int:Int]] = []
        var d = self.data
        
        //stage 1 remove first 40 symetrically
        for _ in 1...20{
            let candidate = randoms.removeFirst()
            let opposite = 80 - candidate
            history.append([candidate : d[candidate]])
            history.append([opposite : d[opposite]])
            d[candidate] = 0
            d[opposite] = 0
        }
        
        //step 2, remove randos individually
        var puzzle = SudokuPuzzle(data: d)
        do{
            while( try puzzle.uniquelySolvable() ){
                let candidate = randoms.removeFirst()
                history.append([candidate : d[candidate]])
                d[candidate] = 0
                puzzle = SudokuPuzzle(data: d)
            }
            //FIXME: ugly, history items can be tuples
            let lastKey = history.last!.keys.first!
            let lastValue = history.last![lastKey]!
            puzzle.data[lastKey] = lastValue
            
            //stage 3: try each item left individually until small
            var shouldStop = true
            var hasRemoved = false
            repeat{
                let indices = puzzle.data.indices.filter{ puzzle.data[$0] > 0}
                shouldStop = true
                for i in indices{
                    let v = puzzle.data[i]
                    puzzle.data[i] = 0
                    let p2 = SudokuPuzzle(data: puzzle.data)
                    if( try p2.uniquelySolvable()){
                        shouldStop = false
                        hasRemoved = true
                    }
                    else{
                        puzzle.data[i] = v
                    }
                }
            }while( !shouldStop )
            if(!hasRemoved && recurseNumber <= Self.maxAttemptsWhileSubtracting){
                //Its a dud, no removals in stage 3, try again until limit is reached
                return subtractTilGood(recurseNumber + 1)
            }
            return SudokuPuzzle(data: puzzle.data)
        }catch {
            //FIXME: no throw?
            return puzzle
        }
    }
    
    
    
    //TODO:  Check is this biased towards more squares revealed at bottom?
    //best 29 average
    internal func addTilUnique() -> SudokuPuzzle{
        let randoms = [Int](0..<80).shuffled()
        var i = 0
        let d = self._data
        var p = [Int](repeating: -1, count: 81 )
        for _ in 0..<18{
            p[randoms[i]] = d[randoms[i]]
            i += 1
        }
        //FIXME: bounds check
        while(true){
            let puzzle = SudokuPuzzle(data: p.map{$0 + 1})
            do {
                let (unique, answers) = try puzzle._uniquelySolvable()
                if(unique){
                    var puzzle = SudokuPuzzle(data: p.map{$0 + 1})
                    puzzle._givens = puzzle.determineGivens()
                    return puzzle
                }else{
                    if let a = answers.first, answers.count > 1{
                        let b = answers[1]
                        let uniqueRows = Set(a).subtracting(b)
                        let all = SudokuPuzzle.rowValues(forRow: uniqueRows.randomElement()!, size: 9)
                        let indx = SudokuPuzzle.indexOf(row: all.0, column: all.1)
                        p[indx] = all.2
                        i += 1
                    }

                    
                }
            } catch  {
                //FIXME:  throw?
            }
        }
    }
   
    
}

extension SudokuPuzzle {
    internal static var solver : DancingLinks = {
        return DancingLinks(from: baseMatrix, size: 9 * 9 * 4)
    }()
    internal static var baseMatrix : [Int] = {
        
        //make size^3 rows by size^2 * constaint types columns
                  let rowSize = 9 * 9 * 9
                  let colSize = 9 * 9 * ConstraintType.allCases.count
                  let dataSize = rowSize * colSize
                  var data : [Int] = [Int](repeating: 0, count: dataSize)
                  for i in 0 ..< dataSize{
                      let row = i / colSize
                      //let col = i % colSize
                      
                      //the row values of the matrix
                      let rowVals = rowValues(forRow: row, size: 9)
                      //print("(\(row),\(col))")
                      //the col values of the matrix
                      let firstColumnConstraint = (i / 9) % 9
                      let secondColumnConstraint = i % 9
                      
                      switch type(forIndex: i, size: colSize) {
                      case .cellConstraint:
                          //fisrtConstraint is row, second is column
                          data[i] = (secondColumnConstraint == rowVals.1 && firstColumnConstraint == rowVals.0) ? 1 : 0
                          // print("\(rowConstraint), \(colConstraint)")
                          break
                      case .rowConstraint:
                          //fisrtConstraint is row, second is value
                          data[i] = (secondColumnConstraint == rowVals.2 && firstColumnConstraint == rowVals.0) ? 1 : 0
                          // print("\(rowConstraint), \(colConstraint)")
                          break
                      case .columnConstraint:
                          //fisrtConstraint is col, second is value
                          data[i] = (secondColumnConstraint == rowVals.2 && firstColumnConstraint == rowVals.1) ? 1 : 0
                          break
                      case .groupConstaint:
                          //fisrtConstraint is group, second is value
                          let indx = indexOf( row: rowVals.0, column: rowVals.1)
                        data[i] = (secondColumnConstraint == rowVals.2 && firstColumnConstraint == groupFrom(index: indx)) ? 1 : 0
                          break
                      }
                      //print("\(i)) R\(rowR)C\(colC)V\(rowValue)")
                  }
                  return data
        
    }()
        //MARK: Internal Utility
        //FIXME: tied to a 9x9 puuzzle
        private static func type(forIndex: Int, size: Int) -> ConstraintType{
            let col = forIndex % size
            switch col {
            case 0...80:
                return .cellConstraint
            case 81...161:
                return .rowConstraint
            case 162...242:
                return .columnConstraint
            case 243...343:
                return .groupConstaint
            default:
                return .cellConstraint
            }
            
        }
}







internal enum ConstraintType : CaseIterable{
    case cellConstraint, rowConstraint, columnConstraint, groupConstaint

}

//MARK: Game Hashing
extension SudokuPuzzle {
    static var lowEndMask : UInt64 =  0xFF
   
    public var base64Hash : String {
        return hashed.base64EncodedString(options: [])
    }
    public  static func from(base64hash : String) -> SudokuPuzzle{
        
        if let data = Data(base64Encoded: base64hash){
            return SudokuPuzzle.from(hash: data)
        }
        //MARK: FIXME THROW ON ERROR
        return SudokuPuzzle()
    }
    
    public var hashed : Data {
        
        
        //MARK: TODO validate input is 81 
        
        var hashed = Data()
        var buffer : UInt64 = 0
        var byteCount = 0
        for (i, value) in self.data.enumerated(){
            //pack i into 5 bits, leftmost bit is a given flag, next 4 bits are encoded value, zero is a blank
            
            //prep buffer by shifting 5 left
            buffer = buffer << 5
            
            //take value at i and add it into buffer
            var bits : UInt8 = self.givens.contains(i) ? 0x10 : 0
            bits = bits | (UInt8(value) & 0xf)
            buffer = buffer | UInt64(bits)
            byteCount += 1
            var offset = 32  // 32 because we push 40 bytes in (40-32 = 8), then decrement the offset
            if byteCount == 8 || i == 80{
                //on case i=80, it hasnt been pushed a full 40 bits left, the value is sitting in the 0xFF position, so zero out the offset
                if(i == 80){
                    offset = 0
                }
                //empty the buffer into the hashed Data
                for _ in 1...5{
                    let chunk = UInt8((buffer >> offset ) & SudokuPuzzle.lowEndMask )
                    hashed.append(chunk)
                    offset -= 8
                }
                buffer = 0
                byteCount = 0
                offset = 32
            }
        }
        return hashed
    }
    
    public  static func from(hash : Data) -> SudokuPuzzle{
        var data = Data(repeating : 0 , count : 81)
        var givens : [Int] = []
        for i in 0..<81{
            let bitIndex = i * 5
            let byteIndex = bitIndex / 8
            var bitOffset = bitIndex % 8
            
            //fix for last one, not sure why this works yet.  Look into it
            if(i == 80){
                bitOffset = 3
            }
            
            if(byteIndex >= hash.count - 1) {
                break
            }
            
            //reconstruct given flag
            
            if hash[byteIndex] << bitOffset & 0x80 == 0x80{
                givens.append(i)
            }
            let byte : UInt8 =  hash[byteIndex]
            if(bitOffset > 3){
                //Need 2 bytes and reconstruct
                let nextByte = hash[byteIndex + 1]
                let remainderOnNext = bitOffset - 3
                let frontEnd = byte << remainderOnNext
                let tailEnd = nextByte >> (8 - remainderOnNext)
                data[i] = (frontEnd | tailEnd) & 0xf
            }
            else{
                //data is in only 1 byte
                let value = (((byte << bitOffset) & 0xf8) >> 3) & 0xf
                
                data[i] = value
            }
            
            
        }
        var arr = Array<UInt8>(repeating: 0, count: data.count/MemoryLayout<UInt8>.stride)
        _ = arr.withUnsafeMutableBytes { data.copyBytes(to: $0) }
        var puzzle = SudokuPuzzle(data: arr.map{Int($0)})
        
        //the given data may be different from the saved data, ie a person may hvae entered a few answers, so use the given flag data, not the data fed o SudokuPuzze(data:[Int])
        puzzle._givens = givens
        return puzzle
    }
    
}


