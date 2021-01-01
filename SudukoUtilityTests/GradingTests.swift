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
        let naked = puzzle.nakedSingles(possibles: puzzle.possibleValueMatrix)
        XCTAssert(naked.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(73)], answer: HintAnswer(index: 73, value: 1))))
        XCTAssert(naked.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(44)], answer: HintAnswer(index: 44, value: 9))))
       
        
        let puzzle2 = SudokuPuzzle.from(base64hash: "AC4AAAAEwABUAAAqAAAApa8QVACdgYAAALgACWAAtQAIzBUAI0ADIKTBi8QWACIM2nIAAAAAAA==")
        
        let naked2 = puzzle2.nakedSingles(possibles: puzzle2.possibleValueMatrix)
        print(puzzle2.description)
        XCTAssert(naked2.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(31)], answer: HintAnswer(index: 31, value: 2))))
        XCTAssert(naked2.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(75)], answer: HintAnswer(index: 75, value: 5))))
        XCTAssert(naked2.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(17)], answer: HintAnswer(index: 17, value: 1))))
        XCTAssert(naked2.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(70)], answer: HintAnswer(index: 70, value: 5))))
        XCTAssert(naked2.contains(Hint(type: .nakedSingle, possiblesHighlights: [], highlights: [HighlightType.index(72)], answer: HintAnswer(index: 72, value: 7))))
        
        
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
        let hidden = puzzle.hiddenSingles(possibles: puzzle.possibleValueMatrix)
        XCTAssert(hidden.contains(Hint(type: .hiddenSingle, possiblesHighlights: [PossibleHighlights(index: 1, positiveHighlights: [3], negativeHighlights: [])], highlights: [HighlightType.house(House(type: .row, houseIndex: 0))], answer: HintAnswer(index: 1, value: 3))))
        XCTAssert(hidden.contains(Hint(type: .hiddenSingle, possiblesHighlights: [PossibleHighlights(index: 62, positiveHighlights: [3], negativeHighlights: [])], highlights: [HighlightType.house(House(type: .column, houseIndex: 8))], answer: HintAnswer(index: 62, value: 3))))
        XCTAssert(hidden.contains(Hint(type: .hiddenSingle, possiblesHighlights: [PossibleHighlights(index: 71, positiveHighlights: [7], negativeHighlights: [])], highlights: [HighlightType.house(House(type: .column, houseIndex: 8))], answer: HintAnswer(index: 71, value: 7))))
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
        let naked = puzzle.nakedSets(possibles: puzzle.possibleValueMatrix)
        XCTAssert(naked.count == 7)
