//
//  Sudoku.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 7/19/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation
public enum DificultyRating{
    case easy,medium, hard, impossible
}
struct SudokuPuzzleError : Error  {
    
    enum SudokuPuzzleErrorType{
        case noSolutions, multipleSolutions, unsolvable
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
    var data : [Int]
    var size : Int
    private var _data : [Int] {
        return data.map{$0 - 1}
    }
    init(data : [Int]){
        self.data = data
        self.size = 9
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
            return self.sudukoPuzzleFromRows(rows)
        } catch let e {
            throw e
        }
    }
    public func uniquelySolvable() throws -> Bool{
        
       
        //need to check if partial and set
        let solvedColumns = filledColumns()
        if(solvedColumns.count  > 0){
            SudokuPuzzle.solver.setPartialSolution(columns: filledColumns())
        }
        
        do {
            try SudokuPuzzle.solver.solve(random: true) { (answers) -> Bool in
                return answers.count > 1
            }
            if(solvedColumns.count  > 0){
                SudokuPuzzle.solver.clearPartialSolution(columns: filledColumns())
            }
            return SudokuPuzzle.solver.solutionSet.count == 1
            
        } catch let e {
            throw e
        }
    }
    public func errors() -> [(Int,Int)]{
        
        return []
    }
    public func rate() throws -> DificultyRating{
        
        return .easy
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
            let group = groupFromIndex(index: i)
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
        let group = groupFromIndex(index: index)
        for constraint in ConstraintType.allCases{
            switch constraint {
            case .cellConstraint:
                colNums.append(  indexOf(size: size, row: row, column: col))
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
    private func sudukoPuzzleFromRows(_ rows : [Int]) -> SudokuPuzzle{
        var data : [Int] = [Int](repeating: 0, count: 81)
        for rowNumber in rows{
            let all = SudokuPuzzle.rowValues(forRow: rowNumber, size: 9)
            let indx = indexOf(size: 9, row: all.0, column: all.1)
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
    public func createSquare(ofSize : Int) throws -> SudokuPuzzle{
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
    internal func creatPuzzle(ofDifficulty : DificultyRating ) throws -> SudokuPuzzle{
        
        return try createSquare(ofSize: 9).removeTilUnique()
    }
    internal func removeTilUnique() -> SudokuPuzzle{
        let randoms = [Int](0..<80).shuffled()
        var i = 0
        var lastvalue = 0
        var d = self._data
        //FIXME: bounds check
        while(true){
            lastvalue = d[randoms[i]]
            d[randoms[i]] = -1
            let puzzle = SudokuPuzzle(data: d.map{$0 + 1})
            if let b = try? puzzle.uniquelySolvable(){
                if(!b){
                    d[randoms[i]] = lastvalue
                    return  SudokuPuzzle(data: d.map{$0 + 1})
                }
            }
            i += 1
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
                          let indx = indexOf(size: 9, row: rowVals.0, column: rowVals.1)
                          data[i] = (secondColumnConstraint == rowVals.2 && firstColumnConstraint == groupFromIndex(index: indx)) ? 1 : 0
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


//FIXME: this is tied to a 9*9 suduko
internal func groupFromIndex(index : Int)-> Int{
    
    let nChunkIndex = index / 3;
    let row = nChunkIndex / 9;
    let column = nChunkIndex % 3;
    return column + row * 3;
}
internal func indexOf(size: Int, row: Int, column : Int) -> Int{
    return row * size + column
}



internal enum ConstraintType : CaseIterable{
    case cellConstraint, rowConstraint, columnConstraint, groupConstaint

}


