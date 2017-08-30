//
//  AboutToolbarViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 4/15/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import Material

class AboutToolbarViewController: ToolbarController {
    fileprivate var menuButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareMenuButton()
        prepareStatusBar()
        prepareToolbar()
    }
}

extension AboutToolbarViewController {
    fileprivate func prepareMenuButton() {
        menuButton = IconButton(image: Icon.cm.menu, tintColor: .black)
        menuButton.pulseColor = .white
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = CustomFunc.UIColorFromRGB(rgbValue: colorMain)
    }
    
    fileprivate func prepareToolbar() {
        toolbar.backgroundColor = CustomFunc.UIColorFromRGB(rgbValue: colorMain)
        toolbar.leftViews = [menuButton]
        
        menuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        toolbar.title = "About"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
    
    func buttonAction(sender: UIButton!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menu"), object: nil)
    }
}
