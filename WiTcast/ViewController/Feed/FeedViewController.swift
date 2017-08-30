//
//  FeedViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 2/23/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import XLActionController
import RealmSwift
import Social
import Material
import Whisper
import PopupDialog

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView : UITableView!
    
    let realm = try! Realm()
    var lists : Results<NormalEpisode>!
    
    // MARK: class properties
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        prepareToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.loadFeed(_:)),name:NSNotification.Name(rawValue: "load_feed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.loadFeed(_:)),name:NSNotification.Name(rawValue: "update_feed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.gotoTop(_:)),name:NSNotification.Name(rawValue: "gotoTop"), object: nil)
        
        let taobaoHeader = FeedRefreshHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        _ = self.tableView.setUpHeaderRefresh(taobaoHeader) { _ in
            
            if (self.currentReachabilityStatus == .reachableViaWiFi) || (self.currentReachabilityStatus == .reachableViaWWAN) {
                InitialData.loadData();
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_data_end"), object: nil)
            }
        }
        self.tableView.beginHeaderRefreshing()
        
        lists = realm.objects(NormalEpisode.self).sorted(byKeyPath: "onAir", ascending: false)
        
        self.tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: "feedCell");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        self.tableView.register(UINib(nibName: "FeedHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedHeaderTableViewCell");
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 129))
        
        if UIScreen.main.bounds.width == 414 {
            self.tableView.rowHeight = 330.0
        }
        else if UIScreen.main.bounds.width == 375 {
            self.tableView.rowHeight = 305.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFeed(_ notification: NSNotification){
        lists = realm.objects(NormalEpisode.self).sorted(byKeyPath: "onAir", ascending: false)
        self.tableView.reloadData();
        self.tableView.endHeaderRefreshing()
    }
    
    // MARK: Table view processing
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath as IndexPath) as! FeedTableViewCell
        
        cell.lblTitle.font = UIFont(name: font_regular, size: cell.lblTitle.font.pointSize);
        cell.favouriteButton.tag = indexPath.section;
        cell.downloadButton.tag = indexPath.section + 1000;
        cell.shareButton.tag = indexPath.section + 2000;
        cell.btnViewDetail.tag = indexPath.section + 3000;
        
        cell.favouriteButton.image = Icon.favorite
        cell.downloadButton.image = Icon.arrowDownward
        cell.shareButton.image = Icon.cm.share
        cell.shareButton.tintColor = Color.blueGrey.base
        
        cell.lblTitle.text = lists[indexPath.section].dsc;
        
        let URLString = lists[indexPath.section].coverImageUrl;
        let url = URL(string: URLString)
        cell.imgBackgroud.kf.setImage(with: url)
        
        cell.favouriteButton.addTarget(self, action: #selector(FeedViewController.selectFunction(_:)), for: .touchUpInside);
        cell.downloadButton.addTarget(self, action: #selector(FeedViewController.selectFunction(_:)), for: .touchUpInside);
        cell.shareButton.addTarget(self, action: #selector(FeedViewController.selectFunction(_:)), for: .touchUpInside);
        cell.btnViewDetail.addTarget(self, action: #selector(FeedViewController.selectFunction(_:)), for: .touchUpInside);
        
        let dataLocal = realm.objects(ItemLocal.self).filter("episodeId = \(lists[indexPath.section].episodeId)")
        if dataLocal.count > 0 {
            if dataLocal[0].isFavourite == false {
                cell.favouriteButton.tintColor = Color.blueGrey.base
            }
            else {
                cell.favouriteButton.tintColor = Color.red.base
            }
            
            if (dataLocal[0].downloadStatus == "Done") || (dataLocal[0].downloadStatus == "Downloading") {
                cell.downloadButton.tintColor = Color.red.base
            }
            else {
                cell.downloadButton.tintColor = Color.blueGrey.base
            }
        }
        else {
            cell.favouriteButton.tintColor = Color.blueGrey.base
            cell.downloadButton.tintColor = Color.blueGrey.base
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "FeedHeaderTableViewCell") as! FeedHeaderTableViewCell
        
        headerCell.lblTitleCategory.font = UIFont(name: font_header_regular, size: headerCell.lblTitleCategory.font.pointSize);
        headerCell.lblDate.font = UIFont(name: font_header_regular, size: headerCell.lblDate.font.pointSize);
        
        headerCell.lblTitleCategory.text = "\(lists[section].title)";
        headerCell.lblDate.text = CustomFunc.getDateShow(dateIn: lists[section].onAir) as String;
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0;
    }
    
    func selectFunction(_ sender: UIButton!) {
        
        if (sender.tag < 1000) {
            let dataTemp = lists[sender.tag];
            let dataFavourite = realm.objects(ItemLocal.self).filter("episodeId = \(dataTemp.episodeId)")
            
            let updateData = ItemLocal()
            if dataFavourite.count == 0 {
                updateData.episodeId = dataTemp.episodeId
                updateData.downloadStatus = "None"
                updateData.isFavourite = true
                updateData.downloadPath = ""
                updateData.downloadPercent = 0
                updateData.lastDulation = 0.0
            }
            else {
                updateData.episodeId = dataFavourite[0].episodeId
                updateData.downloadStatus = dataFavourite[0].downloadStatus
                updateData.downloadPath = dataFavourite[0].downloadPath
                updateData.downloadPercent = dataFavourite[0].downloadPercent
                updateData.lastDulation = dataFavourite[0].lastDulation

                if (dataFavourite[0].isFavourite) == true {
                    updateData.isFavourite = false;
                }
                else{
                    updateData.isFavourite = true;
                }
            }
            
            try! realm.write {
                realm.add(updateData, update: true)
            }
        }
        else if (sender.tag >= 1000 && sender.tag < 2000) {
            
            if UserDefaults.standard.integer(forKey: "downloadCount") == 2 {
                let popup = PopupDialog(title: "ขออภัยค่ะ!", message: "ตอนนี้มีไฟล์ที่กำลังโหลดอยู่ 2 ไฟล์ เพื่อความมีเสถียรภาพกรุณาให้ไฟล์ใดไฟล์หนึ่งโหลดเสร็จสิ้นก่อนนะคะ", buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                }
                
                let buttonOK = DefaultButton(title: "OK") {
                    
                }
                
                popup.addButtons([buttonOK])
                self.present(popup, animated: true, completion: nil)
            }
            else {
                let downloadNow = UserDefaults.standard.integer(forKey: "downloadCount")
                UserDefaults.standard.set((downloadNow + 1), forKey: "downloadCount")
                
                let dataTemp = lists[(sender.tag - 1000)];
                let dataDownload = realm.objects(ItemLocal.self).filter("episodeId = \(dataTemp.episodeId)")
                
                if dataDownload.count == 0 {
                    let updateData = ItemLocal()
                    updateData.episodeId = dataTemp.episodeId
                    updateData.downloadStatus = "Downloading"
                    updateData.isFavourite = false
                    updateData.downloadPath = ""
                    updateData.downloadPercent = 0
                    updateData.lastDulation = 0.0
                    
                    try! realm.write {
                        realm.add(updateData, update: true)
                    }
                    
                    InitialData.downloadFile(indexEpisode: updateData.episodeId, url: dataTemp.fileUrl)
                    
                    let announcement = Announcement(title: "Downloading", subtitle: "ตอนนี้กำลังดาวน์โหลดไฟล์จ้า อย่าพึ่งปิดแอพนะคะ สามารถตรวจสอบสถานะได้ที่เมนู Download", image: UIImage(named: "p-bun.png"))
                    Whisper.show(shout: announcement, to: navigationController!, completion: {
                        print("The shout was silent.")
                    })
                }
                else {
                    if dataDownload[0].downloadStatus == "None" {
                        let updateData = ItemLocal()
                        updateData.episodeId = dataDownload[0].episodeId
                        updateData.downloadStatus = "Downloading"
                        updateData.downloadPath = dataDownload[0].downloadPath
                        updateData.lastDulation = dataDownload[0].lastDulation
                        updateData.downloadPercent = dataDownload[0].downloadPercent
                        updateData.isFavourite = dataDownload[0].isFavourite;
                        
                        try! realm.write {
                            realm.add(updateData, update: true)
                        }
                        
                        InitialData.downloadFile(indexEpisode: updateData.episodeId, url: dataTemp.fileUrl)
                        
                        let announcement = Announcement(title: "Downloading", subtitle: "ตอนนี้กำลังดาวน์โหลดไฟล์จ้า อย่าพึ่งปิดแอพนะคะ สามารถตรวจสอบสถานะได้ที่เมนู Download", image: UIImage(named: "p-bun.png"))
                        Whisper.show(shout: announcement, to: navigationController!, completion: {
                            print("The shout was silent.")
                        })
                    }
                }
            }
        }
        else if (sender.tag >= 2000 && sender.tag < 3000) {
            let dataTemp = lists[(sender.tag - 2000)];
            
            let actionController = PeriscopeActionController()
            actionController.headerData = "Do you want to share this track?"
            actionController.addAction(Action("Share on Twitter", style: .cancel, handler: { action in
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
                    let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
                    vc?.add(URL(string: dataTemp.fileUrl))
                    vc?.setInitialText("I'm listening @twitcast3 \(dataTemp.title) \(dataTemp.dsc)")
                    self.present(vc!, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            actionController.addAction(Action("Share on Facebook", style: .cancel, handler: { action in
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
                    let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
                    vc?.add(URL(string: dataTemp.fileUrl))
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            actionController.addAction(Action("Cancel", style: .destructive, handler: { action in
            }))
            present(actionController, animated: true, completion: nil)
        }
        else {
            UserDefaults.standard.set(lists[(sender.tag - 3000)].episodeId, forKey: "episodeShow")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "open_play_view"), object: nil)
        }
        
        tableView.reloadData();
    }
    
    func gotoTop(_ notification: NSNotification){
        self.tableView.setContentOffset(CGPoint.zero, animated: true);
    }
}

extension FeedViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "New Feed"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
