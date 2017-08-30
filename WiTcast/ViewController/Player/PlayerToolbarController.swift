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

class PlayerToolbarController: ToolbarController {
    fileprivate var downButton: IconButton!
    fileprivate var bellButton: IconButton!
    fileprivate var shareButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareDownButton()
        prepareShareButton()
        prepareStatusBar()
        prepareToolbar()
    }
}

extension PlayerToolbarController {
    fileprivate func prepareDownButton() {
        downButton = IconButton(image: Icon.cm.arrowDownward, tintColor: .black)
        downButton.pulseColor = .white
    }
    
    fileprivate func prepareShareButton() {
        bellButton = IconButton(image: Icon.cm.bell, tintColor: .black)
        bellButton.pulseColor = .white
        shareButton = IconButton(image: Icon.cm.share, tintColor: .black)
        shareButton.pulseColor = .white
    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = CustomFunc.UIColorFromRGB(rgbValue: colorMain)
    }
    
    fileprivate func prepareToolbar() {
        downButton.tag = 0
        bellButton.tag = 1
        shareButton.tag = 2
        
        toolbar.title = "Track Detail"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
        
        toolbar.depthPreset = .none
        toolbar.backgroundColor = CustomFunc.UIColorFromRGB(rgbValue: colorMain)
        toolbar.leftViews = [downButton]
//        toolbar.rightViews = [bellButton, shareButton]
        
        downButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        bellButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        shareButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    func buttonAction(sender: UIButton!) {
        if sender.tag == 0 {
            self.dismiss(animated: true, completion: nil)
        }
        else if sender.tag == 1 {
        
        }
        else {
            
        }
    }
}
