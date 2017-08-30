//
//  DonateViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 10/16/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController {
    
    @IBOutlet var lblTitleBankAccount: UILabel!
    @IBOutlet var lblTitlePaypal: UILabel!
    @IBOutlet var lblTitleInApp: UILabel!
    @IBOutlet var lblBankAccount: UILabel!
    @IBOutlet var lblPaypal: UILabel!
    @IBOutlet var lblInApp: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        prepareToolbar()
        
        self.initFont();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initFont(){
        lblTitleBankAccount.font = UIFont(name: font_header_regular, size: lblTitleBankAccount.font.pointSize);
        lblTitlePaypal.font = UIFont(name: font_header_regular, size: lblTitlePaypal.font.pointSize);
        lblTitleInApp.font = UIFont(name: font_header_regular, size: lblTitleInApp.font.pointSize);
        lblBankAccount.font = UIFont(name: font_regular, size: lblBankAccount.font.pointSize);
        lblPaypal.font = UIFont(name: font_regular, size: lblPaypal.font.pointSize);
        lblInApp.font = UIFont(name: font_regular, size: lblInApp.font.pointSize);
    }
    
}

extension DonateViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "Support WiTcast"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
