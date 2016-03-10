//
//  ProfileListCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileListCell: ProfileCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet private weak var listStackView: UIStackView!
    
    private var elementList = [UIView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = Constants.General.Font.InputFont
        titleLabel.textColor = Constants.General.Color.BorderColor
        
        listStackView.alignment = .Fill
        listStackView.distribution = .Fill
        listStackView.spacing = 5
        listStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func drawRect(rect: CGRect) {
        elementList.append(UIView())
        for element in elementList {
            listStackView.addArrangedSubview(element)
        }
        
        super.drawRect(rect)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addListElement(item: UIView) {
        elementList.append(item)
    }
    
    func removeAllListElements() {
        elementList.removeAll()
        
        // Remove from stackview
        for element in listStackView.arrangedSubviews {
            element.removeFromSuperview()
        }
    }

}
