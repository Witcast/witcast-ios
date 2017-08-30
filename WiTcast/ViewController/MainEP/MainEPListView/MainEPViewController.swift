//
//  MainEPViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/17/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Kingfisher

class MainEPViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mainTable: UITableView!
    
    let realm = try! Realm()
    var lists : Results<MainEpisode>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Color.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainEPViewController.loadMain(_:)),name:NSNotification.Name(rawValue: "load_main"), object: nil)
        
        lists = realm.objects(MainEpisode.self)
        
        self.mainTable.register(UINib(nibName: "MainEPTableViewCell", bundle: nil), forCellReuseIdentifier: "MainEPTableViewCell");
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        self.mainTable.register(UINib(nibName: "MainEPHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "MainEPHeaderTableViewCell");
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        if UIScreen.main.bounds.width == 414 {
            self.mainTable.rowHeight = 211.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.mainTable.rowHeight = 198.0
        }
        
        self.mainTable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMain(_ notification: NSNotification){
        lists = realm.objects(MainEpisode.self)
        self.mainTable.reloadData();
    }
    
    // MARK: Table view processing
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainEPTableViewCell", for: indexPath as IndexPath) as! MainEPTableViewCell
        
        cell.lblDetail.font = UIFont(name: font_regular, size: cell.lblDetail.font.pointSize);
        cell.lblDetail.text = "\(lists[indexPath.section].dsc)";
        
        let URLString = lists[indexPath.section].imageUrl;
        let url = URL(string: URLString)!
        cell.imgBackgroud.kf.setImage(with: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemMainEpViewController(nibName: "ItemMainEpViewController", bundle: nil);
        vc.titleString = lists[indexPath.section].title;
        vc.epID = lists[indexPath.section].mainEpisodeId;
        let itemNav = ItemMainEpToolbarController(rootViewController: vc)
        navigationController?.pushViewController(itemNav, animated: true);
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "MainEPHeaderTableViewCell") as! MainEPHeaderTableViewCell
        
        headerCell.lblEpTitle.font = UIFont(name: font_header_regular, size: headerCell.lblEpTitle.font.pointSize);
        headerCell.lblItemCount.font = UIFont(name: font_header_regular, size: headerCell.lblItemCount.font.pointSize);
        
        headerCell.lblEpTitle.text = "\(lists[section].title)";
        headerCell.lblItemCount.text = "\(lists[section].subEpisodeCount) Part";
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0;
    }
}

extension MainEPViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "WiTcast"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
