//
//  SpecialViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/26/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class SpecialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainTable: UITableView!
    
    let realm = try! Realm()
    var lists : Results<NormalEpisode>!
    var isSpecial = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SpecialViewController.loadSpecial(_:)),name:NSNotification.Name(rawValue: "load_special"), object: nil)
        
        self.mainTable.register(UINib(nibName: "SpecialTableViewCell", bundle: nil), forCellReuseIdentifier: "SpecialTableViewCell");
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        self.mainTable.register(UINib(nibName: "SpecialHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "SpecialHeaderTableViewCell");
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        self.mainTable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
        
        if UIScreen.main.bounds.width == 414 {
            self.mainTable.rowHeight = 139.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.mainTable.rowHeight = 126.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (isSpecial == true) {
            lists = realm.objects(NormalEpisode.self).filter("type = 'SPECIAL'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("type = 'WITTHAI'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        
        self.mainTable.reloadData();
    }
    
    func loadSpecial(_ notification: NSNotification){
        if (isSpecial == true) {
            lists = realm.objects(NormalEpisode.self).filter("type = 'SPECIAL'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("type = 'WITTHAI'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        
        self.mainTable.reloadData();
    }
    
    // MARK: Table view processing
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialTableViewCell", for: indexPath as IndexPath) as! SpecialTableViewCell
        
        cell.lblDetail.font = UIFont(name: font_regular, size: cell.lblDetail.font.pointSize);
        cell.lblDetail.text = lists[indexPath.section].dsc;
        
        let URLString = lists[indexPath.section].mainImageUrl;
        let url = URL(string: URLString)
        cell.imgBg.kf.setImage(with: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(lists[indexPath.section].episodeId, forKey: "episodeShow")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "open_play_view"), object: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "SpecialHeaderTableViewCell") as! SpecialHeaderTableViewCell
        
        headerCell.lblEpisode.font = UIFont(name: font_header_regular, size: headerCell.lblEpisode.font.pointSize);
        headerCell.lblEpisode.text = lists[section].title;
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0;
    }
}

extension SpecialViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        if (isSpecial == true) {
            toolbar.title = "WiTcast Special"
        }
        else {
            toolbar.title = "WiTThai"
        }
        
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
