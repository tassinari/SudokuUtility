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
    
//    func testThatSudokuCanPrintItself(){
//        let data = [1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4]
//        let s = SudokuPuzzle(data: data, size: 4)
//        let string = s.description
//        let expected = "1 2 3 4 \n1 2 3 4 \n1 2 3 4 \n1 2 3 4 "
//
//        XCTAssert(string == expected,"\(string) did not equal \(expected)")
//    }
    
    func testThatMakeMatrixHasRightDataSize(){
        
        XCTAssert(SudokuPuzzle.baseMatrix.count == 236196)
    }
    func testThatMakeMatrixHasRightNumberOfOnes(){
        let count = SudokuPuzzle.baseMatrix.filter{$0 == 1}.count
       XCTAssert(count == 2916)
    }
    func testCreateSquare(){
       
        do {
            let square = try SudokuPuzzle.createSquare(ofSize: 9)
            XCTAssert(square.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
    func testIsCorrectReturnsTrueOnValidPuzzle(){
        
        let data =
        [ 6 , 9 , 2 , 7 , 3 , 5 , 4 , 1 , 8 ,
          8 , 7 , 5 , 4 , 9 , 1 , 6 , 3 , 2 ,
          4 , 1 , 3 , 2 , 8 , 6 , 5 , 9 , 7 ,
          9 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 ,
          5 , 3 , 7 , 6 , 1 , 2 , 9 , 8 , 4 ,
          2 , 4 , 8 , 3 , 7 , 9 , 1 , 6 , 5 ,
          1 , 5 , 9 , 8 , 2 , 3 , 7 , 4 , 6 ,
          3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 9 ,
          7 , 8 , 6 , 9 , 5 , 4 , 3 , 2 , 1
        ]
        let puzzle = SudokuPuzzle(data: data)
        XCTAssert(puzzle.isSolved())
    }
    func testIsCorrectReturnsFalseOnInValidPuzzle(){
        //FIXME:  this data is off by 1 now
        let data = [ 7 , 0 , 2 , 7 , 3 , 5 , 4 , 1 , 8 , 8 , 7 , 5 , 4 , 0 , 1 , 6 , 3 , 2 , 4 , 1 , 3 , 2 , 8 , 6 , 5 , 0 , 7 , 0 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 , 5 , 3 , 7 , 6 , 1 , 2 , 0 , 8 , 4 , 2 , 4 , 8 , 3 , 7 , 0 , 1 , 6 , 5 , 1 , 5 , 0 , 8 , 2 , 3 , 7 , 4 , 6 , 3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 0 , 7 , 8 , 6 , 0 , 5 , 4 , 3 , 2 , 1 ]
        let puzzle = SudokuPuzzle(data: data)
        XCTAssert(!puzzle.isSolved())
        
        let swapped = [ 1 , 0 , 2 , 7 , 3 , 5 , 4 , 6 , 8 , 8 , 7 , 5 , 4 , 0 , 1 , 6 , 3 , 2 , 4 , 1 , 3 , 2 , 8 , 6 , 5 , 0 , 7 , 0 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 , 5 , 3 , 7 , 6 , 1 , 2 , 0 , 8 , 4 , 2 , 4 , 8 , 3 , 7 , 0 , 1 , 6 , 5 , 1 , 5 , 0 , 8 , 2 , 3 , 7 , 4 , 6 , 3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 0 , 7 , 8 , 6 , 0 , 5 , 4 , 3 , 2 , 1 ]
        let puzzle2 = SudokuPuzzle(data: swapped)
        XCTAssert(!puzzle2.isSolved())
        
        let data2 =
        [ 0 , 9 , 2 , 7 , 3 , 5 , 4 , 1 , 8 ,
          8 , 7 , 5 , 4 , 9 , 1 , 6 , 3 , 2 ,
          4 , 1 , 3 , 2 , 8 , 6 , 5 , 9 , 7 ,
          9 , 6 , 1 , 5 , 4 , 8 , 2 , 7 , 3 ,
          5 , 3 , 7 , 6 , 1 , 2 , 9 , 8 , 4 ,
          2 , 4 , 8 , 3 , 7 , 9 , 1 , 6 , 5 ,
          1 , 5 , 9 , 8 , 2 , 3 , 7 , 4 , 6 ,
          3 , 2 , 4 , 1 , 6 , 7 , 8 , 5 , 9 ,
          7 , 8 , 6 , 9 , 5 , 4 , 3 , 2 , 1
        ]
        let puzzle3 = SudokuPuzzle(data: data2)
        XCTAssert(!puzzle3.isSolved())
    }
    func testSolvePartial(){
        let data = [
          0 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
          8 , 2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 ,
          0 , 0 , 3 , 8 , 0 , 0 , 9 , 0 , 0 ,
          0 , 6 , 0 , 0 , 9 , 0 , 3 , 0 , 0 ,
          0 , 9 , 8 , 5 , 0 , 6 , 4 , 7 , 0 ,
          0 , 0 , 1 , 0 , 7 , 0 , 0 , 9 , 0 ,
          0 , 0 , 5 , 0 , 0 , 9 , 1 , 0 , 0 ,
          0 , 0 , 0 , 7 , 0 , 0 , 0 , 4 , 9 ,
          0 , 0 , 0 , 4 , 2 , 0 , 8 , 0 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solved = try puzzle.solvedCopy()
            XCTAssert(solved.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    func testThatMultipleSolvesCanHappenReusingSameSolver(){
        let data = [
          0 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
          8 , 2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 ,
          0 , 0 , 3 , 8 , 0 , 0 , 9 , 0 , 0 ,
          0 , 6 , 0 , 0 , 9 , 0 , 3 , 0 , 0 ,
          0 , 9 , 8 , 5 , 0 , 6 , 4 , 7 , 0 ,
          0 , 0 , 1 , 0 , 7 , 0 , 0 , 9 , 0 ,
          0 , 0 , 5 , 0 , 0 , 9 , 1 , 0 , 0 ,
          0 , 0 , 0 , 7 , 0 , 0 , 0 , 4 , 9 ,
          0 , 0 , 0 , 4 , 2 , 0 , 8 , 0 , 0
        ]
        let data2 = [ 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ]
        let testData = [data,data2]
        for d in testData{
            let puzzle = SudokuPuzzle(data: d)
            
            do {
                let solved = try puzzle.solvedCopy()
                XCTAssert(solved.isSolved())
            } catch let e {
                XCTFail(e.localizedDescription)
            }
        }
    }
    func testSolvePartialWithFewFilledIn(){
        let data = [ 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ]
        //let data = [ 1 , 3 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2 , 3 , 0 , 0 , 0 , 0 , 2 , 3 , 0 , 0 , 0 , 0 , 0 , 3 , 2 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2 , 3 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2 , 3 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 3 , 0 , 2 , 3 , 0 , 0 , 0 , 0 , 2 , 0 , 0 , 0 , 0 , 2 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solved = try puzzle.solvedCopy()
            print(solved.description)
            XCTAssert(solved.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    func testSolvePartialWithAllButOneFilledIn(){
        
        let data = [ 8 , 1 , 5 , 4 , 7 , 3 , 6 , 2 , 9 , 6 , 3 , 7 , 5 , 2 , 9 , 1 , 4 , 8 , 0 , 9 , 2 , 1 , 6 , 8 , 3 , 5 , 7 , 5 , 7 , 6 , 8 , 9 , 2 , 4 , 1 , 3 , 1 , 4 , 9 , 3 , 5 , 7 , 8 , 6 , 2 , 3 , 2 , 8 , 6 , 4 , 1 , 9 , 7 , 5 , 2 , 8 , 3 , 7 , 1 , 6 , 5 , 9 , 4 , 9 , 5 , 1 , 2 , 3 , 4 , 7 , 8 , 6 , 7 , 6 , 4 , 9 , 8 , 5 , 2 , 3 , 1 ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solved = try puzzle.solvedCopy()
            print(solved.description)
            XCTAssert(solved.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    
    func testPerformanceOfSolve() throws {
        //TODO: beter performance measurements
        self.measure {
            let dl = SudokuPuzzle.solver
            do {
                try dl.solve(random: true) { (answer) -> Bool in
                    return true
                }
            } catch let e {
                XCTFail(e.localizedDescription)
            }
        }
    }
    func testPuzzleIsUniqueShouldBeFalse(){
        let data = [ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0  , 5 , 2 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 8 , 0 , 0 , 0 , 0 , 0 , 0 , 4 , 0 , 0 , 3 , 0 , 0 , 0 , 0 , 0 , 5 , 1 , 0 , 9 , 0 , 0 , 0 , 6 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 5 , 0 , 0 , 6 , 0 , 0 , 1 , 7 , 0 , 0 , 0 , 2 , 0 , 0 , 8 , 0 , 0 , 0 , 0 ]
       
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solvable = try puzzle.uniquelySolvable()
            XCTAssert(!solvable)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
    func  testPuzzleIsUniqueShouldBeTrueWithOneNumberMissing(){
        let data = [ 8 , 1 , 5 , 4 , 7 , 3 , 6 , 2 , 9 , 6 , 3 , 7 , 5 , 2 , 9 , 1 , 4 , 8 , 0 , 9 , 2 , 1 , 6 , 8 , 3 , 5 , 7 , 5 , 7 , 6 , 8 , 9 , 2 , 4 , 1 , 3 , 1 , 4 , 9 , 3 , 5 , 7 , 8 , 6 , 2 , 3 , 2 , 8 , 6 , 4 , 1 , 9 , 7 , 5 , 2 , 8 , 3 , 7 , 1 , 6 , 5 , 9 , 4 , 9 , 5 , 1 , 2 , 3 , 4 , 7 , 8 , 6 , 7 , 6 , 4 , 9 , 8 , 5 , 2 , 3 , 1 ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solvable = try puzzle.uniquelySolvable()
            XCTAssert(solvable)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    func  testPuzzleIsUnique(){
  let data = [ 5 , 9 , 6 , 1 , 7 , 8 , 2 , 3 , 4 , 4 , 1 , 8 , 2 , 3 , 6 , 0 , 9 , 7 , 3 , 0 , 7 , 4 , 5 , 9 , 8 , 6 , 1 , 9 , 7 , 3 , 8 , 4 , 2 , 6 , 1 , 5 , 1 , 0 , 5 , 3 , 6 , 7 , 9 , 8 , 2 , 8 , 6 , 2 , 9 , 1 , 5 , 7 , 4 , 3 , 7 , 5 , 1 , 6 , 8 , 3 , 4 , 2 , 0 , 6 , 0 , 9 , 0 , 2 , 4 , 0 , 7 , 0 , 2 , 8 , 4 , 0 , 0 , 0 , 3 , 5 , 6 ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solved = try puzzle.solvedCopy()
            XCTAssert(solved.isSolved())
            XCTAssert(try puzzle.uniquelySolvable())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    func testMeasureCreate(){
        
        do {
            let _ = try SudokuPuzzle.creatPuzzle()
            self.measure {
                do{
                    let _ = try SudokuPuzzle.creatPuzzle()
                }catch let e{
                    XCTFail(e.localizedDescription)
                }
                
            }
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    func testCreate(){
       
        do {
            let puzzle = try SudokuPuzzle.creatPuzzle()
            print("==========")
            print(puzzle.description)
            print("==========")
            XCTAssert(try puzzle.uniquelySolvable())
            print("size: \(puzzle.data.filter{$0 != 0}.count)")
            let solved = try puzzle.solvedCopy()
            print(solved.description)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
       

    }
    func testCreateSize(){
        let count = 40
        var sizes : [Int] = []
        do {
            for _ in 0..<count{
                let puzzle = try SudokuPuzzle.creatPuzzle()
                sizes.append(puzzle.data.filter{$0 != 0}.count)
            }
            let average = sizes.reduce(0,+) / count
            //print("size average is \(average)")
            XCTAssert(average < 31,"Average is off, should be ~29 but is \(average)")
           
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        
    }
    
    
    func testThatMultipleSolvesWorks(){
        let data = [
          0 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
          8 , 2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 ,
          0 , 0 , 3 , 8 , 0 , 0 , 9 , 0 , 0 ,
          0 , 6 , 0 , 0 , 9 , 0 , 3 , 0 , 0 ,
          0 , 9 , 8 , 5 , 0 , 6 , 4 , 7 , 0 ,
          0 , 0 , 1 , 0 , 7 , 0 , 0 , 9 , 0 ,
          0 , 0 , 5 , 0 , 0 , 9 , 1 , 0 , 0 ,
          0 , 0 , 0 , 7 , 0 , 0 , 0 , 4 , 9 ,
          0 , 0 , 0 , 4 , 2 , 0 , 8 , 0 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        
        do {
            let solved = try puzzle.solvedCopy()
            XCTAssert(solved.isSolved())
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        let dl = DancingLinks(from: SudokuPuzzle.baseMatrix, size: 9 * 9 * 4)
        let b = treesAreTheSame(tree1Root: SudokuPuzzle.solver.root, tree2Root: dl.root)
        XCTAssert(b,"Tree is not the same")
        
    }
    func treesAreTheSame(tree1Root : DLXNode,tree2Root : DLXNode ) -> Bool{
        func columnsEqual(col1 : DLXNode, col2 : DLXNode) -> Bool{
            if(col1.coordinate.column != col2.coordinate.column ){
                return false
            }
            var cNode1 : DLXNode = col1.bottom
            var cNode2 : DLXNode = col2.bottom
            while(cNode1 != col1){
                if(cNode1.coordinate != cNode2.coordinate){
                    return false
                }
                cNode2 = cNode2.bottom
                cNode1 = cNode1.bottom
            }
            return true
        }
        
        var cNode1 : DLXNode = tree1Root.right
        var cNode2 : DLXNode = tree2Root.right
        while(cNode1 != tree1Root){
            if(!columnsEqual(col1: cNode2, col2: cNode1)){
                return false
            }
            cNode2 = cNode2.right
            cNode1 = cNode1.right
        }
        return true
    }
    
    func testDissallowedValuesForCurrentState(){
        
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
        let actualAt0 = puzzle.disallowedValuesForCurrentState(atIndex: 0)
        let expected = [2,3,5,7,8,9]
        XCTAssert(Set(actualAt0) == Set(expected))
        
        let actualAt80 = puzzle.disallowedValuesForCurrentState(atIndex: 80)
        let expected80 = [9,4,1]
        XCTAssert(Set(actualAt80) == Set(expected80))
    }
    
    func testEncodeDecodeWorks(){
        let data = [
          2 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
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
        let newPuzzle = SudokuPuzzle.from(hash: puzzle.hashed)
        var actualGivens : [Int] =  []
        for (i,v) in data.enumerated(){
            if(v > 0){
                actualGivens.append(i)
            }
        }
        XCTAssert(actualGivens == newPuzzle.givens)
        XCTAssert(newPuzzle.data == puzzle.data)
    }
    func testEncodeDecode64Works(){
        let data = [
          2 , 0 , 9 , 0 , 5 , 7 , 0 , 0 , 0 ,
          8 , 2 , 0 , 0 , 0 , 3 , 0 , 0 , 0 ,
          0 , 0 , 3 , 8 , 0 , 0 , 9 , 0 , 0 ,
          0 , 6 , 0 , 0 , 9 , 0 , 3 , 0 , 0 ,
          0 , 9 , 8 , 5 , 0 , 6 , 4 , 7 , 0 ,
          0 , 0 , 1 , 0 , 7 , 0 , 0 , 9 , 0 ,
          0 , 0 , 5 , 0 , 0 , 9 , 1 , 0 , 0 ,
          0 , 0 , 0 , 7 , 0 , 0 , 0 , 4 , 9 ,
          4 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
        ]
        let puzzle = SudokuPuzzle(data: data)
        let b64 = puzzle.base64Hash
        let newPuzzle = SudokuPuzzle.from(base64hash: b64)
        print(b64)
        XCTAssert(newPuzzle.data == puzzle.data)
    }
    
    func testThatGivensAreSet(){
        do {
            for _ in 0..<10{
                
                let puzzle = try SudokuPuzzle.creatPuzzle()
                var actualGivens : [Int] =  []
                for (i,v) in puzzle.data.enumerated(){
                    if(v > 0){
                        actualGivens.append(i)
                    }
                }
                XCTAssert(actualGivens == puzzle.givens)
            }
            
        } catch  {
            XCTFail("could not create puzzle")
        }
        
        
    }
   
}
