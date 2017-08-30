//
//  MenuViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 2/23/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var lblVersion: UILabel!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var mainTable: UITableView!
    
    var indexMenu = 0;
    let menu = ["New Feed", "WiTcast", "WiTcast Special", "WiTThai", "Other", "Favorites", "Download", "Support WiTcast", "About"];
    let img = ["newfeed.png", "witcast.png", "special.png", "witthai.png", "other.png", "favorite.png", "download.png", "donate.png", "about.png"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.mainTable.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell");
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        if UIScreen.main.bounds.width == 414 {
            self.mainTable.rowHeight = 60.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.mainTable.rowHeight = 55.0
        }
        
        self.initUI();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI(){
        lblVersion.font = UIFont(name: font_header_regular, size: lblVersion.font.pointSize);
        lblTitle.font = UIFont(name: font_header_regular, size: lblTitle.font.pointSize);
        
        imgLogo.layer.cornerRadius = imgLogo.frame.size.width / 2;
        imgLogo.clipsToBounds = true;
        imgLogo.layer.borderWidth = 2.0;
        imgLogo.layer.borderColor = UIColor.black.cgColor;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath as IndexPath) as! MenuTableViewCell
        
        cell.lblTitle.font = UIFont(name: font_header_regular, size: cell.lblTitle.font.pointSize)!;
        cell.lblTitle.text = "\(self.menu[indexPath.row])";
        cell.imgDot.image = UIImage(named: img[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
        
        self.closeSideMenu();
        UserDefaults.standard.set(indexPath.row, forKey: "index")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
}
