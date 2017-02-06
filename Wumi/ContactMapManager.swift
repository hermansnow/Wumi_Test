//
//  ContactMapManager.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/26/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation
import MapKit

struct ContactMapManager {
    /// Quad tree structure for map clustering.
    private var quadTree = PIKAQuadTree()
    /// Internal recursive lock.
    private var recursiveLock = NSRecursiveLock()
    /// Constant zoom level value for MKMap world.
    private let zoomLevelAtMaxZoom = Int(log2(MKMapSizeWorld.width / 256.0))
    
    // MARK: Operations.
    
    /**
     Add an array of contact points into this map manager for clustering.
     
     - Parameters:
        - contactPoints: an array of contact points to be added.
     */
    func addContactPoints(contactPoints: [ContactPoint]) {
        for contactPoint in contactPoints {
            self.quadTree.insert(PIKAQuadData(contactPoint: contactPoint))
        }
        self.quadTree.showClusters()
    }
    
    /**
     Cluster contact points to annotations.
     
     - Parameters:
        - rect: Cluster contact points in this specific rect.
        - zoomScale: zoom scale of map.
    
     - Returns:
        An array of annotations as ContactPoint annotation or ClusteredContacts annotation.
     */
    func clusterContactPointsToAnnotions(withRect rect: MKMapRect, zoomScale: Double) -> [MKAnnotation] {
        // Quit if zoom scale is inifinite
        guard !zoomScale.isInfinite else { return [] }
        
        let zoomLevel = self.zoomLevel(ForScale: zoomScale)
        let cellSize = self.cellSize(ForZoomLevel: zoomLevel)
        let scale = zoomScale / cellSize
        
        // Calculate min and max coordinates for cells
        let minX = Int(floor(MKMapRectGetMinX(rect) * scale))
        let maxX = Int(floor(MKMapRectGetMaxX(rect) * scale))
        let minY = Int(floor(MKMapRectGetMinY(rect) * scale))
        let maxY = Int(floor(MKMapRectGetMaxY(rect) * scale))
        
        var clusters = [MKAnnotation]()
        
        self.recursiveLock.lock()
        // Loop through all cells
        for i in minX...maxX {
            for j in minY...maxY {
                
                let mapPoint = MKMapPoint(x: Double(i) / scale, y: Double(j) / scale)
                let mapSize = MKMapSize(width: 1.0 / scale, height: 1.0 / scale)
                let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
                let mapBox = PIKAQuadBoundingBox(mapRect: mapRect)
                
                var contactPoints = [ContactPoint]()
                
                // Get all contacts points in this cell
                let treeData = self.quadTree.getAllData(inBox: mapBox)
                for data in treeData {
                    guard let contactPoint = data.data as? ContactPoint else { continue }
                    
                    contactPoints.append(contactPoint)
                }
                
                // Determine which type of annotation will be used to represent this cell
                switch contactPoints.count {
                case 0: break
                case 1:
                    // Show contact point if we zoom in with a zoom level larger than 9
                    if zoomLevel >= 9 {
                        clusters.append(contactPoints.first!)
                    }
                    else {
                        let cluster = ClusteredContacts(contactPoints: contactPoints)
                        clusters.append(cluster)
                    }
                default:
                    let cluster = ClusteredContacts(contactPoints: contactPoints)
                    
                    clusters.append(cluster)
                }
            }
        }
        self.recursiveLock.unlock()
        
        return clusters
    }
    
    /**
     Show clustered annotations on map.
     
     - Parameters:
        - annotations: array of annotations to be shown on map.
        - mapView: map view to show annotations on.
     */
    func showClusterAnnotations(annotations: [MKAnnotation], onMapView mapView: MKMapView) {
        // Remove current displaying annotations excepts user location point
        var currentAnnotations = mapView.annotations
        currentAnnotations.removeObject(mapView.userLocation)
        mapView.removeAnnotations(currentAnnotations)
        // Add new annotations
        mapView.addAnnotations(annotations)
    }
    
    // MARK: Helper functions
    
    /**
     World map's zoom level value with a scale.
     
     - Parameters:
        - scale: map scale.
     
     - Returns:
        Zoom level of map.
     */
    private func zoomLevel(ForScale scale: Double) -> Int {
        return max(0, self.zoomLevelAtMaxZoom + Int(floor(log2f(Float(scale))) + 0.5))
    }
    
    /**
     Cluster cell size with a zoom level.
     
     - Parameters:
        - level: zoom level.
     
     - Returns:
        Cell size for clustering based on a zoom level.
     */
    private func cellSize(ForZoomLevel level: Int) -> Double {
        switch level {
        case 13...15:
            return 64
        case 16...18:
            return 32
        case 18 ..< Int.max:
            return 16
        default:
            return 88 // Less than 13
        }
    }
    
}

// MARK: MKMap extensions for PIKAQuadTree

extension PIKAQuadTree {
    /**
     Initialize a PIKAQuadTree instance with a MKMap world rect.
     */
    init() {
        self.init(root: PIKAQuadTreeNode(withBoundingBox: PIKAQuadBoundingBox(mapRect: MKMapRectWorld), capacity: 20))
    }
}

extension PIKAQuadBoundingBox {
    /**
     Initialize a PIKAQuadBoundingBox instance with a MKMap rect.
     
     - Parameters:
        - mapRect: MKMap rect frame.
     */
    init(mapRect: MKMapRect) {
        let topLeft = MKCoordinateForMapPoint(mapRect.origin)
        let bottomRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
            
        let minLat = bottomRight.latitude
        let maxLat = topLeft.latitude
            
        let minLon = topLeft.longitude
        let maxLon = bottomRight.longitude
            
        self.init(x: minLat, y: minLon, x1: maxLat, y1: maxLon)
    }
}

extension PIKAQuadData {
    /**
     Initialize a PIKAQuadData instance with a contact point.
     
     - Parameters:
        - contactPoint: contact point to be used to initialize this data object.
     */
    init(contactPoint: ContactPoint) {
        self.init(x: contactPoint.coordinate.latitude, y: contactPoint.coordinate.longitude, data: contactPoint)
    }
}
