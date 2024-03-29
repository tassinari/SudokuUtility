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
        var row : Int
        var column : Int
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
    private var lastColumn : DLXNode?
    var solutionSet : [[DLXNode]] = []
    private var stopBlock : (([[Int]])->Bool)?
    var maxRecursionDepth = 500
    private var shouldStop = false
    private var random = false
    private var partialSolutionCoveredColumns : [DLXNode] = []
    
    //MARK: Init
    convenience init(from : [Int], size : Int) {

        self.init(from: DancingLinks.makeMatrix(from: from , size: size))
    }
    required init(from : DLXNode) {
        self.root = from
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
    internal func debugPrintMatrix(headPtr : DLXNode){
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
    internal func debugPrintHeaderConnections()->String{
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
    private func columnCount() -> Int{
        var node : DLXNode = root.right
        var c = 0
        while(node != root){
            node = node.right
            c += 1
        }
        return c
    }
    
    //MARK: Make Matrix
    
    private static func makeMatrix(from : [Int], size : Int) -> DLXNode{
        var headerPtr : DLXNode? = nil
        let colPointer = DLXNode()
        var first : DLXNode = DLXNode()
        for i in 0..<size {
            //header
            let n = DLXNode()
            n.tmp = true
            n.coordinate.column = i
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
                let theNewNode = DLXNode(DLXNode.Coordinate(row: row, column: col))
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
        if(col.columnCount == 0){
            return
        }
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
    
    //MARK: Solve
    internal func setPartialSolution(columns : [Int]){
        for i in columns{
            var node : DLXNode = root.right
            while(node != root){
                if(i == node.coordinate.column){
                    cover(node)
                    self.partialSolutionCoveredColumns.append(node)
                }
                node = node.right
            }
        }
    }
    internal func clearPartialSolution(columns : [Int]){
        let _ = self.partialSolutionCoveredColumns.reversed().map{uncover($0)}
        self.partialSolutionCoveredColumns.removeAll()
    }
    
    internal func solve(random: Bool, stopBlock : @escaping ([[Int]]) -> Bool ) throws {
        self.shouldStop = false
        self.stopBlock = stopBlock
        self.random = random
        self.internalSolutionSet = []
        self.solutionSet = []
        try solve(0)
    }
    

    private func solve(_ i : Int) throws  {
        if(i >= self.maxRecursionDepth ){
            throw DancingLinksError(type: .maxRecursionDepthBreached, debugInfo: "Too many recursions (\(self.maxRecursionDepth)).")
        }
        
        if root.right == root && root.left == root{
            //solved
           
            
            self.solutionSet.append( self.internalSolutionSet )
            let rows = self.solutionSet.map{ return $0.map{ Int($0.coordinate.row)}}
            
            if let block = self.stopBlock, block(rows) == true{
                shouldStop = true
                return
            }
        }
        
        let column = self.getMinimumColumn()
        if(column.columnCount == 0){
            return
        }
        self.cover(column)
        self.lastColumn = column
        for row in rows(column: column, randomized: self.random){
            if(shouldStop){
                break
            }
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

