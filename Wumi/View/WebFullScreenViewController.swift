//
//  WebFullScreenViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 7/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import WebKit

class WebFullScreenViewController: UIViewController {

    private var progressBar = UIProgressView()
    private var progressTimer = NSTimer()
    private var isFinished: Bool = false
    
    var url: NSURL? {
        didSet {
            self.loadUrl()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.requiresUserActionForMediaPlayback = true
        let webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.allowsLinkPreview = true
        webView.allowsBackForwardNavigationGestures = true
        
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fullscreenView = self.view as? WKWebView {
            fullscreenView.navigationDelegate = self
            fullscreenView.UIDelegate = self
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: .Plain, target: self, action: #selector(WebFullScreenViewController.displayShareSheet(_:)))
        
        self.addProgressBar()
        
        self.loadUrl()
    }
    
    private func addProgressBar() {
        self.progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        self.progressBar.progress = 0.0
        self.progressBar.tintColor = Constants.General.Color.ProgressColor
        
        self.view.addSubview(self.progressBar)
    }
    
    // MARK: Help functions
    
    private func loadUrl() {
        guard let url = self.url else { return }
        
        if let fullscreenView = self.view as? WKWebView {
            let request = NSURLRequest(URL: url)
            fullscreenView.loadRequest(request)
        }
    }
    
    private func updateBackButton() {
        if let fullscreenView = self.view as? WKWebView where fullscreenView.canGoBack {
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
        if let fullscreenView = self.view as? WKWebView where fullscreenView.canGoBack {
            fullscreenView.goBack()
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

// MARK: WKNavigation delegate

extension WebFullScreenViewController:  WKNavigationDelegate {
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.progressBar.progress = 0.0
        self.isFinished = false
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/60,
                                                                    target: self,
                                                                    selector: #selector(self.progressTimerCallBack),
                                                                    userInfo: nil,
                                                                    repeats: true)
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        self.isFinished = true
    }
    
    // Update progress bar. The progress bar will stay at 95% if the web is still in loading after 0.9 second.
    func progressTimerCallBack() {
        if isFinished {
            if self.progressBar.progress >= 1 {
                self.progressBar.hidden = true
                self.progressTimer.invalidate()
            }
            else {
                self.progressBar.progress += 0.1
            }
        }
        else {
            self.progressBar.progress += 0.05
            if self.progressBar.progress >= 0.95 {
                self.progressBar.progress = 0.95
            }
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // Update web view controller's navigation bar title with page title
        if let navigationController = self.navigationController, topItem = navigationController.navigationBar.topItem {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            titleLabel.textAlignment = .Center
            titleLabel.font = Constants.General.Font.ButtonFont
            titleLabel.backgroundColor = Constants.General.Color.ThemeColor
            titleLabel.textColor = Constants.General.Color.TintColor
            titleLabel.adjustsFontSizeToFitWidth = false
            titleLabel.lineBreakMode = .ByTruncatingTail
            titleLabel.text = webView.title
            topItem.titleView = titleLabel
        }
        
        // Update navigation bar items
        self.updateBackButton()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        // Try open if with URL
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? NSURL where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
            if webView.canGoBack {
                webView.goBack()
            }
        }
        // Otherwise, show error
        else {
            if let path = NSBundle.mainBundle().pathForResource("error", ofType: "html") {
                do {
                    let html = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    webView.loadHTMLString(html, baseURL: nil)
                }
                catch {
                    return
                }
            }
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        if error.code == -999 { return } // TODO: Not sure about this error code
        
        // Try open if with URL
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? NSURL where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
            if webView.canGoBack {
                webView.goBack()
            }
        }
        // Otherwise, show error
        if let path = NSBundle.mainBundle().pathForResource("error", ofType: "html") {
            do {
                let html = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                webView.loadHTMLString(html, baseURL: nil)
            }
            catch {
                return
            }
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.URL else { return }
        
        if url.willOpenInApp() {
            decisionHandler(.Cancel)
            return
        }
        
        decisionHandler(.Allow)
    }
}

// MARK: WKUI delegate

extension WebFullScreenViewController: WKUIDelegate {
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle target=_blank links by opening them in the same view
        if navigationAction.targetFrame == nil {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
}
