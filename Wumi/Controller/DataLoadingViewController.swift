//
//  DataLoadingViewController.swift
//  Wumi
//
//  Created by Zhe Cheng on 10/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class DataLoadingViewController: UIViewController {
    
    /// Loading indicator for async operations.
    private var loadingView: LoadingIndicatorView {
        let view = LoadingIndicatorView()
        view.frame.size = CGSize(width: 40, height: 40)
        view.center = self.view.center
        return view
    }
    
    /// Whether the controller is loading or not.
    var isLoading: Bool = false
    
    /**
     Show loading indicator.
     */
    func showLoadingIndicator() {
        self.loadingView.startAnimating()
        self.view.addSubview(self.loadingView)
        self.isLoading = true
    }
    
    /**
     Dismiss loading indicator.
     */
    func dismissLoadingIndicator() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
        self.isLoading = false
    }
}
