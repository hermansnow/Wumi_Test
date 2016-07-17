//
//  ProfessionListViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import NHAlignmentFlowLayout

class ProfessionListViewController: UIViewController {

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
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize header
        let title = "Professions"
        let details = "you can select up to 3 related professions"
        let description = NSMutableAttributedString(string: "\(title) (\(details))")
        description.addAttributes(
            [NSForegroundColorAttributeName: Constants.General.Color.TextColor,
                NSFontAttributeName: Constants.General.Font.DetailFont!],
            range: NSRange(location: 0, length: title.characters.count))
        description.addAttributes(
            [NSForegroundColorAttributeName: Constants.General.Color.ProfileTitleColor,
                NSFontAttributeName: Constants.General.Font.ProfileTitleFont!],
            range: NSRange(location: title.characters.count, length: details.characters.count + 3))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        description.addAttribute(NSParagraphStyleAttributeName,
                          value: style,
                          range: NSRange(location: 0, length: description.length))
        self.listDescription.attributedText = description
        self.listDescription.numberOfLines = 0
        self.avatarImageView.image = self.avatarImage
        self.headerView.backgroundColor = Constants.General.Color.LightBackgroundColor
        
        // Initializde collection view
        let flowLayout = NHAlignmentFlowLayout ()
        flowLayout.scrollDirection = .Vertical
        flowLayout.alignment = .TopLeftAligned
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.professionCollectionView.collectionViewLayout = flowLayout
        self.professionCollectionView.backgroundColor = UIColor.whiteColor()
        
        // Set delegates
        self.professionCollectionView.delegate = self
        self.professionCollectionView.dataSource = self
        
        // Register collection cell
        self.professionCollectionView.registerNib(UINib(nibName: "ProfileCollectionCell", bundle: nil),
                                     forCellWithReuseIdentifier: "ProfileCollectionCell")
        self.professionCollectionView.registerNib(UINib(nibName: "ProfessionSectionHeader", bundle: nil),
                                     forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                            withReuseIdentifier: "ProfessionSectionHeader")
        
        // Fetch profession data
        self.loadProfessions()
    }
    
    // MARK: Actions
    
    @IBAction func done(sender: AnyObject) {
        if let delegate = self.professionDelegate {
            delegate.finishProfessionSelection(selectedProfessions)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Help functions
    
    private func loadProfessions() {
        Profession.loadAllProfessions { (results, error) -> Void in
            guard let allProfessions = results as? [Profession] where results.count >= 0 && error == nil else {
                print("\(error)")
                return
            }
            
            self.professions = allProfessions.groupBy { (profession) -> String in
                return profession.category!
            }
                
            self.professionCategories = Array(self.professions.keys.sort())
                
            self.professionCollectionView.reloadData()
        }
    }
}

// MARK: Collection view delegate & data source

extension ProfessionListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.professionCategories.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let key = self.professionCategories[safe: section], category = self.professions[key] else {
            return 0
        }
        return category.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dequeueCell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionCell", forIndexPath: indexPath)
        
        
        guard let cell = dequeueCell as? ProfileCollectionCell,
            key = self.professionCategories[safe: indexPath.section],
            profession = self.professions[key]?[indexPath.row] else {
                return dequeueCell
        }

        cell.cellLabel.text = profession.name
        
        // Set styles for selected/unselected cells
        var isSelected = false
        for selectedProfession in self.selectedProfessions {
            if selectedProfession == profession {
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
        
        guard let sectionHeader = header as? ProfessionSectionHeader, key = self.professionCategories[safe: indexPath.section] else {
            return header
        }
        sectionHeader.titleLabel.text = key.uppercaseString
        
        return sectionHeader
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let key = self.professionCategories[safe: indexPath.section], profession = self.professions[key]?[indexPath.row], text = profession.name else {
                return CGSizeZero
        }
        
        return CGSize(width: text.getSizeWithFont(Constants.General.Font.ProfileCollectionFont!).width + 16, height: 24)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let key = self.professionCategories[safe: indexPath.section],
            categoryList = self.professions[key],
            profession = categoryList[safe: indexPath.row],
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? ProfileCollectionCell else { return }
        
        switch (cell.style) {
        case .Original:
            if self.selectedProfessions.count < 3 {
                self.selectedProfessions.insert(profession)
                cell.style = .Selected
            }
        case .Selected:
            for selectedProfession in self.selectedProfessions {
                if selectedProfession == profession {
                    self.selectedProfessions.remove(selectedProfession)
                    break
                }
            }
            cell.style = .Original
        }
    }
}

// MARK: Custome delegate

protocol ProfessionListDelegate {
    func finishProfessionSelection(selectedProfessions: Set<Profession>)
}
