/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material

class AppSearchBarController: SearchBarController {
    fileprivate var backButton: IconButton!
    fileprivate var moreButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareMenuButton()
        prepareMoreButton()
        prepareStatusBar()
        prepareSearchBar()
    }
}

extension AppSearchBarController: UITextFieldDelegate {
    fileprivate func prepareMenuButton() {
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor.black
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreVertical)
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        
        // Access the statusBar.
//        statusBar.backgroundColor = Color.green.base
    }
    
    fileprivate func prepareSearchBar() {
        searchBar.leftViews = [backButton]
//        searchBar.rightViews = [moreButton]
        statusBar.backgroundColor = UIColor.white // CustomFunc.UIColorFromRGB(rgbValue: colorMain)
        searchBar.backgroundColor = UIColor.white // CustomFunc.UIColorFromRGB(rgbValue: colorMain)
        searchBar.textColor = UIColor.black
        searchBar.textField.font = UIFont(name: font_regular, size: (searchBar.textField.font?.pointSize)!);
        searchBar.textField.returnKeyType = .done
        searchBar.textField.delegate = self
        backButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        return false
    }
    
    func buttonAction(sender: UIButton!) {
        _ = navigationController?.popViewController(animated: true);
    }
}

