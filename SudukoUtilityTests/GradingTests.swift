//
//  GradingTests.swift
//  SudukoUtilityTests
//
//  Created by Mark Tassinari on 10/9/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//


import Foundation
import XCTest
@testable import SudukoUtility


class GradingTests: XCTestCase {
    
    
    func testPossibleValueMatrix(){
        
        let data = [
            0 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
            8 , 2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 ,
            0 , 0 , 3 , 8 , 0 , 0 , 9 , 0 , 0 ,
            0 , 6 , 0 , 0 , 9 , 0 , 3 , 0 , 0 ,
            0 , 9 , 8 , 5 , 0 , 6 , 4 , 7 , 0 ,
            0 , 0 , 1 , 0 , 7 , 0 , 0 , 9 , 0 ,
            0 , 0 , 5 , 0 , 0 , 9 , 1 , 0 , 0 ,
            0 , 0 , 0 , 7 , 0 , 0 , 0 , 4 , 9 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let possibles = puzzle.possibleValueMatrix
        let expected = [1,4,6]
        guard let possibleAt0 = possibles[0] else {
            XCTFail()
            return
        }
        XCTAssert(Set(possibleAt0) == Set(expected))
        let expected80 = [2,3,5,6,7,8]
        
        guard let possibleAt80 = possibles[80] else {
            XCTFail()
            return
        }
        XCTAssert(Set(possibleAt80) == Set(expected80))
        
        
    }
    func testNakedSingle(){
        
        let data = [
            8 , 0 , 9 , 6 , 5 , 7 , 4 , 2 , 1 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 ,
            0 , 0 , 0 , 8 , 0 , 0 , 0 , 0 , 6 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 4 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2 ,
            7 , 8 , 2 , 0 , 0 , 0 , 0 , 0 , 3 ,
            9 , 5 , 3 , 0 , 0 , 0 , 0 , 0 , 7 ,
            4 , 0 , 6 , 0 , 0 , 0 , 0 , 0 , 8
        ]
        let puzzle = SudokuPuzzle(data: data)
        let naked = puzzle.nakedSingles()
        XCTAssert(naked == [73 : 1, 1 : 3, 44 : 9])
        
        let puzzle2 = SudokuPuzzle.from(base64hash: "AC4AAAAEwABUAAAqAAAApa8QVACdgYAAALgACWAAtQAIzBUAI0ADIKTBi8QWACIM2nIAAAAAAA==")
        
        let naked2 = puzzle2.nakedSingles()
        print(puzzle2.description)
        XCTAssert(naked2 == [31:2,75:5,17:1,70:5,72:7])
        
        
    }
    func testHiddenSingle(){
        
        let data = [
            8 , 0 , 9 , 0 , 0 , 7 , 4 , 2 , 1 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 ,
            0 , 0 , 0 , 8 , 0 , 0 , 0 , 0 , 6 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 3 , 4 ,
            0 , 0 , 0 , 3 , 7 , 0 , 0 , 0 , 0 ,
            0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2 ,
            7 , 8 , 2 , 0 , 0 , 0 , 0 , 0 , 0 ,
            9 , 0 , 3 , 0 , 0 , 0 , 0 , 0 , 0 ,
            4 , 0 , 6 , 0 , 3 , 0 , 0 , 0 , 8
        ]
        let puzzle = SudokuPuzzle(data: data)
        let hidden = puzzle.hiddenSingles()
        XCTAssert(hidden == [1 : 3, 62 : 3, 71 : 7])
    }
    func testNakedPairs(){
        //http://www.sudokubeginner.com/naked-pair/
        let data = [
            0 , 0 , 1 , 4 , 9 , 0 , 7 , 0 , 0 ,
            0 , 0 , 4 , 0 , 0 , 6 , 9 , 0 , 0 ,
            8 , 0 , 9 , 0 , 1 , 7 , 5 , 4 , 0 ,
            2 , 8 , 0 , 0 , 7 , 0 , 0 , 5 , 9 ,
            4 , 1 , 7 , 9 , 0 , 0 , 2 , 6 , 8 ,
            5 , 9 , 0 , 0 , 2 , 0 , 0 , 0 , 0 ,
            0 , 4 , 5 , 0 , 8 , 0 , 0 , 0 , 3 ,
            0 , 0 , 8 , 7 , 0 , 0 , 0 , 0 , 0 ,
            0 , 0 , 2 , 0 , 0 , 9 , 8 , 0 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let naked = puzzle.nakedSets()
        let sets = [Set(arrayLiteral: 40,41),Set(arrayLiteral: 40,13),Set(arrayLiteral: 8,26)]
        XCTAssert(naked.count == 7)
        let _ = sets.map{ XCTAssert(naked.map{$0.indices}.contains($0))}

        //https://www.sudocue.net/guide.php
        let data2 = [
         0 , 0 , 5 , 1 , 6 , 0 , 0 , 0 , 0 ,
         6 , 0 , 0 , 0 , 7 , 3 , 0 , 0 , 0 ,
         3 , 0 , 0 , 0 , 0 , 5 , 7 , 0 , 6 ,
         0 , 0 , 0 , 0 , 3 , 0 , 6 , 9 , 1 ,
         1 , 3 , 9 , 7 , 5 , 6 , 4 , 8 , 2 ,
         8 , 6 , 2 , 4 , 9 , 1 , 0 , 0 , 7 ,
         4 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 5 ,
         0 , 0 , 0 , 5 , 0 , 0 , 0 , 0 , 8 ,
         0 , 0 , 0 , 0 , 0 , 7 , 2 , 0 , 0
        ]
        let puzzle2 = SudokuPuzzle(data: data2)
        let naked2 = puzzle2.nakedSets()
        let sets2 = [Set(arrayLiteral: 11,20),Set(arrayLiteral: 30,32)]
        XCTAssert(naked2.count == 6)
        let _ = sets2.map{ XCTAssert(naked2.map{$0.indices}.contains($0))}
        
    }
    func testNakedTriple(){
        
        //http://www.sudoku9981.com/sudoku-solving/naked-triple.php
        let data = [
            2 , 4 , 0 , 0 , 3 , 0 , 0 , 0 , 1 ,
            5 , 9 , 0 , 0 , 1 , 0 , 3 , 2 , 0 ,
            0 , 0 , 0 , 0 , 2 , 0 , 0 , 0 , 4 ,
            3 , 5 , 2 , 1 , 4 , 6 , 8 , 9 , 7 ,
            4 , 0 , 0 , 3,  8 , 9 , 5 , 1 , 2 ,
            1 , 8 , 9 , 5 , 7 , 2 , 6 , 4 , 3 ,
            0 , 2 , 0 , 0 , 9 , 3 , 1 , 0 , 0 ,
            6 , 0 , 0 , 0 , 5 , 1 , 0 , 0 , 9 ,
            9 , 0 , 0 , 0 , 6 , 0 , 0 , 3 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let naked = puzzle.nakedSets()
        let sets = [Set(arrayLiteral: 11,38,2),Set(arrayLiteral: 2,11,18)]
        let _ = sets.map{ XCTAssert(naked.map{$0.indices}.contains($0))}
        
        //http://www.sudokubeginner.com/naked-pair/
        let data2 = [
         2 , 3 , 0 , 5 , 0 , 0 , 0 , 0 , 7 ,
         0 , 1 , 5 , 0 , 0 , 0 , 0 , 2 , 0 ,
         0 , 8 , 0 , 2 , 0 , 0 , 0 , 0 , 6 ,
         1 , 5 , 0 , 0 , 0 , 0 , 0 , 6 , 4 ,
         8 , 9 , 0 , 1 , 0 , 0 , 0 , 0 , 0 ,
         0 , 0 , 0 , 0 , 5 , 0 , 9 , 1 , 0 ,
         0 , 4 , 0 , 8 , 1 , 5 , 6 , 0 , 0 ,
         0 , 6 , 1 , 0 , 3 , 0 , 0 , 0 , 0 ,
         0 , 0 , 8 , 0 , 0 , 6 , 4 , 0 , 1
        ]
        let puzzle2 = SudokuPuzzle(data: data2)
        let naked2 = puzzle2.nakedSets()
        let sets2 = [Set(arrayLiteral: 20,18,22),Set(arrayLiteral: 73,75,76)]
        let _ = sets2.map{ XCTAssert(naked2.map{$0.indices}.contains($0))}
        
        
    }
    func testNakedQuad(){
        //https://www.sudocue.net/guide.php
    
        
        let data = [
         8 , 0 , 0 , 0 , 7 , 0 , 0 , 0 , 9 ,
         0 , 1 , 0 , 0 , 0 , 0 , 0 , 5 , 0 ,
         7 , 0 , 0 , 6 , 0 , 8 , 0 , 0 , 3 ,
         3 , 8 , 0 , 1 , 0 , 5 , 2 , 7 , 4 ,
         0 , 0 , 0 , 2 , 0 , 7 , 0 , 0 , 0 ,
         2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 , 5 ,
         6 , 0 , 8 , 4 , 0 , 9 , 5 , 0 , 0 ,
         1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 6 ,
         5 , 9 , 0 , 0 , 0 , 0 , 0 , 4 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let sets = [Set(arrayLiteral: 6,7,24,25),Set(arrayLiteral: 14,9,12,13)]
        let naked = puzzle.nakedSets()
        
        let _ = sets.map{ XCTAssert(naked.map{$0.indices}.contains($0))}
        
        
    }
    func testHiddenPair(){
        //https://www.sudocue.net/guide.php
        
//        let d = "800070009010000050700608003380105074000207000200030005008409500100000006090000040"
//        var s = "let data = [\n"
//        for (i,c) in d.enumerated(){
//            if(i != 0 && i % 9 == 0){ s.append("\n")}
//            s.append(i == 80 ? " \(c) " :  " \(c) ," )
//
//        }
//        s.append("\n]")
//        print(s)
        
        let data = [
         8 , 0 , 0 , 0 , 7 , 0 , 0 , 0 , 9 ,
         0 , 1 , 0 , 0 , 0 , 0 , 0 , 5 , 0 ,
         7 , 0 , 0 , 6 , 0 , 8 , 0 , 0 , 3 ,
         3 , 8 , 0 , 1 , 0 , 5 , 2 , 7 , 4 ,
         0 , 0 , 0 , 2 , 0 , 7 , 0 , 0 , 0 ,
         2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 , 5 ,
         6 , 0 , 8 , 4 , 0 , 9 , 5 , 0 , 0 ,
         1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 6 ,
         5 , 9 , 0 , 0 , 0 , 0 , 0 , 4 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let hidden = puzzle.hiddenSets()
        let sets = [Set(arrayLiteral: 15,17),Set(arrayLiteral: 11,15,17)]
        let _ = sets.map{ XCTAssert(hidden.map{$0.indices}.contains($0))}
        
        
    }
}
