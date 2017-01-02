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
    private lazy var loadingView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.frame.size = CGSize(width: 40, height: 40)
        view.center = self.view.center
        return view
    }()
    
    /**
     Show loading indicator.
     */
    func showLoadingIndicator() {
        self.loadingView.startAnimating()
        self.view.addSubview(loadingView)
    }
    
    /**
     Dismiss loading indicator.
     */
    func dismissLoadingIndicator() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}
