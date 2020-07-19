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
    var header : DLXNode!
    var left : DLXNode!
    var right : DLXNode!
    var top : DLXNode!
    var bottom : DLXNode!
    var coordinate : Coordinate
    var columnCount = 0
    var tmp = false
    
    enum TraverseDirection{
        case up, down, left, right
    }
    private func next( forDirection : TraverseDirection) -> DLXNode{
        switch forDirection {
        case .up:
            return self.top
        case .down:
            return self.bottom
        case .left:
            return self.left
        case .right:
            return self.right
            
        }
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

//MARK:  Dancing Linke Error

struct DancingLinksError : Error  {
    
    enum DancingLinksErrorType{
        case parseError, maxRecursionDepthBreached
    }
    var localizedDescription : String {
        return debugInfo
    }
    
    let type : DancingLinksErrorType
    let debugInfo :String
}

//MARK: Dancing Links
final class DancingLinks{
    
    internal var internalSolutionSet : [DLXNode] = []
    internal var root : DLXNode = DLXNode()
    internal var size : Int
    private var lastColumn : DLXNode?
    var solutionSet : [[DLXNode]] = []
    private var stopBlock : (([[Int]])->Bool)?
    var maxRecursionDepth = 500
    
    //MARK: Init
    required init(from : [Int], size : Int) {
        self.size = size
        self.root = makeMatrix(from: from , size: size)
    }
    
    //MARK: Min Column
    internal func getMinimumColumn()->DLXNode{
        var node : DLXNode = root.right
        var minNode : DLXNode = node
        while(node != root){
            if(node.columnCount < minNode.columnCount && node.columnCount > 0){
                minNode = node
            }
            node = node.right
        }
        return minNode
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
    public func debugPrintHeaderConnections()->String{
        let max = 20
        var count = 0
        var loopBegin = -1
        var loopEnd = -1
        
        var nodes : [DLXNode] = [root]
        var node = root.right
        repeat{
            guard let n = node else{
                return "NIL found in list"
            }
            if let index = nodes.lastIndex(of: n){
                loopBegin = index
                loopEnd = count
                break
            }
            nodes.append(n)
            count += 1
            node = node?.right
        }while count < max && node != root
        var str = ""
        if(loopBegin >= 0 && loopEnd >= 0){
            str.append("Loop found \(loopEnd) -> \(loopBegin)\n")
        }
        for (i,node) in nodes.enumerated(){
            str.append("""
                \(i)) (col \(node.top?.coordinate.column ?? 0)) -- <\(Unmanaged.passUnretained(node as AnyObject).toOpaque().debugDescription)> ==>
                """)
        }
        
        return str
        
    }
    
    //MARK: Make Matrix
    
    public func makeMatrix(from : [Int], size : Int) -> DLXNode{
        var headerPtr : DLXNode? = nil
        let colPointer = DLXNode()
        var first : DLXNode = DLXNode()
        for i in 0..<size {
            //header
            let n = DLXNode()
            n.tmp = true
            n.coordinate.column = UInt8(i)
            n.header = n
            if(i == 0){
                first = n
                headerPtr = n
                continue
            }
            headerPtr?.right = n
            n.left = headerPtr
            if (i == size - 1){
                first.left = n
                n.right = first
            }
            headerPtr = n
        }
        //Have all the coluumn nodes made, now weave in the colPointer (root) between first and headerPtr
        colPointer.right = first
        colPointer.left = headerPtr
        headerPtr?.right = colPointer
        first.left = colPointer
        
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
                var colHeader : DLXNode = first
                let theNewNode = DLXNode(DLXNode.Coordinate(row: UInt8(row), column: UInt8(col)))
                //get col header
                for _ in 0..<col{
                    colHeader = colHeader.right
                    
                }
                theNewNode.header = colHeader
                //add new node to bottom of column
                
                if colHeader.columnCount != 0{
                    //we have a node, add to bottom
                    theNewNode.bottom = colHeader
                    theNewNode.top = colHeader.top
                    colHeader.top.bottom = theNewNode
                    colHeader.top = theNewNode
                    
                }else{
                    //No top node, make this the first
                    colHeader.top = theNewNode
                    colHeader.bottom = theNewNode
                    theNewNode.top = colHeader
                    theNewNode.bottom = colHeader
                    
                }
                colHeader.columnCount += 1
                
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
        return colPointer
    }
    
    //MARK: Cover
    internal func cover(_ col : DLXNode){
        
        col.left.right = col.right
        col.right.left = col.left
        var next : DLXNode = col.bottom
        while(next != col){
            var right = next.right
            while(right != next){
                right?.top.bottom = right?.bottom
                right?.bottom.top = right?.top
                right?.header.columnCount -= 1
                right = right?.right
            }
            next = next.bottom
        }
    }
    
    //MARK: Uncover
    internal func uncover(_ col : DLXNode){
        
        var next = col.top
        while(next != col){
            var left = next?.left
            while(left != next){
                left?.top.bottom = left
                left?.bottom.top = left
                left?.header.columnCount += 1
                left = left?.left
            }
            next = next?.top
        }
        col.left.right = col
        col.right.left = col
    }
    public func solve(random: Bool, stopBlock : @escaping ([[Int]]) -> Bool ) throws {
        self.stopBlock = stopBlock
        try solve(0)
    }
    
    //MARK: Solve
    private func solve(_ i : Int) throws  {
        if(i >= self.maxRecursionDepth ){
            throw DancingLinksError(type: .maxRecursionDepthBreached, debugInfo: "Too many recursions (\(self.maxRecursionDepth)).")
        }
        if root.right == root && root.left == root{
            //solved
           
            let rows = self.solutionSet.map{ return $0.map{ Int($0.coordinate.row)}}
            if let block = self.stopBlock, block(rows){
                return
            }
            self.solutionSet.append( self.internalSolutionSet )
            if let last = self.lastColumn{
                uncover(last)
                self.lastColumn = nil
                return
            }
            
        }
        let column = self.getMinimumColumn()
        
        self.cover(column)
        self.lastColumn = column
        
        for row in rows(column: column, randomized: true){
            internalSolutionSet.append(row)
            
            //cover to right
            var right : DLXNode = row.right
            while(row != right){
                self.lastColumn = right.header
                cover(right.header)
                
                right = right.right
            }
            
            try solve(i + 1)
            
            
            //uncover to left
            var left : DLXNode = row.left
            while(row != left){
                uncover(left.header)
                self.lastColumn = nil
                left = left.left
            }
            internalSolutionSet.removeAll(where: { $0 == row})
        }
        
        self.lastColumn = nil
        self.uncover(column)
        
    }
    private func rows(column: DLXNode ,randomized : Bool) -> [DLXNode] {
        var rows : [DLXNode] = []
        var row : DLXNode = column.bottom
        while row != column{
            rows.append(row)
            row = row.bottom
        }
        return randomized ? rows.shuffled() : rows
    }
}

