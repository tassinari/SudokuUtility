//
//  DancingLinks.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation

class DLXNode : Equatable{
    struct Coordinate {
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
    var covered = false
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

class DancingLinks{
    private let data : RawSudukoData
    private var entryPoint : ColumnNode?
    private var allColumnPointer : ColumnNode?
    private var allRowPointer : Node?
    
    internal var solutionSet : [DLXNode] = []
    internal var columnHead : DLXNode = DLXNode()
    init(data : RawSudukoData) {
        self.data = data
        entryPoint =  baseMatrix(size: data.size)
    }
    internal func getMinimumColumn(header : DLXNode)->DLXNode{
        var lowestColumn = header
        var h = header.right
        while(h != header ){
            
            if let myColumn = h, myColumn.items.count < lowestColumn.items.count{
                lowestColumn = myColumn
            }
            h = h?.right
        }
        return lowestColumn
    }
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
            
           //if one add to matrix
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
        self.columnHead = returnVal
        return returnVal
    }
    internal func cover(_ node : DLXNode){
        guard let col = node.header else {
            return
        }
        let s = """
        
        _____________
        Covering column \(col.top!.coordinate.column)
        setting left's ( \(col.left!.top!.coordinate.column)) right to \(col.right!.top!.coordinate.column)
        setting rights's ( \(col.right!.top!.coordinate.column)) left to \(col.left!.top!.coordinate.column)
        ___________________
        """
        let tmp = !col.covered
        
        if !col.covered{
            col.left?.right = col.right
            col.right?.left = col.left
            node.covered = true
            
            //if the column is the header, get a new header.
            if(self.columnHead == col){
                guard let right = col.right else {
                    return
                }
                self.columnHead = right
            }
            
           // print(s)
        }
        for node in col.items{
            var n : DLXNode? = node.right
            repeat{
                //if we cover the columns top pointer, we must reset the top pointer ??
                
                n?.top?.bottom = n?.bottom
                n?.bottom?.top = n?.top
                if(n?.header?.top == n){
                    n?.header?.top = n?.bottom
                }
                n = n?.right
            } while(n != node && n != nil)
        }
        let s2 = """
        
        After the operation:
        _____________
        The Column: \(col.top!.coordinate.column)
        right is set to \(col.right!.top!.coordinate.column)
        left is set to \(col.left!.top!.coordinate.column)
        
        The Column's right: \(col.right!.top!.coordinate.column)
        right is set to \(col.right!.right!.top!.coordinate.column)
        left is set to \(col.right!.left!.top!.coordinate.column)
        
        The Column's left: \(col.left!.top!.coordinate.column)
        right is set to \(col.left!.right!.top!.coordinate.column)
        left is set to \(col.left!.left!.top!.coordinate.column)
        ___________________
        """
        if(tmp){
            //print(s2)
        }
        
    }
    internal func uncover(_ node : DLXNode){
        guard let col = node.header else {
            return
        }
        col.left?.right = col
        col.right?.left = col
        node.covered = false
        for node in col.items{
            var n : DLXNode? = node
            repeat{
                if(n?.header?.top == n?.bottom){
                    n?.header?.top = n
                }
                n?.top?.bottom = n
                n?.bottom?.top = n
                n = n?.right
            } while(n != node)
        }
    }
    
    
    
