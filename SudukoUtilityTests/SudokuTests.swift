//
//  SudokuTests.swift
//  SudukoUtilityTests
//
//  Created by Mark Tassinari on 7/19/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation
import XCTest
@testable import SudukoUtility


class SudokuTests: XCTestCase {
    
    func testThatSudokuCanPrintItself(){
        let data = [1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4]
        let s = SudokuPuzzle(data: data, size: 4)
        let string = s.description
        let expected = "1 2 3 4 \n1 2 3 4 \n1 2 3 4 \n1 2 3 4 "

        XCTAssert(string == expected,"\(string) did not equal \(expected)")
    }
    
    func testThatMakeMatrixHasRightDataSize(){
        let s = SudokuUtility()
        let data = s.baseMatrix(size: 9)
        XCTAssert(data.count == 236196)
    }
    func testThatMakeMatrixHasRightNuumberOfOnes(){
        let s = SudokuUtility()
        let data = s.baseMatrix(size: 9)
        let count = data.filter{$0 == 1}.count
       XCTAssert(count == 2916)
    }
    func testSquarePuzzleIsValid(){
        let s = SudokuUtility()
        do {
            let square = try s.createSquare(ofSize: 9)
            print(square)
            XCTAssert(square.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
    func testIsCorrectReturnsTrueOnValidPuzzle(){
        
        let data = [ 6 , 0 , 2 , 7 , 3 , 5 , 4 , 1 , 8 , 8 , 7 , 5 , 4 , 0 , 1 , 6 , 3 , 2 , 4 , 1 , 3 , 2 , 8 , 6 , 5 , 0 , 7 , 0 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 , 5 , 3 , 7 , 6 , 1 , 2 , 0 , 8 , 4 , 2 , 4 , 8 , 3 , 7 , 0 , 1 , 6 , 5 , 1 , 5 , 0 , 8 , 2 , 3 , 7 , 4 , 6 , 3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 0 , 7 , 8 , 6 , 0 , 5 , 4 , 3 , 2 , 1 ]
        let puzzle = SudokuPuzzle(data: data, size: 9)
        XCTAssert(puzzle.isSolved())
    }
    func testIsCorrectReturnsFalseOnInValidPuzzle(){
        
        let data = [ 7 , 0 , 2 , 7 , 3 , 5 , 4 , 1 , 8 , 8 , 7 , 5 , 4 , 0 , 1 , 6 , 3 , 2 , 4 , 1 , 3 , 2 , 8 , 6 , 5 , 0 , 7 , 0 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 , 5 , 3 , 7 , 6 , 1 , 2 , 0 , 8 , 4 , 2 , 4 , 8 , 3 , 7 , 0 , 1 , 6 , 5 , 1 , 5 , 0 , 8 , 2 , 3 , 7 , 4 , 6 , 3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 0 , 7 , 8 , 6 , 0 , 5 , 4 , 3 , 2 , 1 ]
        let puzzle = SudokuPuzzle(data: data, size: 9)
        XCTAssert(!puzzle.isSolved())
        
        let swapped = [ 1 , 0 , 2 , 7 , 3 , 5 , 4 , 6 , 8 , 8 , 7 , 5 , 4 , 0 , 1 , 6 , 3 , 2 , 4 , 1 , 3 , 2 , 8 , 6 , 5 , 0 , 7 , 0 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 , 5 , 3 , 7 , 6 , 1 , 2 , 0 , 8 , 4 , 2 , 4 , 8 , 3 , 7 , 0 , 1 , 6 , 5 , 1 , 5 , 0 , 8 , 2 , 3 , 7 , 4 , 6 , 3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 0 , 7 , 8 , 6 , 0 , 5 , 4 , 3 , 2 , 1 ]
        let puzzle2 = SudokuPuzzle(data: swapped, size: 9)
        XCTAssert(!puzzle2.isSolved())
    }
    
    
    func testPerformanceOfSolve() throws {
        self.measure {
            let s = SudokuUtility()
            let data = s.baseMatrix(size: 9)
            let dl = DancingLinks(from: data, size: 9 * 9 * 4)
            do {
                try dl.solve(random: true) { (answer) -> Bool in
                    return true
                }
            } catch let e {
                XCTFail(e.localizedDescription)
            }
        }
    }
    
}


