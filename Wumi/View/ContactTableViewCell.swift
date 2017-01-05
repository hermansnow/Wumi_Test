//
//  ContactTableViewCell.swift
//  Wumi
//
//  Created by Zhe Cheng on 2/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var additionalButton: MoreButton!
    @IBOutlet weak var additionalMenuButtonStack: UIStackView!
    @IBOutlet weak var emailButton: EmailButton!
    @IBOutlet weak var phoneButton: PhoneButton!
    @IBOutlet weak var privateMessageButton: PrivateMessageButton!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    /// Top border layer.
    private var topBorder = CALayer()
    /// Bottom border layer.
    private var bottomBorder = CALayer()
    /// Left border layer.
    private var leftBorder = CALayer()
    /// Right border layer.
    private var rightBorder = CALayer()
    
    /// Array of additional buttons in more menu.
    private var additionalMenuButtons = [UIButton]()
    
    /// Contact table view cell delegate, this delegate will also be assigned as delegate for FavoriteButton, EmailButton, PhoneButton, PrivateMessageButton and MoreButton.
    var delegate: protocol<FavoriteButtonDelegate, EmailButtonDelegate, PhoneButtonDelegate, PrivateMessageButtonDelegate, MoreButtonDelegate>? {
        didSet {
            self.favoriteButton.delegate = self.delegate
            self.emailButton.delegate = self.delegate
            self.phoneButton.delegate = self.delegate
            self.privateMessageButton.delegate = self.delegate
            self.additionalButton.delegate = self.delegate
        }
    }
    
    // MARK: Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.drawBorder()
        
        self.reset()
    }
    
    override func drawRect(rect: CGRect) {
        // Set border frames
        self.topBorder.frame = CGRect(x: 0,
                                      y: 0,
                                      width: rect.size.width,
                                      height: self.topBorder.borderWidth)
        self.bottomBorder.frame = CGRect(x: 0,
                                         y: rect.size.height - self.bottomBorder.borderWidth,
                                         width: rect.size.width,
                                         height: self.bottomBorder.borderWidth)
        self.leftBorder.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.leftBorder.borderWidth,
                                       height: rect.size.height)
        self.rightBorder.frame = CGRect(x: rect.size.width - self.rightBorder.borderWidth,
                                        y: 0,
                                        width: self.rightBorder.borderWidth,
                                        height: rect.size.height)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        // Disable hit test for the cell but enable hit test for subviews.
        if hitView == self {
            return nil
        }
        else {
            return hitView
        }
    }
    
    // MARK: Help Functions
    
    /**
     Set properties for the cell.
     */
    private func setProperty() {
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        // Set border property
        self.topBorder.borderWidth = CGFloat(4.0)
        self.bottomBorder.borderWidth = CGFloat(4.0)
        self.leftBorder.borderWidth = CGFloat(8.0)
        self.rightBorder.borderWidth = CGFloat(8.0)
        self.topBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.bottomBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.leftBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.rightBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
    }
    
    /**
     Draw border for the cell.
     */
    private func drawBorder() {
        self.layer.addSublayer(self.topBorder)
        self.layer.addSublayer(self.bottomBorder)
        self.layer.addSublayer(self.leftBorder)
        self.layer.addSublayer(self.rightBorder)
        self.layer.masksToBounds = true
    }
    
    /**
     Show additional actions.
     
     - Parameters:
        - showAdditonalActions: Flag to indicate whether we are going to show additional menu or hide it.
        - withAnimation: Flag to indicate whether we will show/hide additional menu with animation or not.
     */
    func showAdditionalActions(showAdditonalActions show: Bool, withAnimation animation: Bool) {
        let animationDuration = 0.5
        
        // Compose additional menu buttons
        for button in self.additionalMenuButtons {
            if button.enabled {
                self.additionalMenuButtonStack.insertArrangedSubview(button, atIndex: 0)
            }
            else {
                self.additionalMenuButtonStack.removeArrangedSubview(button)
            }
        }
        
        // Show additional action menu
        if show {
            self.additionalButton.selected = true
            if animation {
                self.contentStackView.insertArrangedSubview(self.additionalMenuButtonStack, atIndex: 2)
                
                UIView.animateKeyframesWithDuration(animationDuration,
                                                    delay: 0.0,
                                                    options: UIViewKeyframeAnimationOptions.CalculationModePaced,
                                                    animations: {
                                                        let duration = animationDuration / Double(self.additionalMenuButtonStack.arrangedSubviews.count)
                                                        for index in 0..<self.additionalMenuButtonStack.arrangedSubviews.count {
                                                            guard let button = self.additionalMenuButtonStack.arrangedSubviews[safe: index] as? UIButton else { continue }
                        
                                                            UIView.addKeyframeWithRelativeStartTime(Double(index) * duration,
                                                                                                    relativeDuration: duration)
                                                            {
                                                                button.alpha = 1.0
                                                            }
                                                        }
                    
                                                        if !self.favoriteButton.selected && self.favoriteButton.enabled {
                                                            UIView.addKeyframeWithRelativeStartTime(Double(self.additionalMenuButtons.count) * duration,
                                                                                                    relativeDuration: duration)
                                                            {
                                                                self.favoriteButton.alpha = 1.0
                                                            }
                                                        }
                                                    },
                                                    completion: nil)
            }
            else {
                for button in self.additionalMenuButtonStack.arrangedSubviews {
                    button.alpha = 1.0
                }
                if !self.favoriteButton.selected && self.favoriteButton.enabled {
                    self.favoriteButton.alpha = 1.0
                }
            }
        }
        // Hide additional action menu
        else {
            self.additionalButton.selected = false
            if animation {
                UIView.animateKeyframesWithDuration(animationDuration,
                                                    delay: 0.0,
                                                    options: UIViewKeyframeAnimationOptions.CalculationModePaced,
                                                    animations: {
                                                        let duration = animationDuration / Double(self.additionalMenuButtonStack.arrangedSubviews.count)
                                                        for index in 0..<self.additionalMenuButtons.count {
                                                            guard let button = self.additionalMenuButtonStack.arrangedSubviews[safe: index] as? UIButton else { continue }
                        
                                                            UIView.addKeyframeWithRelativeStartTime(Double(self.additionalMenuButtons.count - 1 - index) * duration,
                                                                                                    relativeDuration: duration)
                                                            {
                                                                button.alpha = 0.0
                                                            }
                                                        }
                                                        
                                                        if !self.favoriteButton.selected || !self.favoriteButton.enabled {
                                                            UIView.addKeyframeWithRelativeStartTime(0,
                                                                                                    relativeDuration: duration)
                                                            {
                                                                self.favoriteButton.alpha = 0.0
                                                            }
                                                        }
                                                    },
                                                    completion: { (success) -> Void in
                                                        self.contentStackView.removeArrangedSubview(self.additionalMenuButtonStack)
                                                    })
            }
            else {
                for button in self.additionalMenuButtonStack.arrangedSubviews {
                    button.alpha = 0.0
                }
                self.contentStackView.removeArrangedSubview(self.additionalMenuButtonStack)
                
                if !self.favoriteButton.selected || !self.favoriteButton.enabled {
                    self.favoriteButton.alpha = 0.0
                }
            }
        }
    }
    
    /**
     Reset the cell.
     */
    func reset() {
        self.avatarImageView.image = UIImage(named: Constants.General.ImageName.AnonymousAvatar)
        self.nameLabel.text = nil
        self.locationLabel.text = nil
        self.additionalButton.selected = false
        self.phoneButton.enabled = true
        self.privateMessageButton.enabled = true
        self.emailButton.enabled = true
        self.favoriteButton.enabled = true
        self.additionalMenuButtons = [self.privateMessageButton, self.emailButton, self.phoneButton]
        self.showAdditionalActions(showAdditonalActions: false, withAnimation: false)
    }
}
