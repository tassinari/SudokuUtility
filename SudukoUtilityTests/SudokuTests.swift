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
    func testSolveOfEmptyPuzzle(){
        let s = SudokuUtility()
        do {
            let _ = try s.createSquare(ofSize: 9)
            //print(square.description)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
        
//        let data = s.baseMatrix(size: 9)
//        let dl = DancingLinks(from: data, size: 9 * 9 * 4)
//        do {
//            try dl.solve(random: true) { (answer) -> Bool in
//                print(answer.first)
//                return true
//            }
//            print(dl.solutionSet)
//        } catch let e {
//            XCTFail(e.localizedDescription)
//        }
        
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


