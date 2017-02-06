//
//  PIKAQuadTree.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

struct PIKAQuadTree {
    /// Root node of this quad tree.
    private var root: PIKAQuadTreeNode
    /// Array of leaf nodes of this quad tree.
    var leaves: [PIKAQuadTreeNode] {
        return self.root.leaves
    }
    
    // MARK: Initializers
    
    init(root: PIKAQuadTreeNode) {
        self.root = root
    }
    
    // MARK: Operations
    
    /**
     Add a new data into this quad tree.
     
     - Parameters:
        - data: PIKAQuadData object to be added.
     
     - Returns:
        True if successfully added the data object, otherwise false.
     */
    func insert(data: PIKAQuadData) -> Bool {
        return self.root.insert(data)
    }
    
    /**
     Get all data in a bounding box from this node.
     
     - Parameters:
        - box: bounding box to search.
     
     - Returns:
        An array of PIKAQuadData objects in this bounding box.
     */
    func getAllData(inBox box: PIKAQuadBoundingBox) -> [PIKAQuadData] {
        return self.root.getAllData(inBox: box)
    }
    
    func showClusters() {
        self.root.showCluster()
    }
}
