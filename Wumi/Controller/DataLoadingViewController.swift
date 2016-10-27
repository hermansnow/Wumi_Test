//
//  DataLoadingViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 10/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DataLoadingViewController: UIViewController {
    private lazy var loadingView = LoadingIndicatorView() // Loading indicator for async operations
    
    func showLoadingIndicator() {
        self.loadingView.frame.size = CGSize(width: 40, height: 40)
        self.loadingView.center = self.view.center
        self.loadingView.startAnimating()
        self.view.addSubview(loadingView)
    }
    
    func hideLoadingIndicator() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}
