//
//  AddChatViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 4/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class AddChatViewController: UIViewController {
    
    @IBOutlet weak var otherIdTextField: UITextField!
    
    @IBAction func goChat(sender: AnyObject) {
        if let otherId = otherIdTextField.text {
            CDChatManager.sharedManager().fetchConversationWithOtherId(otherId, callback: { (conv: AVIMConversation!, error: NSError!) -> Void in
                if (error != nil) {
                    print("error: \(error)")
                } else {
                    let chatRoomVC = ChatRoomViewController(conversation: conv)
                    self.navigationController?.pushViewController(chatRoomVC, animated: true)
                }
            })
        }
    }
}
