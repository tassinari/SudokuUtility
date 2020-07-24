//
//  DancingLinksTests.swift
//  SudukoUtilityTests
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import XCTest
@testable import SudukoUtility

class DancingLinksTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

 
    
    func testSanityAfterSolve(){
        func colHeadCount(head : DLXNode) -> [[DLXNode.Coordinate]]{
            var c : [[DLXNode.Coordinate]] = []
            var n : DLXNode = head.right
            while(n != head){
                var node = n.top
                var coords : [DLXNode.Coordinate] = []
                repeat{
                    coords.append(node!.coordinate)
                    node = node?.bottom
                }while(node != n.top)
                c.append(coords)
                n = n.right
            }
            return c
        }
        let a =  [
            0,1,1,0,1,1,0,
            1,0,0,1,0,0,1,
            0,1,1,0,0,1,0,
            0,0,0,1,0,1,0,
            1,1,0,0,0,1,1,
            0,0,1,1,1,0,0,
            0,0,0,0,1,0,0
        ]
        let s = DancingLinks(from: a, size: 7)
        let countBefore = colHeadCount(head: s.root)
        var callCount = 0
        try? s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
            callCount += 1
            return false
        })
        XCTAssert(callCount == 3, "Solution block called more than expected")
        let countAfter = colHeadCount(head: s.root)
        XCTAssert(countBefore == countAfter)
        
        
        
    }
    func testStopCallBackStopsOnMultipleSolutionMatrix(){
        let a =  [
            0,1,1,0,1,1,0,
            1,0,0,1,0,0,1,
            0,1,1,0,0,1,0,
            0,0,0,1,0,1,0,
            1,1,0,0,0,1,1,
            0,0,1,1,1,0,0,
            0,0,0,0,1,0,0
        ]
        let s = DancingLinks(from: a, size: 7)
        var callCount = 0
        try? s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
            callCount += 1
            return true
        })
        XCTAssert(callCount == 1, "Callback count off")
        XCTAssert(s.solutionSet.count == 1,"Too many solutions found")
    }
    func testThrowsOnTooManyRecursions(){
        let a =  [
            0,1,1,0,1,1,0,
            0,1,1,0,1,1,0,
            0,1,1,0,0,1,0,
            1,0,0,1,1,0,1
            
        ]
        var errorThrown = false
        let s = DancingLinks(from: a, size: 7)
        s.maxRecursionDepth = 1
        do {
            try s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
                return false
            })
            
        } catch let error {
            guard let e = error as? DancingLinksError else{
                XCTFail("Wrong error thrown")
                return
            }
            errorThrown = e.type == .maxRecursionDepthBreached
        }
        XCTAssert(errorThrown, "Error not thrown or was wrong")
       
    }
    func testSolveNoSolution(){
        
        let testData  = [
                   
                   1,0,1,0,1,0,0,
                   1,0,0,1,0,0,1,
                   1,1,1,0,0,1,0,
                   1,0,0,1,0,1,0,
                   1,1,0,0,0,0,1,
                   1,0,0,1,1,0,1
             ]
        
        let s = DancingLinks(from: testData, size: 7)
        do {
            try s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
                return false
            })
            XCTAssertEqual([], s.solutionSet)
        } catch _ {
            XCTFail("Cannot setup test data")
        }
       
    }

    func testSolve(){
       
    
        //304
        let testData  = [
            [   "data" : [
            0,0,1,0,1,0,0,
            1,0,0,1,0,0,1,
            0,1,1,0,0,1,0,
            1,0,0,1,0,1,0,
            0,1,0,0,0,0,1,
            0,0,0,1,1,0,1
        ],
                    "solution" : [[3,0,4]]
        ]
////        //5043
        ,
            [   "data" : [
            1,0,1,0,1,0,0,
            0,0,0,0,0,0,1,
            1,1,1,0,0,1,0,
            0,0,0,1,1,0,0,
            0,0,0,0,0,1,0,
            0,1,0,1,0,0,0
        ],
                    "solution" : [ [0,4,5,1], [1,2,3]]
        ]
//        //235
        ,  [   "data" : [
            0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,
            1,1,1,0,0,1,0,
            0,0,0,0,0,0,1,
            0,0,0,0,0,1,0,
            0,0,0,1,1,0,0
        ],
                    "solution" : [[2,3,5]]
        ]
//        //01 && 253
        ,  [   "data" : [
            1,1,1,0,1,1,1,
            0,0,0,1,0,0,0,
            1,1,1,0,0,1,0,
            0,0,0,0,0,0,1,
            0,0,0,0,0,1,0,
            0,0,0,1,1,0,0
        ],
               "solution" : [ [0,1],[2,5,3]]
        ]
        ,  [   "data" : [
            1,1,1,0,1,1,1,
            0,0,0,0,0,0,0,
            1,1,1,0,0,1,0,
            0,0,0,1,1,0,1,
            0,0,0,0,0,1,0,
            0,0,0,1,0,0,0
        ],
               "solution" : [[2,3],[0,5]]
        ]
        ]
        for item in testData{
           
            guard let matrix = item["data"] as? [Int], let expectedSolutionSetArray = item["solution"] as? [[Int]] else {
                XCTFail("Unable to produce test data")
                return
            }
            
             let s = DancingLinks(from: matrix, size: 7)
            //  s.debugPrintMatrix(headPtr: headerPtr)
            try? s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
                return false
            })
                
            //XCTAssertEqual(s.solutionSet.map{Int($0.coordinate.row)}.sorted(), expectedSolutionSetArray.sorted())
            let sortedAnswers = s.solutionSet.map { (nodeArray) -> [Int] in
                return nodeArray.map{Int($0.coordinate.row)}.sorted()
            }
            XCTAssertEqual(Set(sortedAnswers), Set(expectedSolutionSetArray.map{$0.sorted()}))
            
           // XCTAssertEqual(solution.map{Int($0.coordinate.row)}.sorted(), expected.sorted())
           // print("solution set : \(s.solutionSet)")
        
        }
      

        
        
        
    }

    func testPerformanceOfSolve() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let a =  [
                0,1,1,0,1,1,0,
                1,0,0,1,0,0,1,
                0,1,1,0,0,1,0,
                0,0,0,1,0,1,0,
                1,1,0,0,0,1,1,
                0,0,1,1,1,0,0,
                0,0,0,0,1,0,0
            ]
            let s = DancingLinks(from: a, size: 7)
            try? s.solve(random: true, stopBlock: { (solutionSet) -> Bool in
                return false
            })
        }
    }

    
}
