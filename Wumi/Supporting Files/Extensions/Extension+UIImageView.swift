//
//  Extension+UIImageView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension UIImageView {
    
    // Return bounds of displayed image
    func displayedImageBounds() -> CGRect {
        
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
        return CGRectMake(0, topLeftY, boundsWidth, height)
    }
    
    // Return image scale factor
    func imageScaleFactor() -> CGFloat {
        guard let image = self.image else { return 1.0 }
        
        let widthScale = self.bounds.size.width / image.size.width
        let heightScale = self.bounds.size.height / image.size.height
        
        if (self.contentMode == .ScaleToFill) {
            return widthScale == heightScale ? widthScale : 0
        }
        if (self.contentMode == .ScaleAspectFit) {
            return min(widthScale, heightScale)
        }
        if (self.contentMode == .ScaleAspectFill) {
            return max(widthScale, heightScale)
        }
        return 1.0;
    }
}
