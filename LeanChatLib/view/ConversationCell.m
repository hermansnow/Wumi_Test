//
//  ConversationCell.m
//  Wumi
//
//  Created by JunpengLuo on 5/14/16.
//  Copyright © 2016 Parse. All rights reserved.
//

#import "ConversationCell.h"

@implementation ConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2.0;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.litteBadgeView.hidden = YES;
    _badgeView = [[JSBadgeView alloc]initWithParentView:self.avatarImageView alignment:JSBadgeViewAlignmentTopRight];
    
    _operationQueue = [[NSOperationQueue alloc]init];
}
+ (instancetype)cellForRowWithTableView:(UITableView *)tableView
{
    NSString * className = NSStringFromClass([self class]);
    
    [tableView registerNib:[UINib nibWithNibName:className bundle:nil] forCellReuseIdentifier:className];
//    return [tableView dequeueReusableCellWithIdentifier:className];
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
    if (cell == nil) {
        cell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] identifier]];
    }
    return cell;
}

+ (CGFloat)heightOfCell
{
    return 65;
}

- (void)setConversation:(AVIMConversation *)conversation
{
    if (conversation.type == CDConversationTypeSingle) {
        id <CDUserModelDelegate> user = [[CDChatManager manager].userDelegate getUserById:conversation.otherId];
        [self.operationQueue addOperationWithBlock:^{
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
        }];
        self.nameLabel.text = user.username;
    }
    else {
        [self.avatarImageView setImage:conversation.icon];
        self.nameLabel.text = conversation.displayName;
    }
    if (conversation.lastMessage) {
        self.messageTextLabel.attributedText = [[CDMessageHelper helper] attributedStringWithMessage:conversation.lastMessage conversation:conversation];
        self.timestampLabel.text = [[NSDate dateWithTimeIntervalSince1970:conversation.lastMessage.sendTimestamp / 1000] timeAgoSinceNow];
    }
    if (conversation.unreadCount > 0) {
        if (conversation.muted) {
            self.litteBadgeView.hidden = NO;
        } else {
            self.badgeView.badgeText = [NSString stringWithFormat:@"%ld", conversation.unreadCount];
        }
        self.litteBadgeView.hidden = NO;
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.badgeView.badgeText = nil;
    self.litteBadgeView.hidden = YES;
    self.messageTextLabel.text = nil;
    self.timestampLabel.text = nil;
    self.nameLabel.text = nil;
}

@end

