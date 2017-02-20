//
//  ChatRoomViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 4/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ChatRoomViewController: CDChatRoomVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func textView(textView: SETextView, clickedOnLink link: SELinkText, atIndex charIndex: UInt) -> Bool {
        guard let URL = NSURL(string: link.text) else { return false }
        // Launch application if it can be handled by any app installed
        if URL.willOpenInApp != nil {
            UIApplication.sharedApplication().openURL(URL)
        }
            // Otherwise, request it in web viewer
        else {
            let webVC = WebFullScreenViewController()
            webVC.url = URL
            
            self.navigationController?.pushViewController(webVC, animated: true)
        }
        return false;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
