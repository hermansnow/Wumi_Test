//
//  ProfileListCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import NHAlignmentFlowLayout

class ProfileListCell: ProfileCell {

    @IBOutlet weak var titleStackView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var separator = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize the collection's layout - left alignment flow layout
        let flowLayout = NHAlignmentFlowLayout()
        flowLayout.alignment = .TopLeftAligned
        flowLayout.scrollDirection = .Vertical
        flowLayout.estimatedItemSize = CGSize(width: 40, height: 20)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.scrollEnabled = false
        
        // Register collection cell
        self.collectionView.registerNib(UINib(nibName: "ProfileCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionCell")
        
        // Set properties
        self.titleLabel.font = Constants.General.Font.InputFont
        self.titleLabel.textColor = Constants.General.Color.BorderColor
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        layer.addSublayer(separator)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Add separator
        self.separator.frame = CGRect(x: self.titleStackView.frame.origin.x,
                                      y: self.titleStackView.frame.origin.y + self.titleStackView.bounds.height + 2,
                                  width: self.titleStackView.bounds.width,
                                 height: 1.0)
        self.separator.backgroundColor = UIColor.blackColor().CGColor
    }
    
    func reset() {
        self.titleLabel.text = nil
        self.addButton.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
        self.collectionView.tag = -1
    }
    
    func setCollectionViewDataSourceDelegate <T: protocol<UICollectionViewDataSource, UICollectionViewDelegate>> (dataSourceDelegate: T, ForIndexPath indexPath: NSIndexPath) {
        self.collectionView.dataSource = dataSourceDelegate;
        self.collectionView.delegate = dataSourceDelegate;
        self.collectionView.tag = indexPath.row
    
        self.collectionView.reloadData()
    }
    
    override func systemLayoutSizeFittingSize(targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        let minHeight = max(30, self.collectionView.collectionViewLayout.collectionViewContentSize().height)
        
        let size = CGSize(width: targetSize.width,
                         height: minHeight + self.collectionView.frame.origin.y + 10)
        
        return super.systemLayoutSizeFittingSize(size, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}
