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
    
    var separator = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize the collection's layout
        let flowLayout = NHAlignmentFlowLayout()
        flowLayout.alignment = .TopLeftAligned
        flowLayout.scrollDirection = .Vertical
        flowLayout.estimatedItemSize = CGSize(width: 40, height: 20)
        collectionView.collectionViewLayout = flowLayout
        collectionView.scrollEnabled = false
        
        // Register collection cell
        collectionView.registerNib(UINib(nibName: "ProfileCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionCell")
        
        // Set properties
        titleLabel.font = Constants.General.Font.InputFont
        titleLabel.textColor = Constants.General.Color.BorderColor
        collectionView.backgroundColor = UIColor.whiteColor()
        
        layer.addSublayer(separator)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Add separator
        separator.frame = CGRect(x: titleStackView.frame.origin.x,
                                 y: titleStackView.frame.origin.y + titleStackView.bounds.height + 2,
                             width: titleStackView.bounds.width,
                            height: 1.0)
        separator.backgroundColor = UIColor.blackColor().CGColor
    }
    
    func reset() {
        titleLabel.text = nil
        addButton.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        collectionView.dataSource = nil
        collectionView.delegate = nil
        collectionView.tag = -1
    }
    
    func setCollectionViewDataSourceDelegate <T: protocol<UICollectionViewDataSource, UICollectionViewDelegate>> (dataSourceDelegate: T, ForIndexPath indexPath: NSIndexPath) {
        collectionView.dataSource = dataSourceDelegate;
        collectionView.delegate = dataSourceDelegate;
        collectionView.tag = indexPath.row
    
        collectionView.reloadData()
    }
    
    override func systemLayoutSizeFittingSize(targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        let minHeight = max(30, collectionView.collectionViewLayout.collectionViewContentSize().height)
        
        let size = CGSize(width: targetSize.width,
                         height: minHeight + collectionView.frame.origin.y + 10)
        
        print(size)
        
        return super.systemLayoutSizeFittingSize(size, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}
