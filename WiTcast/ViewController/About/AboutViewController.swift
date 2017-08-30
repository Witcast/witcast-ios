//
//  AboutViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/17/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var dscText: UITextView!
    @IBOutlet weak var tanthaiLabel: UILabel!
    @IBOutlet weak var tanthaiFacbookLabel: UILabel!
    @IBOutlet weak var pongpangLabrl: UILabel!
    @IBOutlet weak var pongpangFacebookLabel: UILabel!
    @IBOutlet weak var ahbubLabel: UILabel!
    @IBOutlet weak var ahbunFacebookLabel: UILabel!
    @IBOutlet weak var tanthaiImage: UIImageView!
    @IBOutlet weak var pongpangImage: UIImageView!
    @IBOutlet weak var ahbunImage: UIImageView!
    @IBOutlet weak var modLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
        
        self.titleLabel.font = UIFont(name: font_header_regular, size: self.titleLabel.font.pointSize);
        self.facebookLabel.font = UIFont(name: font_regular, size: self.facebookLabel.font.pointSize);
        self.dscText.font = UIFont(name: font_regular, size: (self.dscText.font?.pointSize)!);
        self.tanthaiLabel.font = UIFont(name: font_regular, size: self.tanthaiLabel.font.pointSize);
        self.tanthaiFacbookLabel.font = UIFont(name: font_regular, size: self.tanthaiFacbookLabel.font.pointSize);
        self.pongpangLabrl.font = UIFont(name: font_regular, size: self.pongpangLabrl.font.pointSize);
        self.pongpangFacebookLabel.font = UIFont(name: font_regular, size: self.pongpangFacebookLabel.font.pointSize);
        self.ahbubLabel.font = UIFont(name: font_regular, size: self.ahbubLabel.font.pointSize);
        self.ahbunFacebookLabel.font = UIFont(name: font_regular, size: self.ahbunFacebookLabel.font.pointSize);
        self.modLabel.font = UIFont(name: font_header_regular, size: self.modLabel.font.pointSize);
        
        tanthaiImage.layer.cornerRadius = tanthaiImage.frame.size.width / 2;
        tanthaiImage.clipsToBounds = true;
        tanthaiImage.layer.borderWidth = 2.0;
        tanthaiImage.layer.borderColor = UIColor.white.cgColor;
        
        pongpangImage.layer.cornerRadius = pongpangImage.frame.size.width / 2;
        pongpangImage.clipsToBounds = true;
        pongpangImage.layer.borderWidth = 2.0;
        pongpangImage.layer.borderColor = UIColor.white.cgColor;
        
        ahbunImage.layer.cornerRadius = ahbunImage.frame.size.width / 2;
        ahbunImage.clipsToBounds = true;
        ahbunImage.layer.borderWidth = 2.0;
        ahbunImage.layer.borderColor = UIColor.white.cgColor;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