//        print("var expected1 : [Hint] = []")
//        for hint in naked{
//            print("expected1.append( \(hint.debugDescription) )")
//        }
        var expected1 : [Hint] = []
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 57, positiveHighlights: [2, 1, 6], negativeHighlights : []), PossibleHighlights(index: 59, positiveHighlights: [2, 1, 6], negativeHighlights : []), PossibleHighlights(index: 60, positiveHighlights: [2, 1, 6], negativeHighlights : []), PossibleHighlights(index: 54, positiveHighlights: [], negativeHighlights : [1, 6]), PossibleHighlights(index: 61, positiveHighlights: [], negativeHighlights : [2, 1])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 6))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 13, positiveHighlights: [3, 5], negativeHighlights : []), PossibleHighlights(index: 40, positiveHighlights: [3, 5], negativeHighlights : []), PossibleHighlights(index: 67, positiveHighlights: [], negativeHighlights : [3, 5]), PossibleHighlights(index: 76, positiveHighlights: [], negativeHighlights : [3, 5])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 4))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 8, positiveHighlights: [1, 2, 6], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [1, 2, 6], negativeHighlights : []), PossibleHighlights(index: 26, positiveHighlights: [1, 2, 6], negativeHighlights : []), PossibleHighlights(index: 53, positiveHighlights: [], negativeHighlights : [1]), PossibleHighlights(index: 71, positiveHighlights: [], negativeHighlights : [2, 1, 6]), PossibleHighlights(index: 80, positiveHighlights: [], negativeHighlights : [1, 6])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 8))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 8, positiveHighlights: [6, 2], negativeHighlights : []), PossibleHighlights(index: 26, positiveHighlights: [6, 2], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [], negativeHighlights : [2]), PossibleHighlights(index: 71, positiveHighlights: [], negativeHighlights : [6, 2]), PossibleHighlights(index: 80, positiveHighlights: [], negativeHighlights : [6])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 8))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 8, positiveHighlights: [6, 2, 1], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [6, 2, 1], negativeHighlights : []), PossibleHighlights(index: 26, positiveHighlights: [6, 2, 1], negativeHighlights : []), PossibleHighlights(index: 7, positiveHighlights: [], negativeHighlights : [2]), PossibleHighlights(index: 16, positiveHighlights: [], negativeHighlights : [2, 1])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 2))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 8, positiveHighlights: [2, 6], negativeHighlights : []), PossibleHighlights(index: 26, positiveHighlights: [2, 6], negativeHighlights : []), PossibleHighlights(index: 7, positiveHighlights: [], negativeHighlights : [2]), PossibleHighlights(index: 16, positiveHighlights: [], negativeHighlights : [2]), PossibleHighlights(index: 17, positiveHighlights: [], negativeHighlights : [2])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 2))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 40, positiveHighlights: [5, 3], negativeHighlights : []), PossibleHighlights(index: 41, positiveHighlights: [5, 3], negativeHighlights : []), PossibleHighlights(index: 30, positiveHighlights: [], negativeHighlights : [3]), PossibleHighlights(index: 32, positiveHighlights: [], negativeHighlights : [3]), PossibleHighlights(index: 48, positiveHighlights: [], negativeHighlights : [3]), PossibleHighlights(index: 50, positiveHighlights: [], negativeHighlights : [3])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 4))], answer: nil) )
        
        for e in expected1{
            if !naked.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
       

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
        let naked2 = puzzle2.nakedSets(possibles: puzzle2.possibleValueMatrix)

        var expected : [Hint] = []
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 11, positiveHighlights: [4, 8], negativeHighlights : []), PossibleHighlights(index: 20, positiveHighlights: [4, 8], negativeHighlights : []), PossibleHighlights(index: 29, positiveHighlights: [], negativeHighlights : [4]), PossibleHighlights(index: 74, positiveHighlights: [], negativeHighlights : [8])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 2))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 11, positiveHighlights: [4, 8, 7], negativeHighlights : []), PossibleHighlights(index: 20, positiveHighlights: [4, 8, 7], negativeHighlights : []), PossibleHighlights(index: 29, positiveHighlights: [4, 8, 7], negativeHighlights : []), PossibleHighlights(index: 65, positiveHighlights: [], negativeHighlights : [7]), PossibleHighlights(index: 74, positiveHighlights: [], negativeHighlights : [8])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 2))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 12, positiveHighlights: [9, 8, 2], negativeHighlights : []), PossibleHighlights(index: 21, positiveHighlights: [9, 8, 2], negativeHighlights : []), PossibleHighlights(index: 30, positiveHighlights: [9, 8, 2], negativeHighlights : []), PossibleHighlights(index: 57, positiveHighlights: [], negativeHighlights : [8, 2, 9]), PossibleHighlights(index: 75, positiveHighlights: [], negativeHighlights : [8, 9])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 3))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 11, positiveHighlights: [4, 8], negativeHighlights : []), PossibleHighlights(index: 20, positiveHighlights: [4, 8], negativeHighlights : []), PossibleHighlights(index: 1, positiveHighlights: [], negativeHighlights : [8, 4]), PossibleHighlights(index: 10, positiveHighlights: [], negativeHighlights : [8, 4]), PossibleHighlights(index: 19, positiveHighlights: [], negativeHighlights : [8, 4])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 0))], answer: nil) )
        
        for e in expected{
            if !naked2.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
    }
    func testNakedPair(){
        let p = SudokuPuzzle.from(base64hash: "AAAEgAAGagBgEQAlcBQAwmgAAkA4AAAA+agtgEQAxMFwArk0zoAAAKAiIqbXuEViZqMAAAAACA==")

        //let rated = p.nakedSets(possibles: p.possibleValueMatrix)
        do{
            let rated = try p.internalRate()
            XCTAssert(!Set(rated.2.possibleValuesMatrix[5] ?? []).contains(4) )
            XCTAssert(!Set(rated.2.possibleValuesMatrix[14] ?? []).contains(4) )
        }catch{
            XCTFail()
        }
        
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
        let naked = puzzle.nakedSets(possibles: puzzle.possibleValueMatrix)
        var expected : [Hint] = []
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 2, positiveHighlights: [8, 6, 7], negativeHighlights : []), PossibleHighlights(index: 11, positiveHighlights: [8, 6, 7], negativeHighlights : []), PossibleHighlights(index: 38, positiveHighlights: [8, 6, 7], negativeHighlights : []), PossibleHighlights(index: 20, positiveHighlights: [], negativeHighlights : [7, 8, 6]), PossibleHighlights(index: 56, positiveHighlights: [], negativeHighlights : [7, 8]), PossibleHighlights(index: 65, positiveHighlights: [], negativeHighlights : [7, 8]), PossibleHighlights(index: 74, positiveHighlights: [], negativeHighlights : [7, 8])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 2))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 6, positiveHighlights: [9, 7], negativeHighlights : []), PossibleHighlights(index: 24, positiveHighlights: [9, 7], negativeHighlights : []), PossibleHighlights(index: 69, positiveHighlights: [], negativeHighlights : [7]), PossibleHighlights(index: 78, positiveHighlights: [], negativeHighlights : [7])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.column, houseIndex: 6))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 2, positiveHighlights: [6, 7, 8], negativeHighlights : []), PossibleHighlights(index: 11, positiveHighlights: [6, 7, 8], negativeHighlights : []), PossibleHighlights(index: 18, positiveHighlights: [6, 7, 8], negativeHighlights : []), PossibleHighlights(index: 19, positiveHighlights: [], negativeHighlights : [6, 7]), PossibleHighlights(index: 20, positiveHighlights: [], negativeHighlights : [6, 8, 7])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 0))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 6, positiveHighlights: [9, 7], negativeHighlights : []), PossibleHighlights(index: 24, positiveHighlights: [9, 7], negativeHighlights : []), PossibleHighlights(index: 7, positiveHighlights: [], negativeHighlights : [7]), PossibleHighlights(index: 25, positiveHighlights: [], negativeHighlights : [7])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 2))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 61, positiveHighlights: [6, 5, 7, 8], negativeHighlights : []), PossibleHighlights(index: 62, positiveHighlights: [6, 5, 7, 8], negativeHighlights : []), PossibleHighlights(index: 70, positiveHighlights: [6, 5, 7, 8], negativeHighlights : []), PossibleHighlights(index: 80, positiveHighlights: [6, 5, 7, 8], negativeHighlights : []), PossibleHighlights(index: 69, positiveHighlights: [], negativeHighlights : [7]), PossibleHighlights(index: 78, positiveHighlights: [], negativeHighlights : [7])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 8))], answer: nil) )
        for e in expected{
            if !naked.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
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
        let naked2 = puzzle2.nakedSets(possibles: puzzle2.possibleValueMatrix)
        var expected1 : [Hint] = []
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 18, positiveHighlights: [4, 9, 7], negativeHighlights : []), PossibleHighlights(index: 20, positiveHighlights: [4, 9, 7], negativeHighlights : []), PossibleHighlights(index: 22, positiveHighlights: [4, 9, 7], negativeHighlights : []), PossibleHighlights(index: 23, positiveHighlights: [], negativeHighlights : [7, 9, 4]), PossibleHighlights(index: 25, positiveHighlights: [], negativeHighlights : [9, 4])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 2))], answer: nil) )
        expected1.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 73, positiveHighlights: [2, 7, 9], negativeHighlights : []), PossibleHighlights(index: 75, positiveHighlights: [2, 7, 9], negativeHighlights : []), PossibleHighlights(index: 76, positiveHighlights: [2, 7, 9], negativeHighlights : []), PossibleHighlights(index: 72, positiveHighlights: [], negativeHighlights : [7, 9]), PossibleHighlights(index: 79, positiveHighlights: [], negativeHighlights : [7, 9])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 8))], answer: nil) )
        for e in expected1{
            if !naked2.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
        
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
        let naked = puzzle.nakedSets(possibles: puzzle.possibleValueMatrix)
        var expected : [Hint] = []
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 9, positiveHighlights: [9, 4, 3, 2], negativeHighlights : []), PossibleHighlights(index: 12, positiveHighlights: [9, 4, 3, 2], negativeHighlights : []), PossibleHighlights(index: 13, positiveHighlights: [9, 4, 3, 2], negativeHighlights : []), PossibleHighlights(index: 14, positiveHighlights: [9, 4, 3, 2], negativeHighlights : []), PossibleHighlights(index: 11, positiveHighlights: [], negativeHighlights : [2, 9, 4, 3]), PossibleHighlights(index: 15, positiveHighlights: [], negativeHighlights : [4]), PossibleHighlights(index: 17, positiveHighlights: [], negativeHighlights : [2])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 1))], answer: nil) )
        expected.append( Hint(type: .nakedSet, possiblesHighlights: [PossibleHighlights(index: 6, positiveHighlights: [2, 1, 6, 4], negativeHighlights : []), PossibleHighlights(index: 7, positiveHighlights: [2, 1, 6, 4], negativeHighlights : []), PossibleHighlights(index: 24, positiveHighlights: [2, 1, 6, 4], negativeHighlights : []), PossibleHighlights(index: 25, positiveHighlights: [2, 1, 6, 4], negativeHighlights : []), PossibleHighlights(index: 15, positiveHighlights: [], negativeHighlights : [4, 6]), PossibleHighlights(index: 17, positiveHighlights: [], negativeHighlights : [2])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 2))], answer: nil) )
        for e in expected{
            if !naked.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
        
        
    }
    func testLockedCandidate(){
        //Good example AAAIgACYAAmAAAUuAAAYAAAK4AAAAABG4AApkAAZAAFQAAAEZgACQAVBTNgRnQAMAAAAAAAAAA==  //group 3 locks the 4s out of colomn 0 in group 0, so index 0 can remove its possible 4
        
        //https://www.sudocue.net/guide.php
        
//        let d = "000023000004000100050084090001070902093006000000010760000000000800000004060000587"
//        var s = "let data = [\n"
//        for (i,c) in d.enumerated(){
//            if(i != 0 && i % 9 == 0){ s.append("\n")}
//            s.append(i == 80 ? " \(c) " :  " \(c) ," )
//
//        }
//        s.append("\n]")
//        print(s)
        
        let data = [
         0 , 0 , 0 , 0 , 2 , 3 , 4 , 0 , 0 ,
         0 , 0 , 4 , 0 , 0 , 0 , 1 , 0 , 0 ,
         0 , 5 , 0 , 0 , 8 , 4 , 0 , 9 , 0 ,
         6 , 0 , 1 , 0 , 7 , 0 , 9 , 0 , 2 ,
         7 , 9 , 3 , 2 , 0 , 6 , 8 , 0 , 1 ,
         0 , 0 , 0 , 0 , 1 , 0 , 7 , 6 , 0 ,
         0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 9 ,
         8 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 4 ,
         0 , 6 , 0 , 0 , 0 , 0 , 5 , 8 , 7
        ]
        let puzzle = SudokuPuzzle(data: data)
        let solved = try? puzzle.solvedCopy()
        let locked = puzzle.lockedCandidate(possibles: puzzle.possibleValueMatrix)
        var expected : [Hint] = []
        expected.append( Hint(type: .lockedCandidate, possiblesHighlights: [PossibleHighlights(index: 3, positiveHighlights: [1], negativeHighlights : []), PossibleHighlights(index: 21, positiveHighlights: [1], negativeHighlights : []), PossibleHighlights(index: 57, positiveHighlights: [], negativeHighlights : [1]), PossibleHighlights(index: 66, positiveHighlights: [], negativeHighlights : [1]), PossibleHighlights(index: 75, positiveHighlights: [], negativeHighlights : [1])], highlights: [HighlightType.house(House(type: .group, houseIndex: 1)), HighlightType.house(House(type: .column, houseIndex: 3))], answer: nil) )
        expected.append( Hint(type: .lockedCandidate, possiblesHighlights: [PossibleHighlights(index: 45, positiveHighlights: [5], negativeHighlights : []), PossibleHighlights(index: 47, positiveHighlights: [5], negativeHighlights : []), PossibleHighlights(index: 48, positiveHighlights: [], negativeHighlights : [5]), PossibleHighlights(index: 50, positiveHighlights: [], negativeHighlights : [5]), PossibleHighlights(index: 53, positiveHighlights: [], negativeHighlights : [5])], highlights: [HighlightType.house(House(type: .group, houseIndex: 3)), HighlightType.house(House(type: .row, houseIndex: 5))], answer: nil) )
        expected.append( Hint(type: .lockedCandidate, possiblesHighlights: [PossibleHighlights(index: 30, positiveHighlights: [3], negativeHighlights : []), PossibleHighlights(index: 48, positiveHighlights: [3], negativeHighlights : []), PossibleHighlights(index: 57, positiveHighlights: [], negativeHighlights : [3]), PossibleHighlights(index: 66, positiveHighlights: [], negativeHighlights : [3]), PossibleHighlights(index: 75, positiveHighlights: [], negativeHighlights : [3])], highlights: [HighlightType.house(House(type: .group, houseIndex: 4)), HighlightType.house(House(type: .column, houseIndex: 3))], answer: nil) )
        expected.append( Hint(type: .lockedCandidate, possiblesHighlights: [PossibleHighlights(index: 60, positiveHighlights: [6], negativeHighlights : []), PossibleHighlights(index: 69, positiveHighlights: [6], negativeHighlights : []), PossibleHighlights(index: 24, positiveHighlights: [], negativeHighlights : [6])], highlights: [HighlightType.house(House(type: .group, houseIndex: 8)), HighlightType.house(House(type: .column, houseIndex: 6))], answer: nil) )
       
        for e in expected{
            if !locked.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
        }
        let rated = try? puzzle.internalRate()
        XCTAssert(solved!.data == rated!.2.currentPuzzle.data)
        
        
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
        let hidden = puzzle.hiddenSets(possibles: puzzle.possibleValueMatrix)
        var expected : [Hint] = []
        expected.append( Hint(type: .hiddenSet, possiblesHighlights: [PossibleHighlights(index: 15, positiveHighlights: [7, 8], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [7, 8], negativeHighlights : [])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 1))], answer: nil) )
        expected.append( Hint(type: .hiddenSet, possiblesHighlights: [PossibleHighlights(index: 11, positiveHighlights: [7, 8, 6], negativeHighlights : []), PossibleHighlights(index: 15, positiveHighlights: [7, 8, 6], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [7, 8, 6], negativeHighlights : [])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.row, houseIndex: 1))], answer: nil) )
        expected.append( Hint(type: .hiddenSet, possiblesHighlights: [PossibleHighlights(index: 15, positiveHighlights: [7, 8], negativeHighlights : []), PossibleHighlights(index: 17, positiveHighlights: [7, 8], negativeHighlights : [])], highlights: [HighlightType.house(House(type: SudukoUtility.HouseType.group, houseIndex: 2))], answer: nil) )
        for e in expected{
            if !hidden.contains(e){
                XCTFail("hint not found : \n \(e.debugDescription)")
            }
            
        }
        
    }
    func testXWing(){
        //https://www.sudocue.net/guide.php
  
        let data = [
         0 , 2 , 8 , 7 , 0 , 9 , 6 , 5 , 0 ,
         7 , 5 , 4 , 0 , 0 , 3 , 9 , 8 , 0 ,
         0 , 6 , 9 , 0 , 0 , 0 , 0 , 0 , 7 ,
         0 , 3 , 1 , 0 , 9 , 7 , 0 , 6 , 0 ,
         0 , 7 , 6 , 3 , 0 , 0 , 0 , 9 , 0 ,
         0 , 9 , 5 , 0 , 0 , 4 , 3 , 7 , 0 ,
         9 , 1 , 7 , 4 , 5 , 6 , 0 , 0 , 0 ,
         5 , 4 , 2 , 9 , 3 , 8 , 7 , 1 , 6 ,
         6 , 8 , 3 , 1 , 7 , 2 , 5 , 4 , 9
        ]
        let puzzle = SudokuPuzzle(data: data)
        let xwing = puzzle.xwing(possibles: puzzle.possibleValueMatrix)
        let sets = [Set(arrayLiteral: 49,13),Set(arrayLiteral: 53,17), Set(arrayLiteral: 23,24),Set(arrayLiteral: 41,42)]
//        let _ = sets.map{ XCTAssert(xwing.map{$0.indices}.contains($0))}
//        let _ = xwing.filter{ sets.contains($0.indices)}.map { (hint) -> Void in
//            XCTAssert(hint.values.count == 1)
//            XCTAssert(hint.values.contains(1) || hint.values.contains(6))
//        }
        XCTFail("Need to implement a test")
        
    }
    
    
    

    
    /*
     This is a 27 given puzzle which will need hidden sets:
     BEAAAqDIAABG4JgnQAMgAC1gAACIAXiAAL5AAAAAlUAAAyAAAABKgMUACQIgACYAABkAAAAAAA==
     */
    func testHiddenTriple(){
        //605301204703000509000000000100936007000000000900457001000000000807000402309108706
        
        let data = [
         6 , 0 , 5 , 3 , 0 , 1 , 2 , 0 , 4 ,
         7 , 0 , 3 , 0 , 0 , 0 , 5 , 0 , 9 ,
         0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
         1 , 0 , 0 , 9 , 3 , 6 , 0 , 0 , 7 ,
         0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
         9 , 0 , 0 , 4 , 5 , 7 , 0 , 0 , 1 ,
         0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,
         8 , 0 , 7 , 0 , 0 , 0 , 4 , 0 , 2 ,
         3 , 0 , 9 , 1 , 0 , 8 , 7 , 0 , 6
        ]
        let puzzle = SudokuPuzzle(data: data)
        let solved = try? puzzle.solvedCopy()
        let rated = try? puzzle.internalRate()
        let typesUsed = rated?.2.solveLog.map{$0.type}
        if let types = typesUsed{
            if(solved!.data == rated!.2.currentPuzzle.data){
                print("solved -- \(types)")
            }else{
                print("fail -- \(types)")
            }
        }
        
        
    }
    func testRateScore(){
        var data : [(SudokuPuzzle,Int,Int,Bool,String)] = []
        do {
            for _ in 0..<20{
                let puzzle = try SudokuPuzzle.creatPuzzle()
                let rated = try puzzle.internalRate()
                let solved = try puzzle.solvedCopy()
                let solvedata = rated.2
                let solvable = solvedata.currentPuzzle.data == solved.data
                let typesUsed = solvedata.solveLog.map{$0.type}
                let str = typesUsed.reduce("") { (theStr, hint) -> String in
                    var mutableStr = theStr
                    if mutableStr.count == 0{
                        mutableStr = hint.description
                    }else{
                        mutableStr = "\(mutableStr)|\(hint.description)"
                    }
                    return mutableStr
                }
                data.append((puzzle,rated.0,rated.1,solvable,str))
               
        }
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        print("data ---")
        print("givens,HintCount,score,solvable,types")
        for t in data{
            print("\(t.0.data.filter({$0 > 0}).count),\(t.1),\(t.2),\(t.3 ? 1 : 0),\(t.4)")
        }
    }
//    func testRate(){
//        do {
//            for _ in 0..<300{
//                let puzzle = try SudokuPuzzle.creatPuzzle()
//                let rated = try puzzle.rate()
//                print(rated)
//        }
//        } catch let e {
//            XCTFail(e.localizedDescription)
//        }
//    }
    
    func testHiddenSetsThatProduce(){
        let puzzles = [
            "ADF5AACMgAACoAYBMEcWyCQAABQEgABgAMgiC4AVwCIMgyAAAAoAAKAnEAAZACQKgAAAAAAAAA==",
            "AAAAAAAGagBgEQAlcAAAwCgAAkAAAAAAGagtgEQAxMFwArkEwAAAAKAiAALXuAFgZqAAAAAAAA==",  //<--this registers
            "ACYJZAAAAABQAIzjIAAAwAAJ1vEAAUACgAAsAEgABOlQAAAALgADAKgBgFMgBEAASBcAAAAAAA=="
            
            ]
        for hash in puzzles{
            let puzzle = SudokuPuzzle.from(base64hash: hash)
            let solved = try? puzzle.solvedCopy()
            let rated = try? puzzle.internalRate()
            
            let typesUsed = rated?.2.solveLog.map{$0.type}
            if let types = typesUsed{
                if(solved!.data == rated!.2.currentPuzzle.data){
                    print("solved -- \(types)")
                }else{
                    print("fail -- \(types)")
                }
            }
            
            //XCTAssert(solved!.data == rated!.data,"failed on \(puzzle.base64Hash)")
        }
        
        
    }
    
    func testHiddenSet(){
        let puzzles = [
            "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"
            ]
        for hash in puzzles{
            let puzzle = SudokuPuzzle.from(base64hash: hash)
            let solved = try? puzzle.solvedCopy()
            let rated = try? puzzle.internalRate()
            
            let typesUsed = rated?.2.solveLog.map{$0.type}
            if let types = typesUsed{
                if(solved!.data == rated!.2.currentPuzzle.data){
                    print("solved -- \(types)")
                }else{
                    print("fail -- \(types)")
                }
            }
            
            //XCTAssert(solved!.data == rated!.data,"failed on \(puzzle.base64Hash)")
        }
        
        
    }
}

