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
        let d = RawSudukoData(size: 9, data: [UInt8(1)])
        let s = DancingLinks(data: d)
        let matrixPointer = s.baseMatrix(size: 9)
        var current = matrixPointer
        var count = 0
        repeat{
            guard let next = current.right else{
                XCTFail("nil pointer in list")
                return
            }
            count += 1
            current = next
            guard let topNode = next.top else{
                XCTFail("no tope node in column header")
                return
            }
            var currentNode : Node? = topNode
            var nodeCounter = 0
            repeat{
                nodeCounter += 1
                currentNode = currentNode?.bottom
                if(nodeCounter == 8){
                    XCTAssert(currentNode?.bottom == topNode && topNode.top == currentNode, "non circular list")
                }
            }while(currentNode != nil && topNode != currentNode)
            XCTAssert(nodeCounter == 9, "node counter off")
        }while(current != matrixPointer)
        XCTAssert(count == 324)
        
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
        var set = Set<Node>()
        for type in ColumnNodeType.allCases{
           
            for _ in ColumnNodeType.allCases.enumerated(){
                for i in 0..<9{  //rows
                    for j in 0..<9{
                        let tmpCol = ColumnNode(type: type, row: UInt8(i), column: UInt8(j))
                        for l in 0..<9{
                            let node = Node()
                            var c :  Coordinate
                            switch type {
                            case .cellConstraint:
                                c = Coordinate(row: UInt8(i), column: UInt8(j))
                            case .rowConstraint:
                                c = Coordinate(row: UInt8(i), column: UInt8(l))
                            case .columnConstraint:
                                c = Coordinate(row: UInt8(j), column: UInt8(l))
                            case .groupConstaint:
                                c = Coordinate(row: groupFromIndex(index: Coordinate(row: UInt8(i), column: UInt8(j)).index), column: UInt8(l))
                            }
                            c.value =  UInt8(l)
                            node.coordinate = c
                            node.header = tmpCol
                            node.type = type
                            set.insert(node)
                        }
                        
                    }
                }
            }
            
        }
        XCTAssertTrue(set.count == 2916, "Invalid test setup")
        
        let d = RawSudukoData(size: 9, data: [UInt8(1)])
        let s = DancingLinks(data: d)
        let matrixPointer = s.baseMatrix(size: 9)
        var counter = 0
        var current = matrixPointer
        // header loop
        repeat{
            guard let next = current.right else{
                XCTFail("nil pointer in list")
                return
            }
            guard let topNode = current.top else{
                XCTFail("Top Node Empty")
                return
            }
            //Node loop
            var nextNode = topNode
           repeat{
                
                //remove from set
                counter += 1
                if set.contains(nextNode){
                    set.remove(nextNode)
                }else{
                    XCTFail("trying to remove a node from the set that is not in the set")
                }
                guard let n = nextNode.bottom else{
                               XCTFail("nil pointer in list")
                               return
                }
                nextNode = n
                XCTAssert(rowHas(nNodes: 4, node: nextNode))
            } while(nextNode != topNode)
            current = next // for outer loop
        }while(current != matrixPointer)
        
        XCTAssertTrue(set.count == 0, "count = \(set.count) Missing rows ?!")
        
        
    }
    func testThatEveryHeaderHasATopElementAndItHas9Nodes(){
        let d = RawSudukoData(size: 9, data: [UInt8(1)])
        let s = DancingLinks(data: d)
        let matrixPointer = s.baseMatrix(size: 9)
        var current = matrixPointer
        // header loop
        repeat{
            guard let next = current.right else{
                XCTFail("nil pointer in list")
                return
            }
            guard let topNode = current.top else{
                XCTFail("Top Node Empty")
                return
            }
            //Node loop
            var count = 0
            var nextNode = topNode
            repeat{
                guard let n = nextNode.bottom else{
                   XCTFail("nil pointer in list")
                   return
                }
                nextNode = n
                count += 1
                
            }while(nextNode != topNode)
            XCTAssert(count == 9, "Count is off")
            current = next // for outer loop
        }while(current != matrixPointer)
        
    }
    
    func testSolve(){
        let d = RawSudukoData(size: 9, data: [UInt8(1)])
        let s = DancingLinks(data: d)
      
        try? s.solve()
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
}
