//
//  DancingLinks.swift
//  SudukoUtility
//
//  Created by Mark Tassinari on 6/7/20.
//  Copyright © 2020 Tassinari. All rights reserved.
//

import Foundation

enum DancingLinkError : Error{
    
    case parseError
}

class DancingLinks{
    private let data : RawSudukoData
    private var entryPoint : ColumnNode?
    private var allColumnPointer : ColumnNode?
    private var allRowPointer : Node?
    private var solutionSet : [Node] = []
    
    init(data : RawSudukoData) {
        self.data = data
        entryPoint =  baseMatrix(size: data.size)
    }
    
    public func solve() throws  {
       //if colNode.size == 0 done
        //pick a colmn node add to set
        guard let col = entryPoint else{
            return
        }
        
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
//    internal func cover(){
//        //remove node from linked list, but node must keep reference to left tand right
//        self.right?.left = self.left
//        self.left?.right = self.right
//        //remove rows
//        if let items = self.items{
//            for rowNode in items{
//                rowNode.cover()
//            }
//        }
//
//    }
//    internal func uncover(){
//        //reweave in the node into the list
//        self.left?.right = self
//        self.right?.left = self
//
//        //re-add rows
//        if let items = self.items{
//            for rowNode in items{
//                rowNode.uncover()
//            }
//        }
//
//    }

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
            while(node.right != node){
                let n = node.right
                n?.top?.bottom = n?.bottom
                n?.bottom?.top = n?.top
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
            while(node.right != node){
                let n = node.right
                n?.top?.bottom = n
                n?.bottom?.top = n
            }
        }
    }
    
}
