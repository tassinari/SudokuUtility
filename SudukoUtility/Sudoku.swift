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
public struct SudokuPuzzle{
    var data : [Int]
    var size : Int
    
    init(data : [Int], size : Int){
        self.data = data
        self.size = size
    }
    init( withDifficulty: DificultyRating) {
        self.data = []
        self.size = 9
    }
}

//MARK: Solving utilties
extension SudokuPuzzle{
    
    public func solvedCopy() throws -> SudokuPuzzle{
        let dl = DancingLinks(withPuzzle: self)
        let solvedColumns = filledColumns()
        if(solvedColumns.count  > 0){
            dl.setPartialSolution(columns: filledColumns())
        }
        
        do {
            try dl.solve(random: true) { (answers) -> Bool in
                   return true
            }
            guard let solution = dl.solutionSet.first else {
                throw SudokuPuzzleError(type: .noSolutions, debugInfo: "No solutions found")
            }
            var filledRows : [Int] = []
            for (i,v) in self.data.enumerated(){
                if(v > 0){
                    filledRows.append(matrixRowfromSuduko(row: i / size, col: i % size, value: v, size: size ))
                }
            }
            var rows = solution.map{$0.coordinate.row}
            rows.append(contentsOf: filledRows)
            //FIXME: This is returning the rows, need to return a Puzzle
            return self.sudukoPuzzleFromRows(rows)
        } catch let e {
            throw e
        }
    }
    public func uniquelySolvable() throws -> Bool{
        
        let dl = DancingLinks(withPuzzle: self)
        do {
            try dl.solve(random: true) { (answers) -> Bool in
                return answers.count > 1
            }
            return dl.solutionSet.count == 1
            
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
    func isSolved() -> Bool{
        
        //check every item is a number
        //TODO: make zeros denote empty
        //        if self.data.contains(0){
        //            return false
        //        }
        
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
        let allRowsGood = !rowArray.map { $0.reduce(0,+) == 36 }.contains(false)  //sum each row and check for a false
        let allColsGood = !colArray.map { $0.reduce(0,+) == 36 }.contains(false)  //sum each col and check for a false
        let allGroupsGood = !groupArray.map { $0.reduce(0,+) == 36 }.contains(false)  //sum each group and check for a false
        
        return allRowsGood && allColsGood && allGroupsGood
    }
    internal func filledColumns() -> [Int]{
        var cols : [Int] = []
        for (i, v) in self.data.enumerated(){
            if( v != 0){
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
        let value = data[index]
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
        var data : [Int] = [Int](repeating: 0, count: rows.count)
        for rowNumber in rows{
            let all = rowValues(forRow: rowNumber, size: 9)
            let indx = indexOf(size: 9, row: all.0, column: all.1)
            data[indx] = all.2
        }
        return SudokuPuzzle(data: data, size: 9)
    }
    private func matrixRowfromSuduko( row : Int, col : Int, value : Int, size : Int) -> Int{
        return (size * size) * row + (col * size) + (col / (size * size)) % 9 + value
    }
    private func rowValues(forRow: Int, size: Int) -> (Int,Int,Int){
           
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

func sudokuToMatrix(_ sudoku : SudokuPuzzle) -> [Int] {
    
    
    return []
}
func matrixToSudoku(_ matrix : [Int]) -> SudokuPuzzle{
    
    
    return SudokuPuzzle(data: [], size: 0)
}

internal enum ConstraintType : CaseIterable{
    case cellConstraint, rowConstraint, columnConstraint, groupConstaint

}

//MARK: Dancing Links Extension

internal extension DancingLinks {
    
    convenience init(withPuzzle: SudokuPuzzle){
        let matrix = SudokuUtility().baseMatrix(size: withPuzzle.size)
        self.init(from:matrix, size:  9 * 9 * 4)
        
    }
    
}

//MARK: SuudukoUtility Errors

struct SudokuUtilityError : Error  {
    
    enum SudokuUtilityErrorType{
        case creationError
    }
    var localizedDescription : String {
        return debugInfo
    }
    
    let type : SudokuUtilityErrorType
    let debugInfo :String
}


//MARK:  SudokuUtility

public class SudokuUtility{
    
    //MARK: Public Functions
    public func createSquare(ofSize : Int) throws -> SudokuPuzzle{
        
        let s = SudokuUtility()
        let data = s.baseMatrix(size: ofSize)
        let dl = DancingLinks(from: data, size: 9 * 9 * 4)
        var answers : [Int] = []
        try dl.solve(random: true) { (answer) -> Bool in
            answers = answer.first ?? []
            return true
        }
        if answers.count == 0{
            throw SudokuUtilityError(type: .creationError, debugInfo: "createSquare was unable to create a puzzle.  An empty array was returned from DancingLinks solve")
        }
        return sudukoPuzzleFromRows(answers)
    }
    func sudukoPuzzleFromRows(_ rows : [Int])->SudokuPuzzle{
        var data : [Int] = [Int](repeating: 0, count: rows.count)
        for rowNumber in rows{
            let all = rowValues(forRow: rowNumber, size: 9)
            let indx = indexOf(size: 9, row: all.0, column: all.1)
            data[indx] = all.2
        }
        return SudokuPuzzle(data: data, size: 9)
    }
    //MARK: Internal Utility
    //FIXME: tied to a 9x9 puuzzle
    private func type(forIndex: Int, size: Int) -> ConstraintType{
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
    
    /// Returns the values of Row, Column and Value for a particular index (Index, not row) of the base matrix
    ///  see: https://www.stolaf.edu/people/hansonr/sudoku/exactcovermatrix.htm
    ///  This will make the rows of the above example
    /// - Parameters:
    ///   - forRow: the index
    ///   - size: the number of columns
    /// - Returns: a tuple of (Row, Column, Value)
    
    private func rowValues(forRow: Int, size: Int) -> (Int,Int,Int){
        
        let value = forRow % size
        let row = (forRow / (size * size)) % size
        let col = (forRow / size) % size
        return (row, col, value)
    }
    
    //MARK: Base Matrix
    //TODO: Make this a lazy var to cahe and run only once
    internal func baseMatrix(size: Int) -> [Int]{
        //make size^3 rows by size^2 * constaint types columns
        let rowSize = size * size * size
        let colSize = size * size * ConstraintType.allCases.count
        let dataSize = rowSize * colSize
        var data : [Int] = [Int](repeating: 0, count: dataSize)
        for i in 0 ..< dataSize{
            let row = i / colSize
            //let col = i % colSize
            
            //the row values of the matrix
            let rowVals = rowValues(forRow: row, size: size)
            //print("(\(row),\(col))")
            //the col values of the matrix
            let firstColumnConstraint = (i / size) % size
            let secondColumnConstraint = i % size
            
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
                let indx = indexOf(size: size, row: rowVals.0, column: rowVals.1)
                data[i] = (secondColumnConstraint == rowVals.2 && firstColumnConstraint == groupFromIndex(index: indx)) ? 1 : 0
                break
            }
            //print("\(i)) R\(rowR)C\(colC)V\(rowValue)")
        }
        return data
    }
//    internal func makeMatrix(fromPuzzle : SudokuPuzzle) throws -> [Int] {
//        //FIXME: base matrix muust be lazy
//        var fullMatrix = self.baseMatrix(size: fromPuzzle.size)
//        let colSize = fromPuzzle.size * fromPuzzle.size * 4
//        for (i,v) in fromPuzzle.data.enumerated(){
//            if(v == 0){
//                continue
//            }
//            let cols = self.matrixColumnsfromSuduko(row: i / fromPuzzle.size, col:  i % fromPuzzle.size, value: v,group : groupFromIndex(index: i), size: fromPuzzle.size )
//            let row = matrixRowfromSuduko(row: i / fromPuzzle.size, col: i % fromPuzzle.size, value: v, group: groupFromIndex(index: i), size: fromPuzzle.size)
//            for col in cols{
//                for i in everyIndexInAColumn(fromIndex: col, columnSize: colSize , length: fullMatrix.count){
//                    if fullMatrix[i] == 1 && i / colSize != row {
//                        fullMatrix[i] = 0
//                    }
//                }
//            }
//        }
//        return fullMatrix
//    }
    private func matrixRowfromSuduko( row : Int, col : Int, value : Int,group : Int, size : Int) -> Int{
        return size * row + (col * size) % size + value
    }
    
//    private func everyIndexInAColumn(fromIndex: Int, columnSize : Int, length : Int) -> [Int]{
//        var cols : [Int] = []
//        var col = fromIndex % columnSize
//        while col < length{
//            cols.append(col)
//            col += columnSize
//        }
//
//        return cols
//    }
}
