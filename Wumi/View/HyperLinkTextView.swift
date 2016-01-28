//
//  HyperLinkTextView.swift
//  Wumi
//
//  Created by Herman on 11/5/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

class HyperLinkTextView: UITextView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var hyperLinkText: String?
    
    var hyperLinkActions = [String: [String: AnyObject]] ()
    
    func parseHyperLinkText() {
        if let hyperLinkString = self.hyperLinkText {
            var wordLocation = CGPoint(x: 0.0, y: 0.0);
            var wordEnd = wordLocation
            let innerLabel = UILabel()
            
            // Split hyperlink text into pieces. All hyperLink piece should be wrapped in format: ##<signiture>Content##
            let stringPieces = hyperLinkString.componentsSeparatedByString("##")
            
            // Parse each piece of hyper link text
            for piece in stringPieces {
                if piece.characters.count == 0 { continue }
                
                var hyperLinkPrefix = ""
                for prefix in self.hyperLinkActions.keys {
                    if (piece.hasPrefix(prefix)) {
                        hyperLinkPrefix = prefix
                        break
                    }
                }
                
                // Create UILabel for each string piece
                let label = UILabel()
                label.font = UIFont.systemFontOfSize(12.0)
                if hyperLinkPrefix.characters.count > 0 {
                    label.text = piece.stringByReplacingOccurrencesOfString(hyperLinkPrefix, withString: "")
                    label.textColor = UIColor.yellowColor()
                    // Add hyperlink actions
                    if let action = self.hyperLinkActions[hyperLinkPrefix] {
                        let tapGesture = UITapGestureRecognizer(target: action["target"], action: Selector(action["selector"] as! String))
                        label.addGestureRecognizer(tapGesture)
                        label.userInteractionEnabled = true
                    }
                }
                else {
                    label.text = piece
                    label.textColor = UIColor.whiteColor()
                }
                
                //
                label.sizeToFit()
                if self.frame.size.width < wordLocation.x + label.bounds.size.width {
                    wordLocation.x = 0.0;                       // move this word all the way to the left...
                    wordLocation.y += label.frame.size.height;  // ...on the next line
                }
                
                // Set the location for this label:
                label.frame = CGRect(x: wordLocation.x, y: wordLocation.y, width: label.frame.size.width, height: label.frame.size.height);
                
                // Show this label:
                innerLabel.addSubview(label)
                
                // Update the horizontal position for the next word:
                wordLocation.x += label.frame.size.width;
                
                // Update word ending point
                wordEnd.x = wordLocation.x
                wordEnd.y = wordLocation.y + label.frame.size.height
            }
            innerLabel.frame.size = CGSize(width: wordEnd.x, height: wordEnd.y)
            innerLabel.frame.origin = CGPoint(x: (self.frame.size.width - innerLabel.frame.size.width) / 2, y: (self.frame.size.height - innerLabel.frame.size.height) / 2)
            innerLabel.userInteractionEnabled = true
            
            for view in self.subviews {
                view.removeFromSuperview()
            }
            self.addSubview(innerLabel)
        }
    }
    
    

}
