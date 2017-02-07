//
//  PIKAQuadTreeNode.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

class PIKAQuadTreeNode {
    /// Northeast subnode of this quad tree node.
    private var northEast: PIKAQuadTreeNode?
    /// Southeast subnode of this quad tree node.
    private var southEast: PIKAQuadTreeNode?
    /// Northwest subnode of this quad tree node.
    private var northWest: PIKAQuadTreeNode?
    /// Southwest subnode of this quad tree node.
    private var southWest: PIKAQuadTreeNode?
    /// Bounding box of this quad tree node.
    private var boundingBox: PIKAQuadBoundingBox
    /// Array of data in this node. 
    /// The array will be incompleted if the node is full, therefore, this data is only reliable for leaf nodes.
    private lazy var data = [PIKAQuadData]()
    /// Maximum number of data can be handled by node itself.
    private var capacity: Int = 10
    /// Number of data sets in the sub quad-tree with this node as root.
    var count: Int {
        if isLeaf() { return self.data.count }
        
        return self.northWest!.count + self.northEast!.count + self.southWest!.count + self.southEast!.count
    }
    /// Array of leaf nodes in the sub quad-tree with this node as root.
    var leaves: [PIKAQuadTreeNode] {
        if self.isLeaf() {
            return [self]
        }
        
        var subNodes = [PIKAQuadTreeNode]()
        
        subNodes.appendContentsOf(self.northEast!.leaves)
        subNodes.appendContentsOf(self.northWest!.leaves)
        subNodes.appendContentsOf(self.southEast!.leaves)
        subNodes.appendContentsOf(self.southWest!.leaves)
        
        return subNodes
    }
    
    //  MARK: Initializers
    
    init(withBoundingBox box: PIKAQuadBoundingBox, data: [PIKAQuadData]? = nil, capacity: Int = 10) {
        self.boundingBox = box
        if data != nil {
            self.data = data!
        }
        self.capacity = capacity
    }
    
    // MARK: Operations
    
    /**
     Add a new data into this quad node.
     
     - Parameters:
        - data: PIKAQuadData object to be added.
     
     - Returns:
        True if successfully added the data object, otherwise false.
     */
    func insert(data: PIKAQuadData) -> Bool {
        guard self.boundingBox.contains(data) else {
            return false
        }
        
        if !isFull() {
            self.data.append(data)
            return true
        }
        
        if isLeaf() {
            //divide tree node
            self.divide()
        }
        
        // Try insert the data point to all subnodes
        if self.northWest!.insert(data) { return true }
        if self.northEast!.insert(data) { return true }
        if self.southEast!.insert(data) { return true }
        if self.southWest!.insert(data) { return true }
        
        return false
    }
    
    /**
     Get all data in a bounding box from this node.
     
     - Parameters:
        - box: bounding box to search.
     
     - Returns:
        An array of PIKAQuadData objects in this bounding box.
     */
    func getAllData(inBox box: PIKAQuadBoundingBox) -> [PIKAQuadData] {
        guard self.boundingBox.intersects(box) else { return [] }
        
        var inboxData = [PIKAQuadData]()
        
        // Loop through all data objects to find results in box if this node is a leaf
        if self.isLeaf() {
            for data in self.data {
                if box.contains(data) {
                    inboxData.append(data)
                }
            }
        }
        // Otherwise, recurse into subnodes.
        else {
            inboxData.appendContentsOf(self.northEast!.getAllData(inBox: box))
            inboxData.appendContentsOf(self.northWest!.getAllData(inBox: box))
            inboxData.appendContentsOf(self.southEast!.getAllData(inBox: box))
            inboxData.appendContentsOf(self.southWest!.getAllData(inBox: box))
        }
        
        return inboxData
    }
    
    /**
     Remove all data from the sub quad-tree with this node as root.
     */
    func removeAllData() {
        guard !self.isLeaf() else {
            self.data.removeAll()
            return
        }
        
        self.northWest!.removeAllData()
        self.northWest = nil
        self.northEast!.removeAllData()
        self.northEast = nil
        self.southWest!.removeAllData()
        self.southWest = nil
        self.southEast!.removeAllData()
        self.southEast = nil
        self.data.removeAll()
    }
    
    /**
     Divide this node into four subnodes.
     */
    private func divide() {
        // Quit if it is a leaf node.
        guard self.isLeaf() else { return }
        
        self.northWest = PIKAQuadTreeNode(withBoundingBox: PIKAQuadBoundingBox(x: self.boundingBox.x, y: self.boundingBox.y, x1: self.boundingBox.xMid, y1: self.boundingBox.yMid),
                                          capacity: self.capacity)
        self.northEast = PIKAQuadTreeNode(withBoundingBox: PIKAQuadBoundingBox(x: self.boundingBox.xMid, y: self.boundingBox.y, x1: self.boundingBox.x1, y1: self.boundingBox.yMid),
                                          capacity: self.capacity)
        self.southWest = PIKAQuadTreeNode(withBoundingBox: PIKAQuadBoundingBox(x: self.boundingBox.x, y: self.boundingBox.yMid, x1: self.boundingBox.xMid, y1: self.boundingBox.y1),
                                          capacity: self.capacity)
        self.southEast = PIKAQuadTreeNode(withBoundingBox: PIKAQuadBoundingBox(x: self.boundingBox.xMid, y: self.boundingBox.yMid, x1: self.boundingBox.x1, y1: self.boundingBox.y1),
                                          capacity: self.capacity)
        
        // Distribute data to subnodes
        for data in self.data {
            // Try insert the data point to all subnodes
            self.northWest?.insert(data)
            self.northEast?.insert(data)
            self.southEast?.insert(data)
            self.southWest?.insert(data)
        }
    }
    
    // MARK: Helper functions
    
    /**
     Print out cluster information.
     */
    func showCluster() {
        if isLeaf() {
            print("Boundary: \(self.boundingBox) Capacity: \(self.capacity) Count: \(self.data.count)")
            for data in self.data {
                print("    \(data)")
            }
        }
        
        self.northWest?.showCluster()
        self.northEast?.showCluster()
        self.southWest?.showCluster()
        self.southEast?.showCluster()
    }
    
    /**
     Whether this quad node is a leaf.
     
     - Returns:
        True if this node is leaf, otherwise false.
     */
    private func isLeaf() -> Bool {
        return self.northEast == nil
    }
    
    /**
     Whether this qaud node is full or not.
     
     - Returns:
        True if this node is full, otherwise false.
     */
    private func isFull() -> Bool {
        return self.data.count >= self.capacity
    }
}
