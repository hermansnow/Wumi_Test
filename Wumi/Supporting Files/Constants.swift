//
//  Constants.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//
import UIKit
import Foundation
//import ReachabilitySwift

struct Constants {
    
    struct General {
        static let TabBarItemDidClickSelf = "TabBarItemDidClickSelf"
        static let CustomURLIdentifier = "CustomURLIdentifier"
        static let SchemeWhiteList = ["about"]
        static let ReachabilityChangedNotification = "reachabilityTODO"
        //static let ReachabilityChangedNotification = ReachabilitySwift.ReachabilityChangedNotification

        struct Color {
            static let TintColor = UIColor.whiteColor()
            static let TitleColor = UIColor.whiteColor()
            static let BackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
            static let ThemeColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1.0)
            static let TextColor = UIColor(red: 51/255, green: 52/255, blue: 53/255, alpha: 1.0)
            static let BorderColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
            static let ErrorColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
            static let LightBackgroundColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1.0)
            static let ProfileTitleColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
            static let MaskColor = UIColor(white: 1.0, alpha: 0.9)
            static let LightMaskColor = UIColor(white: 1.0, alpha: 0.6)
            static let DarkMaskColor = UIColor(white: 0.0, alpha: 0.6)
            static let ProgressColor = UIColor(hexString: "#00bfff")
        }
        
        struct Font {
            static let InputFont = UIFont(name: ".SFUIText-Light", size: 16)
            static let ErrorFont = UIFont(name: ".SFUIText-Light", size: 12)
            static let LinkButtonFont = UIFont(name: ".SFUIText-Medium", size: 14)
            static let ButtonFont = UIFont(name: ".SFUIText-Medium", size: 16)
            static let DetailFont = UIFont(name: ".SFUIText-Bold", size: 16)
            static let ProfileTitleFont = UIFont(name: ".SFUIText-Regular", size: 14)
            static let ProfileNameFont = UIFont(name: ".STHeitiSC-Medium", size: 18)
            static let ProfileLocationFont = UIFont(name: ".SFUIText-Regular", size: 16)
            static let ProfileCollectionFont = UIFont(name: ".SFUIText-Regular", size: 14)
            static let ProfileTextFont = UIFont(name: ".SFUIText-Regular", size: 16)
        }
        
        struct Image {
            static let Logo = UIImage(named: "Logo")
            static let AnonymousAvatarImage = UIImage(named: "Anonymous")
            static let Check = UIImage(named: "Checkmark")
            static let Uncheck = UIImage(named: "Uncheck")
        }
        
        struct Size {
            struct AvatarThumbnail {
                static let Height = 40.0
                static let Width = 62.5
            }
            struct AvatarImage {
                static let WidthHeightRatio = 375.0 / 240.0
            }
        }
    }
    
    struct SignIn {
        struct Color {
            static let MaskColor = UIColor(white: 1.0, alpha: 0.2)
        }
        
        struct Image {
            static let AddAvatarImage = UIImage(named: "Add_Photo")
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
    
    struct InvitationCode {
        struct String {
            struct ErrorMessages {
                static let incorrenctInvitationCode = "Incorrenct invitation code"
            }
        }
    }
    
    struct Post {
        static let maximumImages = 5 // number of images allows to be attached in a post
        
        struct Image {
            static let TabBarIcon = UIImage(named: "Notification")
            static let TabBarSelectedIcon = UIImage(named: "Home")
            static let Star = UIImage(named: "Star")
            static let Reply = UIImage(named: "Reply")
        }
        
        struct Font {
            static let ListCurrentUserBanner  = UIFont(name: ".SFUIText-Medium", size: 16)
            static let ListTitle = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
            static let ListUserBanner = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
            static let ListContent = UIFont(name: ".SFUIText-Light", size: 16)
            static let ListTimeStamp = UIFont(name: ".SFUIText-Regular", size: 14)
            static let ListButton = UIFont(name: ".SFUIText-Medium", size: 14)
            static let ListReply = UIFont(name: ".SFUIText-Regular", size: 14)
        }
        
        struct  Color {
            static let ListDetailText = UIColor(red: 164/255, green: 164/255, blue: 164/255, alpha: 1.0)
        }
        
        struct Size {
            struct Thumbnail {
                static let Height = 100
                static let Width = 100
            }
        }
    }
    
    struct Query {
        static let LoadUserLimit = 200 // number of user records load in each query
        static let LoadPostLimit = 100 // number of post records load in each query
        static let searchTimeInterval = 0.3 // seconds to start search. UISearchController will only search results if end-users stop inputting with this time interval
    }
    
    struct Notification {
        struct Image {
            static let TabBarIcon = UIImage(named: "Notification")
        }
    }
} 
