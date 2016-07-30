//
//  WebFullScreenViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class WebFullScreenViewController: UIViewController {

    var url: NSURL? {
        didSet {
            self.loadUrl()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        if let view = UINib(nibName: "WebFullScreenView", bundle: NSBundle(forClass: self.classForCoder)).instantiateWithOwner(self, options: nil).first as? UIView {
            view.frame = self.view.frame
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let fullscreenView = self.view as? WebFullScreenView else { return }
        
        fullscreenView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: .Plain, target: self, action: #selector(WebFullScreenViewController.displayShareSheet(_:)))
        
        self.loadUrl()
    }
    
    // MARK: Help functions
    
    private func loadUrl() {
        guard let url = self.url, fullscreenView = self.view as? WebFullScreenView else { return }
        
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: NSTimeInterval(300))
        
        fullscreenView.webView.loadRequest(request)
    }
    
    private func updateBackButton() {
        guard let fullscreenView = self.view as? WebFullScreenView else { return }
        
        if fullscreenView.webView.canGoBack {
            if self.navigationItem.hidesBackButton == false {
                self.navigationItem.hidesBackButton = true
                let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(WebFullScreenViewController.backPage(_:)))
                let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(WebFullScreenViewController.closeView(_:)))
                self.navigationItem.leftBarButtonItems = [backButton, closeButton]
            }
        }
        else {
            self.navigationItem.leftBarButtonItems = nil
            self.navigationItem.hidesBackButton = false
        }
    }
    
    // MARK: Actions
    
    func backPage(sender: AnyObject?) {
        guard let fullscreenView = self.view as? WebFullScreenView else { return }
        
        if fullscreenView.webView.canGoBack {
            fullscreenView.webView.goBack()
        }
    }
    
    func closeView(sender: AnyObject?) {
        if let navigationController = self.navigationController {
            navigationController.popViewControllerAnimated(true)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func displayShareSheet(sender: AnyObject?) {
        guard let url = self.url else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

extension WebFullScreenViewController: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        // Update navigation bar items
        self.updateBackButton()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        guard let fullscreenView = self.view as? WebFullScreenView else { return }
        
        // Update web view controller's navigation bar title with page title
        if let navigationController = self.navigationController, topItem = navigationController.navigationBar.topItem {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            titleLabel.textAlignment = .Center
            titleLabel.font = Constants.General.Font.ButtonFont
            titleLabel.backgroundColor = Constants.General.Color.ThemeColor
            titleLabel.textColor = Constants.General.Color.TintColor
            titleLabel.adjustsFontSizeToFitWidth = false
            titleLabel.lineBreakMode = .ByTruncatingTail
            titleLabel.text = fullscreenView.webView.stringByEvaluatingJavaScriptFromString("document.title")
            topItem.titleView = titleLabel
        }
        
        // Update navigation bar items
        self.updateBackButton()
    }
}
