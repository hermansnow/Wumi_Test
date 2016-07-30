//
//  WebFullScreenView.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class WebFullScreenView: UIView {
    
    @IBOutlet weak var webView: UIWebView!
    
    var delegate: protocol<UIWebViewDelegate>? {
        didSet {
            self.webView.delegate = self.delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize web view
        self.webView.allowsInlineMediaPlayback = true
        self.webView.allowsLinkPreview = true
        self.webView.allowsPictureInPictureMediaPlayback = true
        self.webView.dataDetectorTypes = .All
        self.webView.keyboardDisplayRequiresUserAction = true
    }
}