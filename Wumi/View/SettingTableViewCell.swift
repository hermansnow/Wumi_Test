//
//  SettingTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 1/5/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    /// Title of setting cell.
    var title: String? {
        get {
            return self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Help Functions
    
    /**
     Reset cell data.
     */
    func reset() {
        self.title = nil
    }
}
