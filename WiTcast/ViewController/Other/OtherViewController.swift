//
//  OtherViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/26/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift
import Material

class OtherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainTable: UITableView!
    
    var data: NSMutableArray = ["MOVIECAST", "THRONECAST"];
    var bgImage: NSMutableArray = ["Moviecast.png", "Thronecast.png"];
    
    let realm = try! Realm()
    var movie : Results<NormalEpisode>!
    var throne : Results<NormalEpisode>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Color.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OtherViewController.loadOther(_:)),name:NSNotification.Name(rawValue: "load_other"), object: nil)
        
        movie = realm.objects(NormalEpisode.self).filter("type = 'MOVIECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        throne = realm.objects(NormalEpisode.self).filter("type = 'THRONECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        
        self.mainTable.register(UINib(nibName: "OtherTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherTableViewCell");
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        if UIScreen.main.bounds.width == 414 {
            self.mainTable.rowHeight = 220.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.mainTable.rowHeight = 199.0
        }
        
        self.mainTable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadOther(_ notification: NSNotification){
        movie = realm.objects(NormalEpisode.self).filter("type = 'MOVIECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        throne = realm.objects(NormalEpisode.self).filter("type = 'THRONECAST'").sorted(byKeyPath: "episodeId", ascending: false)
        self.mainTable.reloadData();
    }
    
    // MARK: Table view processing
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherTableViewCell", for: indexPath as IndexPath) as! OtherTableViewCell
        
        cell.lblTitle.font = UIFont(name: font_header_regular, size: cell.lblTitle.font.pointSize);
        cell.lblItemCount.font = UIFont(name: font_header_regular, size: cell.lblItemCount.font.pointSize);
        
        cell.imgBG.image = UIImage(named: bgImage[indexPath.row] as! String);
        cell.lblTitle.text = "\(data[indexPath.row] as! String)";
        
        if indexPath.row == 0 {
            cell.lblItemCount.text = "\(movie.count) Item";
        }
        else {
            cell.lblItemCount.text = "\(throne.count) Item";
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemMainEpViewController(nibName: "ItemMainEpViewController", bundle: nil);
        vc.titleString = data[indexPath.row] as! String;
        let itemNev = ItemMainEpToolbarController(rootViewController: vc)
        navigationController?.pushViewController(itemNev, animated: true);
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
}

extension OtherViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "Other"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
