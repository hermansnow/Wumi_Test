//
//  ChatListViewController.swift
//  Wumi
//
//  Created by JunpengLuo on 4/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

class ChatListViewController: CDChatListVC, CDChatListVCDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "tabbar_chat_active")
        self.tabBarItem.image = image
        
        self.chatListDelegate = self
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(ChatListViewController.addButtonClicked))
        self.navigationItem.rightBarButtonItem = addItem
    }
    
    func addButtonClicked() {
        let storyboard = UIStoryboard(name: "Inbox", bundle: nil)
        let addVC = storyboard.instantiateViewControllerWithIdentifier("AddChat")
        addVC.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func viewController(viewController: UIViewController!, didSelectConv conv: AVIMConversation!) {
        let vc = ChatRoomViewController(conversation: conv)
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setBadgeWithTotalUnreadCount(totalUnreadCount: Int) {
        if (totalUnreadCount > 0) {
            self.navigationController?.tabBarItem.badgeValue = "\(totalUnreadCount)"
        } else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
}