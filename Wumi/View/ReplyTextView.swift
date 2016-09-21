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
    weak var commentTextView: PostTextView!
    
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
        
        self.myAvatarView.image = Constants.General.Image.AnonymousAvatarImage
    }
    
    func reset() {
        self.commentTextView.placeholder = "Write a message"
        self.commentTextView.text = ""
    }
}
