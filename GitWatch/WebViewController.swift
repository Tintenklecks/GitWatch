//
//  WebViewController.swift
//  GitWatch
//
//  Created by Ingo on 17.05.16.
//  Copyright © 2016 Ingo. All rights reserved.
//

import UIKit
import RealmSwift

class WebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var favoriteButton: UIButton!
    var gitRepo:GITRealm! = nil
	var loaded: Bool = false
	var _repositoryURL = ""
	var repositoryURL: String {
		get {
			return _repositoryURL
		}
		set {
			if webView != nil {
				loaded = true

				let replaced = (newValue as NSString).stringByReplacingOccurrencesOfString("git://", withString: "https://")

				let url = NSURL(string: replaced)

				webView.delegate = self
				webView!.loadRequest(NSURLRequest(URL: url!))
			}
			_repositoryURL = newValue
		}
	}

	@IBOutlet weak var webView: UIWebView!

	override func viewWillAppear(animated: Bool) {
		super.viewDidAppear(animated)

		webView.scalesPageToFit = true
		print(webView.scrollView.contentInset)

		webView.scrollView.contentInset = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)

		if !loaded && repositoryURL != "" {
			repositoryURL = _repositoryURL // load it
		}
		webView.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        

	}
	func webViewDidFinishLoad(webView: UIWebView) {
		let top = CGPointMake(0, 0); // can also use CGPointZero here
		webView.scrollView.setContentOffset(top, animated: true)

		webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

	}

    @IBAction func openInSafari(sender: AnyObject) {
        let url = NSURL(string: repositoryURL)
        if url != nil {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    

    
    
    @IBAction func selectAsFavorite(sender: UIButton) {
        
        if gitRepo != nil   {
            
            
            try! Realm().write({
                gitRepo.favorite = !gitRepo.favorite
                favoriteButton.selected = gitRepo.favorite

                try! Realm().add(gitRepo, update: true)
            })
            
            
        }
    }
}
