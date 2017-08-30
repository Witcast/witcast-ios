//
//  FavouriteViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 6/12/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class FavouriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var imgEmpty: UIImageView!
    @IBOutlet var lblNoItem: UILabel!
    
    let realm = try! Realm()
    var lists : Results<ItemLocal>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Color.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FavouriteViewController.updateFavourite(_:)),name:NSNotification.Name(rawValue: "update_favourite"), object: nil)
        
        self.tableView.register(UINib(nibName: "FavouriteTableViewCell", bundle: nil), forCellReuseIdentifier: "FavouriteTableViewCell");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        let colorView = UIView();
        colorView.backgroundColor = UIColor.clear;
        
        UITableViewCell.appearance().selectedBackgroundView = colorView;
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
        
        self.initFont();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initUI();
    }
    
    func initFont(){
        lblNoItem.font = UIFont(name: font_header_regular, size: lblNoItem.font.pointSize);
    }
    
    func initUI() {
        lists = realm.objects(ItemLocal.self).filter("isFavourite = true")
        lblNoItem.text = "No Favorites Item";
        imgEmpty.image = UIImage(named: "empty-favourite.png");
        
        if lists.count == 0 {
            self.tableView.isHidden = true;
            self.imgEmpty.isHidden = false;
            self.lblNoItem.isHidden = false;
        }
        else {
            self.tableView.isHidden = false;
            self.imgEmpty.isHidden = true;
            self.lblNoItem.isHidden = true;
        }
        
        self.tableView.reloadData();
    }
    
    // MARK: Table view processing
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteTableViewCell", for: indexPath as IndexPath) as! FavouriteTableViewCell
        
        let dataTemp = lists[indexPath.row]
        let dataDetail = realm.objects(NormalEpisode.self).filter("episodeId = \(dataTemp.episodeId)")
        
        cell.lblTitle.text = dataDetail[0].title;
        cell.lblDetail.text = dataDetail[0].dsc;
        
        let URLString = dataDetail[0].miniImageUrl;
        let url = URL(string: URLString)!
        cell.imgMini.kf.setImage(with: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(lists[indexPath.row].episodeId, forKey: "episodeShow")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "open_play_view"), object: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    func updateFavourite(_ notification: NSNotification){
        self.initUI();
    }

}

extension FavouriteViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "Favorites"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
