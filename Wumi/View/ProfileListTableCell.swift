//
//  ProfileListTableCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import NHAlignmentFlowLayout

class ProfileListTableCell: ProfileTableCell {

    @IBOutlet weak var titleStackView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize the collection's layout - left alignment flow layout
        let flowLayout = NHAlignmentFlowLayout()
        flowLayout.alignment = .TopLeftAligned
        flowLayout.scrollDirection = .Vertical
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.scrollEnabled = false
        
        // Register collection cell
        self.collectionView.registerNib(UINib(nibName: "ProfileCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionCell")
        
        // Set properties
        self.titleLabel.font = Constants.General.Font.ProfileTitleFont
        self.titleLabel.textColor = Constants.General.Color.ProfileTitleColor
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        self.reset()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Update separator
        self.separator.frame = CGRect(x: self.titleStackView.frame.origin.x,
                                      y: self.titleStackView.frame.origin.y + self.titleStackView.bounds.height + 5,
                                  width: self.titleStackView.bounds.width,
                                 height: 1.0)
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
        
        let minHeight = max(24, self.collectionView.collectionViewLayout.collectionViewContentSize().height)
        
        let size = CGSize(width: targetSize.width,
                         height: minHeight + self.collectionView.frame.origin.y + 10)
        
        return super.systemLayoutSizeFittingSize(size, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}
