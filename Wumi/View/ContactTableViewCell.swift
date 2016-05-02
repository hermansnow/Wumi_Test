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
    @IBOutlet weak var additionalButton: UIButton!
    @IBOutlet weak var additionalMenuButtonStack: UIStackView!
    @IBOutlet weak var emailButton: EmailButton!
    @IBOutlet weak var phoneButton: PhoneButton!
    @IBOutlet weak var privateMessageButton: PrivateMessageButton!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    private var topBorder = CALayer()
    private var bottomBorder = CALayer()
    private var leftBorder = CALayer()
    private var rightBorder = CALayer()
    
    private var additionalMenuButtons = [UIButton]()
    
    var delegate: protocol<FavoriteButtonDelegate, EmailButtonDelegate, PhoneButtonDelegate, PrivateMessageButtonDelegate>? {
        didSet {
            self.favoriteButton.delegate = self.delegate
            self.emailButton.delegate = self.delegate
            self.phoneButton.delegate = self.delegate
            self.privateMessageButton.delegate = self.delegate
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setProperty()
    }
    
    func setProperty() {
        self.topBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.bottomBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.leftBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.rightBorder.borderColor = Constants.General.Color.BackgroundColor.CGColor
        self.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.additionalMenuButtons = [self.privateMessageButton, self.emailButton, self.phoneButton]
        
        self.setButtonImages()
        
        self.addGesture()
        
        self.drawBorder()
        
        self.reset()
    }
    
    private func setButtonImages() {
        // Additional Menu button
        self.additionalButton.setBackgroundImage(UIImage(named: "More"), forState: .Normal)
        self.additionalButton.setBackgroundImage(UIImage(named: "More_Selected"), forState: .Selected)

    }
    
    private func addGesture() {
        self.additionalButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.manageAdditionalActions(_:))))
    }
    
    private func drawBorder() {
        self.topBorder.borderWidth = CGFloat(4.0)
        self.bottomBorder.borderWidth = CGFloat(4.0)
        self.leftBorder.borderWidth = CGFloat(8.0)
        self.rightBorder.borderWidth = CGFloat(8.0)
        
        self.layer.addSublayer(self.topBorder)
        self.layer.addSublayer(self.bottomBorder)
        self.layer.addSublayer(self.leftBorder)
        self.layer.addSublayer(self.rightBorder)
        self.layer.masksToBounds = true
    }
    
    func showAdditonalActions(showAdditonalActions: Bool, withAnimation animation: Bool) {
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
        
        if showAdditonalActions {
            self.additionalButton.selected = true
            if animation {
                self.contentStackView.insertArrangedSubview(self.additionalMenuButtonStack, atIndex: 2)
                
                UIView.animateKeyframesWithDuration(animationDuration, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                    let duration = animationDuration / Double(self.additionalMenuButtonStack.arrangedSubviews.count)
                    for index in 0..<self.additionalMenuButtonStack.arrangedSubviews.count {
                        guard let button = self.additionalMenuButtonStack.arrangedSubviews[safe: index] as? UIButton else { continue }
                        
                        UIView.addKeyframeWithRelativeStartTime(Double(index) * duration, relativeDuration: duration, animations: {
                            button.alpha = 1.0
                        })
                    }
                    
                    if !self.favoriteButton.selected && self.favoriteButton.enabled {
                        UIView.addKeyframeWithRelativeStartTime(Double(self.additionalMenuButtons.count) * duration, relativeDuration: duration, animations: {
                            self.favoriteButton.alpha = 1.0
                        })
                    }
                }, completion: nil)
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
        else {
            self.additionalButton.selected = false
            if animation {
                UIView.animateKeyframesWithDuration(animationDuration, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: {
                    let duration = animationDuration / Double(self.additionalMenuButtonStack.arrangedSubviews.count)
                    for index in 0..<self.additionalMenuButtons.count {
                        guard let button = self.additionalMenuButtonStack.arrangedSubviews[safe: index] as? UIButton else { continue }
                        
                        UIView.addKeyframeWithRelativeStartTime(Double(self.additionalMenuButtons.count - 1 - index) * duration, relativeDuration: duration, animations: {
                            button.alpha = 0.0
                        })
                    }
                    if !self.favoriteButton.selected || !self.favoriteButton.enabled {
                        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: duration, animations: {
                            self.favoriteButton.alpha = 0.0
                        })
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
    
    func reset() {
        self.avatarImageView.image = Constants.General.Image.AnonymousAvatarImage
        self.nameLabel.text = nil
        self.locationLabel.text = nil
        self.additionalButton.selected = false
        self.phoneButton.enabled = true
        self.privateMessageButton.enabled = true
        self.emailButton.enabled = true
        self.showAdditonalActions(false, withAnimation: false)
    }
    
    override func drawRect(rect: CGRect) {
        self.topBorder.frame = CGRect(x:0, y:0, width:rect.size.width, height:self.topBorder.borderWidth)
        self.bottomBorder.frame = CGRect(x:0, y:rect.size.height - self.bottomBorder.borderWidth, width:rect.size.width, height:self.bottomBorder.borderWidth)
        self.leftBorder.frame = CGRect(x: 0, y: 0, width: self.leftBorder.borderWidth, height: rect.size.height)
        self.rightBorder.frame = CGRect(x: rect.size.width - self.rightBorder.borderWidth, y: 0, width: self.rightBorder.borderWidth, height: rect.size.height)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self {
            return nil
        }
        else {
            return hitView
        }
    }
    
    func manageAdditionalActions(sender: UITapGestureRecognizer) {
        self.showAdditonalActions(!self.additionalButton.selected, withAnimation: true)
    }
}