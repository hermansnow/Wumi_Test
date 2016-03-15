//
//  ProfessionListViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import NHAlignmentFlowLayout

class ProfessionListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerStack: UIStackView!
    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var listDescription: UILabel!
    
    @IBOutlet weak var professionCollectionView: UICollectionView!
    
    var professionDelegate: ProfessionListDelegate?
    
    var avatarImage: UIImage?
    var selectedProfessions = Set<Profession>()
    lazy var professions = [String: [Profession]]()
    lazy var professionCategories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize header
        let title = "Professions"
        let details = "you can select up to 3 related professions"
        let description = NSMutableAttributedString(string: "\(title) (\(details))",
            attributes: [NSFontAttributeName: UIFont(name: ".SFUIText-Light", size: 12)!])
        description.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.grayColor(),
                          range: NSRange(location: title.characters.count, length: details.characters.count + 3))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        description.addAttribute(NSParagraphStyleAttributeName,
                          value: style,
                          range: NSRange(location: 0, length: description.length))
        listDescription.attributedText = description
        listDescription.numberOfLines = 0
        avatarImageView.image = avatarImage
        headerView.backgroundColor = Constants.General.Color.BackgroundColor
        headerStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        headerStack.layoutMarginsRelativeArrangement = true
        
        // Initializde collection view
        professionCollectionView.backgroundColor = Constants.General.Color.BackgroundColor
        let flowLayout = NHAlignmentFlowLayout ()
        flowLayout.scrollDirection = .Vertical
        flowLayout.alignment = .TopLeftAligned
        flowLayout.estimatedItemSize = CGSize(width: 40, height: 30)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        professionCollectionView.collectionViewLayout = flowLayout
        professionCollectionView.backgroundColor = UIColor.whiteColor()
        
        // Set delegates
        professionCollectionView.delegate = self
        professionCollectionView.dataSource = self
        
        // Register collection cell
        professionCollectionView.registerNib(UINib(nibName: "ProfileCollectionCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProfileCollectionCell")
        professionCollectionView.registerNib(UINib(nibName: "ProfessionSectionHeader", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                       withReuseIdentifier: "ProfessionSectionHeader")
        
        // Fetch profession data
        loadProfessions()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            professionDelegate?.finishProfessionSelection(selectedProfessions)
        }
    }

    // MARK: Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return professionCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let key = professionCategories[safe: section], category = professions[key] else {
            return 0
        }
        return category.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dequeueCell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionCell", forIndexPath: indexPath)
        
        
        guard let cell = dequeueCell as? ProfileCollectionCell, key = professionCategories[safe: indexPath.section], profession = professions[key]?[indexPath.row] else {
            return dequeueCell
        }

        cell.cellLabel.text = profession.name
        
        var isSelected = false
        for selectedProfession in selectedProfessions {
            if selectedProfession.compareTo(profession) {
                isSelected = true
                break
            }
        }
        if isSelected {
            cell.style = .Selected
        }
        else {
            cell.style = .Original
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                                                      withReuseIdentifier: "ProfessionSectionHeader",
                                                             forIndexPath: indexPath)
        
        guard let sectionHeader = header as? ProfessionSectionHeader, key = professionCategories[safe: indexPath.section] else {
            return header
        }
        sectionHeader.titleLabel.text = key.uppercaseString
        
        return sectionHeader
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let key = professionCategories[safe: indexPath.section], categoryList = professions[key], profession = categoryList[safe: indexPath.row], cell = collectionView.cellForItemAtIndexPath(indexPath) as? ProfileCollectionCell else {
            return
        }
        
        switch (cell.style) {
        case .Original:
            if selectedProfessions.count < 3 {
                selectedProfessions.insert(profession)
                cell.style = .Selected
            }
        case .Selected:
            for selectedProfession in selectedProfessions {
                if selectedProfession.compareTo(profession) {
                    selectedProfessions.remove(selectedProfession)
                    break
                }
            }
            cell.style = .Original
        }
        
        print(selectedProfessions.count)
    }
    
    // MARK: Help functions
    private func loadProfessions() {
        Profession.loadAllProfessions { (results, error) -> Void in
            if results == nil || results.count == 0 {
                print("\(error)")
                return
            }
            
            if let allProfessions = results as? [Profession] {
                self.professions = allProfessions.groupBy { (profession) -> String in
                    return profession.category!
                }
                
                self.professionCategories = Array(self.professions.keys.sort())
                
                self.professionCollectionView.reloadData()
            }
        }
    }
}

protocol ProfessionListDelegate {
    func finishProfessionSelection(selectedProfessions: Set<Profession>)
}
