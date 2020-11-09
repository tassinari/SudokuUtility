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
        XCTAssert(naked.answers == [73 : 1, 1 : 3, 44 : 9])
        
        let puzzle2 = SudokuPuzzle.from(base64hash: "AC4AAAAEwABUAAAqAAAApa8QVACdgYAAALgACWAAtQAIzBUAI0ADIKTBi8QWACIM2nIAAAAAAA==")
        
        let naked2 = puzzle2.nakedSingles(possibles: puzzle2.possibleValueMatrix)
        print(puzzle2.description)
        XCTAssert(naked2.answers == [31:2,75:5,17:1,70:5,72:7])
        
        
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
        XCTAssert(hidden.answers == [1 : 3, 62 : 3, 71 : 7])
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
        let naked2 = puzzle2.nakedSets(possibles: puzzle2.possibleValueMatrix)
        let sets2 = [Set(arrayLiteral: 11,20),Set(arrayLiteral: 30,32)]
        XCTAssert(naked2.count == 6)
        let _ = sets2.map{ XCTAssert(naked2.map{$0.indices}.contains($0))}
        
    }
    func testNakedPair(){
        let p = SudokuPuzzle.from(base64hash: "AAAEgAAGagBgEQAlcBQAwmgAAkA4AAAA+agtgEQAxMFwArk0zoAAAKAiIqbXuEViZqMAAAAACA==")

        //let rated = p.nakedSets(possibles: p.possibleValueMatrix)
        do{
            let rated = try p.rate()
            XCTAssert(!Set(rated.possibleValuesMatrix[5] ?? []).contains(4) )
            XCTAssert(!Set(rated.possibleValuesMatrix[14] ?? []).contains(4) )
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
        let naked2 = puzzle2.nakedSets(possibles: puzzle2.possibleValueMatrix)
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
        let naked = puzzle.nakedSets(possibles: puzzle.possibleValueMatrix)
        
        let _ = sets.map{ XCTAssert(naked.map{$0.indices}.contains($0))}
        
        
    }
    func testLockedCandidate(){
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
        let sets = [Set(arrayLiteral: 3,21)]
        let _ = sets.map{ XCTAssert(locked.map{$0.indices}.contains($0))}
        let rated = try? puzzle.rate()
        if(solved!.data == rated!.currentPuzzle.data){
            print("solved ")
        }
        XCTAssert(solved!.data == rated!.currentPuzzle.data)
        
        
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
        let sets = [Set(arrayLiteral: 15,17),Set(arrayLiteral: 11,15,17)]
        let _ = sets.map{ XCTAssert(hidden.map{$0.indices}.contains($0))}
        
        
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
        let _ = sets.map{ XCTAssert(xwing.map{$0.indices}.contains($0))}
        let _ = xwing.filter{ sets.contains($0.indices)}.map { (hint) -> Void in
            XCTAssert(hint.values.count == 1)
            XCTAssert(hint.values.contains(1) || hint.values.contains(6))
        }
        
        
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
        let rated = try? puzzle.rate()
        let typesUsed = rated?.solveLog.reduce(Set<HintType>(), { (hintSet, hintResult) -> Set<HintType> in
            var set = hintSet
            switch hintResult{
            case .answers( let answer):
                set.insert(answer.type)
               
            case .possibles(let p):
                set.insert(p.type)
            }
            return set
        })
        if let types = typesUsed{
            if(solved!.data == rated!.currentPuzzle.data){
                print("solved -- \(types)")
            }else{
                print("fail -- \(types)")
            }
        }
        
        
    }
    func testRate(){
        do {
            for _ in 0..<300{
                let puzzle = try SudokuPuzzle.creatPuzzle()
                let solved = try puzzle.solvedCopy()
                let rated = try puzzle.rate()
                let typesUsed = rated.solveLog.reduce(Set<HintType>(), { (hintSet, hintResult) -> Set<HintType> in
                    var set = hintSet
                    switch hintResult{
                    case .answers( let answer):
                        set.insert(answer.type)
                       
                    case .possibles(let p):
                        set.insert(p.type)
                    }
                    return set
                })
               
                if(solved.data == rated.currentPuzzle.data){
                    print("solved (\(puzzle.givens.count)) -- \(typesUsed) -- \(puzzle.base64Hash)")
                    XCTAssert(solved.data == rated.currentPuzzle.data,"failed on \(puzzle.base64Hash)")
                }else{
                    print("fail")
                    print("\(puzzle.base64Hash) , \(typesUsed), \(puzzle.givens.count), \(rated.currentPuzzle.data.filter({$0 > 0}).count) ")
                }
            
                
        }
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
    
    func testHiddenSetsThatProduce(){
        let puzzles = [
            "ADF5AACMgAACoAYBMEcWyCQAABQEgABgAMgiC4AVwCIMgyAAAAoAAKAnEAAZACQKgAAAAAAAAA==",
            "AAAAAAAGagBgEQAlcAAAwCgAAkAAAAAAGagtgEQAxMFwArkEwAAAAKAiAALXuAFgZqAAAAAAAA==",  //<--this registers
            "ACYJZAAAAABQAIzjIAAAwAAJ1vEAAUACgAAsAEgABOlQAAAALgADAKgBgFMgBEAASBcAAAAAAA=="
            
            ]
        for hash in puzzles{
            let puzzle = SudokuPuzzle.from(base64hash: hash)
            let solved = try? puzzle.solvedCopy()
            let rated = try? puzzle.rate()
            
            let typesUsed = rated?.solveLog.reduce(Set<HintType>(), { (hintSet, hintResult) -> Set<HintType> in
                var set = hintSet
                switch hintResult{
                case .answers( let answer):
                    set.insert(answer.type)
                   
                case .possibles(let p):
                    set.insert(p.type)
                }
                return set
            })
            if let types = typesUsed{
                if(solved!.data == rated!.currentPuzzle.data){
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
            let rated = try? puzzle.rate()
            
            let typesUsed = rated?.solveLog.reduce(Set<HintType>(), { (hintSet, hintResult) -> Set<HintType> in
                var set = hintSet
                switch hintResult{
                case .answers( let answer):
                    set.insert(answer.type)
                   
                case .possibles(let p):
                    set.insert(p.type)
                }
                return set
            })
            if let types = typesUsed{
                if(solved!.data == rated!.currentPuzzle.data){
                    print("solved -- \(types)")
                }else{
                    print("fail -- \(types)")
                }
            }
            
            //XCTAssert(solved!.data == rated!.data,"failed on \(puzzle.base64Hash)")
        }
        
        
    }
}

