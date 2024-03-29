//
//  ReplyTextView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/24/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class ReplyTextView: UIView {
    
    @IBOutlet weak var myAvatarView: AvatarImageView!
    @IBOutlet weak var commentTextView: PlaceholderTextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commentTextView.characterLimit = 300  // Limitation for lenght of comment
        self.commentTextView.placeholder = "Write a message"
        
        self.myAvatarView.image = UIImage(named: Constants.General.ImageName.AnonymousAvatar)
    }
    
    func reset() {
        self.commentTextView.placeholder = "Write a message"
        self.commentTextView.text = ""
    }
}
