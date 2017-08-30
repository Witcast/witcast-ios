//
//  ItemMainEpViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/18/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class ItemMainEpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var maintable: UITableView!
    
    var titleString = "";
    var epID = 1;
    let realm = try! Realm()
    var lists : Results<NormalEpisode>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Color.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ItemMainEpViewController.loadItem(_:)),name:NSNotification.Name(rawValue: "load_item"), object: nil)

        if titleString == "MOVIECAST" {
            lists = realm.objects(NormalEpisode.self).filter("type = 'MOVIECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else if titleString == "THRONECAST" {
            lists = realm.objects(NormalEpisode.self).filter("type = 'THRONECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("mainEpisodeId = \(epID)").sorted(byKeyPath: "episodeId", ascending: true)
        }
        
        self.maintable.register(UINib(nibName: "ItemMainEpTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemMainEpTableViewCell");
        self.maintable.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        self.maintable.register(UINib(nibName: "ItemMainEpHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemMainEpHeaderTableViewCell");
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        if UIScreen.main.bounds.width == 414 {
            self.maintable.rowHeight = 139.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.maintable.rowHeight = 126.0
        }
        
        self.maintable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 69))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadItem(_ notification: NSNotification){
        if titleString == "MOVIECAST" {
            lists = realm.objects(NormalEpisode.self).filter("type = 'MOVIECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else if titleString == "THRONECAST" {
            lists = realm.objects(NormalEpisode.self).filter("type = 'THRONECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("mainEpisodeId = \(epID)").sorted(byKeyPath: "episodeId", ascending: false)
        }
        self.maintable.reloadData();
    }
    
    // MARK: Table view processing
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemMainEpTableViewCell", for: indexPath) as! ItemMainEpTableViewCell
        
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
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "ItemMainEpHeaderTableViewCell") as! ItemMainEpHeaderTableViewCell
        
        headerCell.lblEpisode.font = UIFont(name: font_header_regular, size: headerCell.lblEpisode.font.pointSize);
        headerCell.lblEpisode.text = lists[section].title;
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0;
    }
}

extension ItemMainEpViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = titleString
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
