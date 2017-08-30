//
//  PlayerDetailViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 3/29/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift

class PlayerDetailViewController: UIViewController, UIWebViewDelegate {
    
    internal var titleTab: String = ""
    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let realm = try! Realm()
    var isPlay = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webview.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var index = 1;
        var episodeNow = 1;
        var episodeShow = 1;
        if (UserDefaults.standard.object(forKey: "episodeNow") as? Int) != nil {
            episodeNow = UserDefaults.standard.object(forKey: "episodeNow") as! Int;
        }

        if (UserDefaults.standard.object(forKey: "episodeShow") as? Int) != nil {
            episodeShow = UserDefaults.standard.object(forKey: "episodeShow") as! Int;
        }
        
        if (episodeNow == episodeShow) {
            self.isPlay = true
        }
        
        if (self.isPlay == true) {
            index = episodeNow;
        }
        else {
            index = episodeShow;
        }

        let data = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
        
        let url = NSURL (string: data[0].detail);
        let requestObj = NSURLRequest(url: url! as URL);
        webview.loadRequest(requestObj as URLRequest);
        
        backButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        backButton.isEnabled = webview.canGoBack
        nextButton.isEnabled = webview.canGoForward
    }

    func initView(titleTab: String) {
        self.titleTab = titleTab
        preparePageTabBarItem()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        webview.goBack()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        webview.goForward()
    }

}

/// PageTabBar.
extension PlayerDetailViewController {
    internal func preparePageTabBarItem() {
        tabItem.title = self.titleTab
        tabItem.titleColor = .black
        tabItem.titleLabel?.font = UIFont(name: font_header_regular, size: 20);
    }
}
