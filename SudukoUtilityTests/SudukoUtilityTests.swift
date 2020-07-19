//
//  SudukoUtilityTests.swift
//  SudukoUtilityTests
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import XCTest
@testable import SudukoUtility

class SudukoUtilityTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThat9SizeMatrixHas324ColumnsAndEachColumnHas9Nodes(){
//        let d = RawSudukoData(size: 9, data: [UInt8(1)])
//        let s = DancingLinks(data: d)
//        let matrixPointer = s.baseMatrix(size: 9)
//        var current = matrixPointer
//        var count = 0
//        repeat{
//            guard let next = current.right else{
//                XCTFail("nil pointer in list")
//                return
//            }
//            count += 1
//            current = next
//            guard let topNode = next.top else{
//                XCTFail("no tope node in column header")
//                return
//            }
//            var currentNode : Node? = topNode
//            var nodeCounter = 0
//            repeat{
//                nodeCounter += 1
//                currentNode = currentNode?.bottom
//                if(nodeCounter == 8){
//                    XCTAssert(currentNode?.bottom == topNode && topNode.top == currentNode, "non circular list")
//                }
//            }while(currentNode != nil && topNode != currentNode)
//            XCTAssert(nodeCounter == 9, "node counter off")
//        }while(current != matrixPointer)
//        XCTAssert(count == 324)
        
    }
    func rowHas(nNodes : Int, node : Node) -> Bool{
        var nodePtr : Node? = node
        var counter = 0
        repeat{
            if nodePtr?.left == nil || nodePtr?.right == nil{
                return false
            }
            nodePtr = nodePtr?.left
            counter += 1
        }while(node != nodePtr)
        return counter == nNodes
    }
    func testThatThereAre729Rows(){
        //make 729 Coordinates in 729*4 nodes in a set and remove, then see if set is empty
//        var set = Set<Node>()
//        for type in ColumnNodeType.allCases{
//
//            for _ in ColumnNodeType.allCases.enumerated(){
//                for i in 0..<9{  //rows
//                    for j in 0..<9{
//                        let tmpCol = ColumnNode(type: type, row: UInt8(i), column: UInt8(j))
//                        for l in 0..<9{
//                            let node = Node()
//                            var c :  Coordinate
//                            switch type {
//                            case .cellConstraint:
//                                c = Coordinate(row: UInt8(i), column: UInt8(j))
//                            case .rowConstraint:
//                                c = Coordinate(row: UInt8(i), column: UInt8(l))
//                            case .columnConstraint:
//                                c = Coordinate(row: UInt8(j), column: UInt8(l))
//                            case .groupConstaint:
//                                c = Coordinate(row: groupFromIndex(index: Coordinate(row: UInt8(i), column: UInt8(j)).index), column: UInt8(l))
//                            }
//                            c.value =  UInt8(l)
//                            node.coordinate = c
//                            node.header = tmpCol
//                            node.type = type
//                            set.insert(node)
//                        }
//
//                    }
//                }
//            }
//
//        }
//        XCTAssertTrue(set.count == 2916, "Invalid test setup")
//
//        let d = RawSudukoData(size: 9, data: [UInt8(1)])
//        let s = DancingLinks(data: d)
//        let matrixPointer = s.baseMatrix(size: 9)
//        var counter = 0
//        var current = matrixPointer
//        // header loop
//        repeat{
//            guard let next = current.right else{
//                XCTFail("nil pointer in list")
//                return
//            }
//            guard let topNode = current.top else{
//                XCTFail("Top Node Empty")
//                return
//            }
//            //Node loop
//            var nextNode = topNode
//           repeat{
//
//                //remove from set
//                counter += 1
//                if set.contains(nextNode){
//                    set.remove(nextNode)
//                }else{
//                    XCTFail("trying to remove a node from the set that is not in the set")
//                }
//                guard let n = nextNode.bottom else{
//                               XCTFail("nil pointer in list")
//                               return
//                }
//                nextNode = n
//                XCTAssert(rowHas(nNodes: 4, node: nextNode))
//            } while(nextNode != topNode)
//            current = next // for outer loop
//        }while(current != matrixPointer)
//
//        XCTAssertTrue(set.count == 0, "count = \(set.count) Missing rows ?!")
//
//
    }
   func testThatEveryHeaderHasATopElementAndItHas9Nodes(){
//        let d = RawSudukoData(size: 9, data: [UInt8(1)])
//        let s = DancingLinks(data: d)
//        let matrixPointer = s.baseMatrix(size: 9)
//        var current = matrixPointer
//        // header loop
//        repeat{
//            guard let next = current.right else{
//                XCTFail("nil pointer in list")
//                return
//            }
//            guard let topNode = current.top else{
//                XCTFail("Top Node Empty")
//                return
//            }
//            //Node loop
//            var count = 0
//            var nextNode = topNode
//            repeat{
//                guard let n = nextNode.bottom else{
//                   XCTFail("nil pointer in list")
//                   return
//                }
//                nextNode = n
//                count += 1
//
//            }while(nextNode != topNode)
//            XCTAssert(count == 9, "Count is off")
//            current = next // for outer loop
//        }while(current != matrixPointer)
        
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
        XCTAssert(callCount == 3, "Callback count off")
        XCTAssert(s.solutionSet.count == 0,"Too many solutions found")
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
