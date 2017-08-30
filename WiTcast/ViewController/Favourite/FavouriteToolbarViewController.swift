//
//  FavouriteToolbarViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 6/12/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import Material

class FavouriteToolbarViewController: ToolbarController {
    fileprivate var menuButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareMenuButton()
        prepareStatusBar()
        prepareToolbar()
    }
}

extension FavouriteToolbarViewController {
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
    }
    
    func buttonAction(sender: UIButton!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menu"), object: nil)
    }
}
