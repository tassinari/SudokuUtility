//
//  DancingLinks.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation


//MARK: DLXNode

class DLXNode : Equatable{
    struct Coordinate  :  Equatable{
        static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
            return  rhs.column == lhs.column && lhs.row == rhs.row
           }
        var row : UInt8
        var column : UInt8
    }
    static func == (lhs: DLXNode, rhs: DLXNode) -> Bool {
        return  ObjectIdentifier(rhs) == ObjectIdentifier(lhs)
    }
    init(_ coordinate : Coordinate){
        self.coordinate = coordinate
    }
    init(){
        self.coordinate = Coordinate(row: 0, column: 0)
    }
    var header : DLXNode?
    var left : DLXNode?
    var right : DLXNode?
    var top : DLXNode? = nil
    var bottom : DLXNode?
    var coordinate : Coordinate
    var columnCount = 0
    var items : [DLXNode] {
        guard let topNode = top else{
            //TODO: better error enumeration
            return []
        }
        var nodes : [DLXNode] = []
        var nodePtr : DLXNode? = topNode
        repeat{
            nodes.append(nodePtr!)  //can force unwrap, will never be nil
            nodePtr = nodePtr?.bottom
        }while( nodePtr != topNode)
        return nodes
    }
    
    
}

extension DLXNode : CustomStringConvertible{
    var description: String {
        
        return """
        DLX Node:
        <\(Unmanaged.passUnretained(self as AnyObject).toOpaque().debugDescription)>
        coord : (\(self.coordinate.row), \(self.coordinate.column))
        left: <\(Unmanaged.passUnretained(self.left as AnyObject).toOpaque().debugDescription)>
        right: <\(Unmanaged.passUnretained(self.right as AnyObject).toOpaque().debugDescription)>
        top: <\(Unmanaged.passUnretained(self.top as AnyObject).toOpaque().debugDescription)>
        bottom: <\(Unmanaged.passUnretained(self.bottom as AnyObject).toOpaque().debugDescription)>
        header: <\(Unmanaged.passUnretained(self.header as AnyObject).toOpaque().debugDescription)>
        """
    }
    
}
enum DancingLinkError : Error{
    
    case parseError
}

//MARK: Dancing Links
final class DancingLinks{
    internal var internalSolutionSet : [DLXNode] = []
    internal var columnHead : DLXNode?
    var solutionSet : [DLXNode] = []
    
     //MARK: Init
    required init(from : [Int], size : Int) {
        self.columnHead = makeMatrix(from: from , size: size)
    }
    
    //MARK: Min Column
    internal func getMinimumColumn(header : DLXNode)->DLXNode{
        var lowestColumn = header
        var h = header.right
        while(h != header ){
            
            if let myColumn = h, myColumn.columnCount < lowestColumn.columnCount && myColumn.columnCount > 0{
                lowestColumn = myColumn
            }
            h = h?.right
        }
        return lowestColumn
    }
    
    //MARK: Debug print
    //TODO: use apple protocol
    public func debugPrintMatrix(headPtr : DLXNode){
        var colCnt = 0
        var next : DLXNode? = headPtr
        repeat{
            print("Column: \(colCnt)")
             print("Column header:")
            print(next!)
             print("Nodes")
            print("____________")
            guard let node = next?.top else{
                print("NO TOP NODE PTR!!")
                return
            }
            var nPtr : DLXNode? = node
            repeat{
                guard let myNode = nPtr else{
                    print("No NODE")
                    return
                }
                print(myNode)
                nPtr = nPtr?.bottom
                print("____________")
            }while nPtr != nil && nPtr != node
            colCnt += 1
            next = next?.right
        }while headPtr != next && next != nil
        
    }
    
    //MARK: Make Matrix
    
