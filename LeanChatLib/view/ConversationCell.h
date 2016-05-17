//
//  ConversationCell.h
//  Wumi
//
//  Created by JunpengLuo on 5/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView/JSBadgeView.h"
#import <AVOSCloudIM/AVIMConversation.h>
#import "AVIMConversation+Custom.h"
#import "CDChatManager.h"
#import "UIView+XHRemoteImage.h"
#import "CDMessageHelper.h"
#import <DateTools/DateTools.h>

@interface ConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIView *litteBadgeView;
@property (nonatomic, strong) JSBadgeView *badgeView;
@property(nonatomic,strong)AVIMConversation * conversation;
@property(nonatomic,strong)NSOperationQueue * operationQueue;
+ (instancetype)cellForRowWithTableView:(UITableView *)tableView;
+ (CGFloat)heightOfCell;

@end