    public func solve() throws  {
        let header = self.columnHead
        if header.left == header{
            //solved
            
            return
        }
        var column = self.getMinimumColumn(header: header)
        
        self.cover(column)
    
    
        for row in column.items{
            solutionSet.append(row)
            var rowptr : DLXNode? = row
            repeat{
                guard let rp = rowptr else {
                    throw DancingLinkError.parseError
                }
                self.cover(rp)
                rowptr = rp.right
            } while row != rowptr
            print("recursing")
            try? solve()
            solutionSet.removeAll(where: { $0 == row})
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
    
    internal func baseMatrix(size: UInt8) -> ColumnNode{
        var entry : ColumnNode?
        var latestNode : ColumnNode?
        var rowPointers: [[Node]] = []
        //Make Columns
        for (k,type) in ColumnNodeType.allCases.enumerated(){
            var rowPointer : [Node] = []
            for i in 0..<size{  //rows
                for j in 0..<size{  //colmns
                    let columnNode = ColumnNode(type: type, row: i, column: j)
                    columnNode.type = type
                    columnNode.left = latestNode
                    latestNode?.right = columnNode
                    latestNode = columnNode
                    //first one is the entry point
                    if(k == 0 && j == 0 && i == 0){
                        entry = columnNode
                    }
                    //hook the last to a first for a circular double link list
                    if( j == size - 1 && i == size - 1 && k == ColumnNodeType.allCases.count - 1){
                        columnNode.right = entry
                        entry?.left = columnNode
                    }
                    
                    var prev : Node? = nil
                    var first : Node? = nil
                    //every column has size nmber of nodes, but where are they?
                    for value in 0..<size{
                        
                        
                        
                        let node = Node()
                        node.coordinate = Coordinate(row: i, column: j)
                        switch type {
                        case .cellConstraint:
                            node.coordinate = Coordinate(row: i, column: j)
                        case .rowConstraint:
                            node.coordinate = Coordinate(row: i, column: value)
                        case .columnConstraint:
                            node.coordinate = Coordinate(row: j, column: value)
                        case .groupConstaint:
                            node.coordinate = Coordinate(row: groupFromIndex(index: Coordinate(row: i, column: j).index), column: value)
                        }
                        node.coordinate?.value = value
                        node.header = columnNode
                        node.value = true
                        node.type = type
                        node.top = prev
                        prev?.bottom = node
                        if(value == 0){
                            first = node
                            columnNode.top = node
                        }
                        if(value == size - 1){
                            node.bottom = first
                            first?.top = node
                        }
                        rowPointer.append(node)
                        prev = node
                        
                    }
                    
                }
                
            }
            rowPointers.append(rowPointer)
        }
        
        //link every node in same row based on rowPointers
        if let topRow = rowPointers.first{
            for i in 0..<topRow.count{
                var nodes : [Node] = []
                for row  in rowPointers{
                    nodes.append(row[i])
                }
                //link all nodes
                for (i, node) in nodes.enumerated(){
                    if(i == 0){
                        node.left = nodes[nodes.count - 1]
                        node.right = nodes[i + 1]
                    }else if(i == nodes.count - 1){
                        node.right = nodes[0]
                        node.left = nodes[i - 1]
                    }else{
                        node.left = nodes[i - 1]
                        node.right = nodes[i + 1]
                    }
                }
                   
            }
        }else{
            //TODO: throw error
        }
        
        //TODO: have this throw for a empty data set( size =0)
        return entry!
    }
    
   
}



internal enum ColumnNodeType : CaseIterable{
    case cellConstraint, rowConstraint, columnConstraint, groupConstaint

}

internal class ColumnNode : Equatable{
    static func == (lhs: ColumnNode, rhs: ColumnNode) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column && lhs.type == rhs.type
    }
    
    //FIXME : remove,  tying suuduko impl to this class, need abstract DLX node
    var type : ColumnNodeType
    var covered : Bool
    var top : Node?
    var left : ColumnNode?
    var right : ColumnNode?
    
    init(type: ColumnNodeType, row : UInt8, column : UInt8) {
        self.type = type
        self.covered = false
        self.row = row
        self.column = column
    }
    
    var row : UInt8
    var column : UInt8
    
    var items : [Node]? {
        if let topNode = top{
            var nodes : [Node] = []
            var nodePtr : Node? = topNode
            repeat{
                nodes.append(nodePtr!)  //can force unwrap, will never be nil
                nodePtr = nodePtr?.bottom
            }while(nodePtr != nil && nodePtr != topNode)
            return nodes
        }
        return nil
    }
    internal func cover(){
        //remove node from linked list, but node must keep reference to left tand right
        self.right?.left = self.left
        self.left?.right = self.right
        //remove rows
        if let items = self.items{
            for rowNode in items{
                rowNode.cover()
            }
        }

    }
    internal func uncover(){
        //reweave in the node into the list
        self.left?.right = self
        self.right?.left = self

        //re-add rows
        if let items = self.items{
            for rowNode in items{
                rowNode.uncover()
            }
        }

    }

}
extension ColumnNode : CustomStringConvertible{
    var description: String {
        
        return "type=\(type) r-\(String(describing: self.row)) c-\(String(describing: self.column)) <\(Unmanaged.passUnretained(self as AnyObject).toOpaque().debugDescription)>"
    }
    
}

internal class Node : Equatable, CustomStringConvertible, Hashable{
    static func == (lhs: Node, rhs: Node) -> Bool {
        guard lhs.coordinate  != nil else {
            return false
        }
        return lhs.coordinate == rhs.coordinate  && lhs.type == rhs.type && lhs.header == rhs.header
    }
    func hash(into hasher: inout Hasher) {
       guard let t = self.type, let c = self.coordinate else {

        return
       }
        hasher.combine(c.index)
        hasher.combine(c.value)
        hasher.combine(t)
    }
    
    var header : ColumnNode?
    var left : Node?
    var right : Node?
    var top : Node?
    var bottom : Node?
    var coordinate : Coordinate?
    var value : Bool = false
    var type : ColumnNodeType?
    
    var description: String {
           
        return "Node<\( Unmanaged.passUnretained(self as AnyObject).toOpaque().debugDescription)> [value type=\(type.debugDescription) coordinate=(r-\(String(describing: self.coordinate!.row)) c-\(String(describing: self.coordinate!.column)) v \(String(describing: self.coordinate!.value!))]"
       }
    internal func cover(){
        guard let col = self.header, let nodes = col.items else {
            return
        }
        col.left?.right = col.right
        col.right?.left = col.left
        for node in nodes{
            var n = node.right
            while(n != node){
                n?.top?.bottom = n?.bottom
                n?.bottom?.top = n?.top
                n = node.right
            }
        }
    }
    internal func uncover(){
        guard let col = self.header, let nodes = col.items else {
            return
        }
        col.left?.right = col
        col.right?.left = col
        for node in nodes{
            var n = node.right
            while(n != node){
                n?.top?.bottom = n
                n?.bottom?.top = n
                n = node.right
            }
        }
    }
    
}