    public func makeMatrix(from : [Int], size : Int) -> DLXNode{
        var headerPtr : DLXNode? = nil
        var first : DLXNode? = nil
        //TODO: optimize, move down to main for loop
        for i in 0..<size {
            //header
            let n = DLXNode()
            n.header = n
            if(i == 0){
                first = n
                headerPtr = n
                continue
            }
            headerPtr?.right = n
            n.left = headerPtr
            if (i == size - 1){
                first?.left = n
                n.right = first
            }
            headerPtr = n
        }
        var row = 0
        var col = 0
        var rowPtr : DLXNode? = nil
        var latestRowPtr : DLXNode? = nil
       
        for i in 0..<from.count{
            col = i % size
            row = i / size
            if(col == 0){
                rowPtr = nil
                latestRowPtr = nil
            }
            
           //if one (an active node) add to matrix
            if(from[i] == 1){
                
                //Columns
                
                guard var colHeader : DLXNode = first else{
                    //FIXME: throw
                    return DLXNode()
                }
                let theNewNode = DLXNode(DLXNode.Coordinate(row: UInt8(row), column: UInt8(col)))
                //get col header
                for _ in 0..<col{
                    //TODO: fix return
                     guard let c = colHeader.right else{
                         //FIXME: throw
                        return DLXNode()
                    }
                    colHeader = c
                    
                }
                theNewNode.header = colHeader
                //add new node to bottom of column
                colHeader.columnCount += 1
                if let top = colHeader.top{
                    //we have a top node, add to bottom
                    theNewNode.bottom = top
                    theNewNode.top = top.top
                    top.top?.bottom = theNewNode
                    top.top = theNewNode
                    
                }else{
                    //No top node, make this the first
                    colHeader.top = theNewNode
                    theNewNode.top = theNewNode
                    theNewNode.bottom = theNewNode
                    
                }
                
                //Rows
                if rowPtr == nil {
                    rowPtr = theNewNode
                    latestRowPtr = theNewNode
                    
                }else{
                    theNewNode.left = latestRowPtr
                    latestRowPtr?.right = theNewNode
                    latestRowPtr = theNewNode
                }
                
            }
            if(col == size - 1){
                //last column, hook the last row to the first
                latestRowPtr?.right = rowPtr
                rowPtr?.left = latestRowPtr
                rowPtr = nil
                latestRowPtr = nil
            }
        }
        guard let returnVal : DLXNode = first else{
           //FIXME: throw
           return DLXNode()
        }
        return returnVal
    }
    
    //MARK: Cover
    internal func cover(_ node : DLXNode){
        guard let col = node.header else {
            return
        }
        
        col.left?.right = col.right
        col.right?.left = col.left
        
        //if the column is the header, get a new header.
        if(self.columnHead == col){
            guard let right = col.right else {
                return
            }
            self.columnHead = right == col ? nil : right
            //self.columnHead = right
        }
        
        
        for node in col.items{
            var n : DLXNode? = node
            repeat{
                //if we cover the columns top pointer, we must reset the top pointer ??
                
                n?.top?.bottom = n?.bottom
                n?.bottom?.top = n?.top
                if(n?.header?.top == n){
                    n?.header?.top = n?.bottom
                }
                n?.header?.columnCount -= 1
                n = n?.right
            } while(n != node && n != nil)
        }
        
    }
    //MARK: Uncover
    internal func uncover(_ node : DLXNode){    
        guard let col = node.header else {
            return
        }
       
        if(columnHead == nil ){
            columnHead = col
        }
        if(col.top?.coordinate.column ?? 0 < columnHead?.top?.coordinate.column ?? 0){
            columnHead = col
        }
        var myNode : DLXNode? = col.top
        repeat {
            var n : DLXNode? = myNode
            repeat{
                
                if(n?.header?.top == n?.bottom && n?.coordinate.row ?? 0 < n?.bottom?.coordinate.row ?? 0){
                    n?.header?.top = n
                }
                n?.top?.bottom = n
                n?.bottom?.top = n
                n?.header?.columnCount += 1
                n = n?.right
                
            } while(n != myNode)
            myNode = myNode?.top
            
        }while(col.top != myNode )
        col.left?.right = col
        col.right?.left = col
    }
    public func solve(random: Bool) throws {
       
        try solve(0)
    }
    
    //MARK: Solve
    private func solve(_ i : Int) throws  {
        guard let header = self.columnHead else{
            //solved
            self.solutionSet = self.internalSolutionSet
            return
        }

        var column = self.getMinimumColumn(header: header)
        if(column.columnCount == 0){
             self.uncover(column)
           // self.solutionSet = self.internalSolutionSet
            return
        }
        self.cover(column)
    
    
        for row in column.items{
            internalSolutionSet.append(row)
            var rowptr : DLXNode? = row
            repeat{
                guard let rp = rowptr else {
                    throw DancingLinkError.parseError
                }
                self.cover(rp)
                rowptr = rp.right
            } while row != rowptr
            try? solve( i + 1)
            internalSolutionSet.removeAll(where: { $0 == row})
            guard let c = row.header else{
                throw DancingLinkError.parseError
            }
            rowptr = row
            repeat {
                guard let rp = rowptr else {
                    throw DancingLinkError.parseError
                }
                self.uncover(rp)
                rowptr = rp.right
            }while row != rowptr
            column = c
            
            
        }
        self.uncover(column)
       
    }
}
   
