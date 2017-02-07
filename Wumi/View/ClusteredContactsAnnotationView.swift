//
//  ClusteredContactsAnnotationView.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/31/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import MapKit

class ClusteredContactsAnnotationView : MKAnnotationView {
    /// Label on center to show number of contacts clustered in this annotation.
    private lazy var countLabel = UILabel()
    /// Number of contacts clustered in this annotation.
    var clusterCount: Int {
        get {
            if let text = self.countLabel.text, count = Int(text) {
                return count
            }
            else {
                return 0
            }
        }
        set {
            self.countLabel.text = "\(newValue)"
            let expandSize = min(newValue, 10)
            // Resize annotation frame based on numnber of contacts, larger annotation indicates more contacts: width/height = 20 + 5 * count.
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: 20 + 5 * expandSize, height: 20 + 5 * expandSize))
            // Redraw
            self.setNeedsLayout()
        }
    }
    
    // MARK: Initializers
    
    override init(annotation: MKAnnotation?, reuseIdentifier identifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: identifier)
        
        self.setProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    // MARK: Draw views
    
    override func layoutSubviews() {
        // Update count label's frame
        self.countLabel.frame = self.bounds
        // Update corner radius to make tha annotation as circle
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.borderWidth = self.frame.size.height / 10
    }
    
    /**
     Private function to be called after initialization to set up properties for this view and its subviews.
     */
    private func setProperty() {
        self.backgroundColor = Constants.General.Color.ThemeColor
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: 30, height: 30))
        
        // Add count label
        self.countLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.countLabel.textAlignment = .Center
        self.countLabel.backgroundColor = UIColor.clearColor()
        self.countLabel.textColor = UIColor.whiteColor()
        self.countLabel.adjustsFontSizeToFitWidth = true
        self.countLabel.minimumScaleFactor = 2
        self.countLabel.numberOfLines = 1
        self.countLabel.baselineAdjustment = .AlignBaselines
        self.addSubview(self.countLabel)
    }
}
