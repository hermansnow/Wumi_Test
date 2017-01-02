//
//  Constants.swift
//  Wumi
//
//  Created by Zhe Cheng on 3/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//
import UIKit
import Foundation
import ReachabilitySwift

struct Constants {
    
    struct General {
        static let TabBarItemDidClickSelf = "TabBarItemDidClickSelf"
        static let CustomURLIdentifier = "CustomURLIdentifier"
        static let SchemeWhiteList = ["about"]
        static let ReachabilityChangedNotification = ReachabilitySwift.ReachabilityChangedNotification

        struct Color {
            static let TintColor = UIColor.whiteColor()
            static let TitleColor = UIColor.whiteColor()
            static let BackgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
            static let ThemeColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1.0)
            static let TextColor = UIColor(red: 51/255, green: 52/255, blue: 53/255, alpha: 1.0)
            static let BorderColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
            static let LightBorderColor = UIColor(hexString: "#a8a8a8")
            static let ErrorColor = UIColor(red: 241/255, green: 81/255, blue: 43/255, alpha: 1)
            static let LightBackgroundColor = UIColor(red: 240/255, green: 241/255, blue: 242/255, alpha: 1.0)
            static let ProfileTitleColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
            static let MaskColor = UIColor(white: 1.0, alpha: 0.9)
            static let LightMaskColor = UIColor(white: 1.0, alpha: 0.6)
            static let DarkMaskColor = UIColor(white: 0.0, alpha: 0.6)
            static let ProgressColor = UIColor(hexString: "#00bfff")
        }
        
        struct Font {
            static let InputFont = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
            static let ErrorFont = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
            static let LinkButtonFont = UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)
            static let ButtonFont = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
            static let DetailFont = UIFont.systemFontOfSize(16, weight: UIFontWeightBold)
            static let ProfileTitleFont = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
            static let ProfileNameFont = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
            static let ProfileLocationFont = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
            static let ProfileCollectionFont = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
            static let ProfileTextFont = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
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
            
            /**
             Struct includes error messages for sign in/up.
             */
            struct ErrorMessages {
                /// Error message to indicate unknow error.
                static let unknown = "Unknow issue occurred"
                /// Error message to indicate username is blank.
                static let blankUsername = "Username is blank"
                /// Error message to indicate username string is shorter than 3 characters.
                static let shortUsername =  "Length of user name should larger than 3 characters"
                /// Error message to indicate password is blank.
                static let blankPassword = "Password is blank"
                /// Error message to indicate password string is shorter than 3 characters.
                static let shortPassword = "Length of user password should larger than 3 characters"
                /// Error message to indicate password not match with confirmed password
                static let passwordNotMatch = "Passwords entered not match"
                /// Error message to indicate sign-in username or password is incorrect.
                static let incorrectPassword = "Incorrect username or password"
                /// Error message to indicate sign-up invitation code is blank.
                static let blankInvitationCode = "Invitation code is blank"
                /// Error message to indicate sign-up invitation code is invalid.
                static let invalidInvitationCode = "Invitation code is invalid"
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
            static let ListCurrentUserBanner  = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
            static let ListTitle = UIFont.systemFontOfSize(16, weight: UIFontWeightRegular)
            static let ListUserBanner = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
            static let ListContent = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
            static let ListTimeStamp = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
            static let ListButton = UIFont.systemFontOfSize(14, weight: UIFontWeightMedium)
            static let ListReply = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
        }
        
        struct  Color {
            static let Placeholder = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
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
