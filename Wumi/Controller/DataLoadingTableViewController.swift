//
//  DataLoadingTableViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 10/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DataLoadingTableViewController: UITableViewController {
    /// Loading indicator for async operations.
    private lazy var loadingView = LoadingIndicatorView()
    
    /**
     Show loading indicator.
     */
    func showLoadingIndicator() {
        self.loadingView.frame.size = CGSize(width: 40, height: 40)
        self.loadingView.center = self.view.center
        self.loadingView.startAnimating()
        self.view.addSubview(loadingView)
        self.view.bringSubviewToFront(loadingView)
    }
    
    /**
     Dismiss loading indicator.
     */
    func dismissLoadingIndicator() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}
