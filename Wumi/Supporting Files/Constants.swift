//
//  Constants.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//
import UIKit
import Foundation

struct Constants {
    
    struct General {
        
        struct Color {
            static let TintColor = UIColor.whiteColor()
            static let TitleColor = UIColor.whiteColor()
            static let BackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
            static let ThemeColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
            static let InputTextColor = UIColor(red: 51/255, green: 52/255, blue: 53/255, alpha: 1.0)
            static let BorderColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
            static let ErrorColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
            static let MaskColor = UIColor(white: 1.0, alpha: 0.9)
        }
        
        struct Font {
            static let InputFont = UIFont(name: ".SFUIText-Light", size: 16)
            static let ErrorFont = UIFont(name: ".SFUIText-Light", size: 12)
            static let LinkButtonFont = UIFont(name: ".SFUIText-Medium", size: 14)
            static let ButtonFont = UIFont(name: ".SFUIText-Medium", size: 16)
        }
        
        struct Image {
            static let Add = UIImage(named: "Add")
            static let Favorite = UIImage(named: "Favorite")
            static let AnonymousAvatarImage = UIImage(named: "Anonymous")
        }
    }
    
    struct SignIn {
        
        struct Color {
            static let MaskColor = UIColor(white: 1.0, alpha: 0.2)
        }
        
        struct Image {
            static let AddAvatarImage = UIImage(named: "Add")
        }
        
        struct Size {
            static let ShadowOffset = CGSize(width: 0, height: 2)
        }
        
        struct Proportion {
            static let MaskHeightWithParentView: CGFloat = 144 / 220
            static let MaskWidthWithHeight: CGFloat = 1.0
        }
        
        struct Value {
            static let shadowOpacity: Float = 1.0
            static let shadowRadius: CGFloat = 3.0
        }
        
        struct String {
            
            static let forgotPasswordLink = "Forgot Password?"
            
            struct ErrorMessages {
                static let incorrectPassword = "Incorrect password"
            }
            
            struct Alert {
                
                struct ResetPassword {
                    static let Title = "Reset Password"
                    static let Message = "Please enter the email address for your account"
                }
                struct ResetPasswordConfirm {
                    static let Title = "Request Sent"
                    static let Message = "Please check your registered email account for resetting password"

                }
                struct AddImageSheet {
                    static let Title = "Add Avatar Image"
                    static let Message = "Choose a photo as your avatar image"
                }
            }
        }
    }
    
} 