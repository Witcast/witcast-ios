//
//  SearchViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 3/22/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import Material
import RealmSwift
import XLActionController
import Social
import Whisper
import PopupDialog

class SearchViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var noteView: UILabel!
    
    internal lazy var heights = [IndexPath: CGFloat]()
    let realm = try! Realm()
    var lists : Results<NormalEpisode>!
    var textSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.loadSearch(_:)),name:NSNotification.Name(rawValue: "update_search"), object: nil)
        
        view.backgroundColor = Color.grey.lighten5
        self.lists = realm.objects(NormalEpisode.self).filter("episodeId = 0")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = nil
        
        self.tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearchTableViewCell")
        prepareSearchBar()
        self.tableView.isHidden = true
        self.emptyView.isHidden = false
        
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 69))
        
        self.noteView.font = UIFont(name: font_light, size: self.noteView.font.pointSize);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSearch(_ notification: NSNotification){
        if (self.textSearch == "") {
            self.lists = realm.objects(NormalEpisode.self).filter("episodeId = 0")
            self.tableView.reloadData()
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("dsc BEGINSWITH '\(self.textSearch)'").sorted(byKeyPath: "onAir", ascending: false)
            self.tableView.reloadData()
        }
    }
}

extension SearchViewController: SearchBarDelegate {
    internal func prepareSearchBar() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        
        searchBar.delegate = self
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        searchBar.endEditing(true)
        textField.text = text
        
        if (textField.text! == "") {
            self.lists = realm.objects(NormalEpisode.self).filter("episodeId = 0")
            self.tableView.reloadData()
            
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("dsc BEGINSWITH '\(textField.text!)'").sorted(byKeyPath: "onAir", ascending: false)
            self.textSearch = textField.text!
            self.tableView.reloadData()
            
            if lists.count == 0 {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
            else {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            }
        }
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        if (textField.text! == "") {
            self.lists = realm.objects(NormalEpisode.self).filter("episodeId = 0")
            self.tableView.reloadData()
            
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        }
        else {
            lists = realm.objects(NormalEpisode.self).filter("dsc BEGINSWITH '\(textField.text!)'").sorted(byKeyPath: "onAir", ascending: false)
            self.textSearch = textField.text!
            self.tableView.reloadData()
            
            if lists.count == 0 {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
            else {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Prepares the cells within the tableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell

        cell.reloadData(data: lists[indexPath.row])
        cell.favoriteButton.tag = indexPath.row;
        cell.downloadButton.tag = indexPath.row + 1000;
        cell.shareButton.tag = indexPath.row + 2000;
        
        cell.favoriteButton.addTarget(self, action: #selector(selectFunction), for: .touchUpInside);
        cell.downloadButton.addTarget(self, action: #selector(selectFunction), for: .touchUpInside);
        cell.shareButton.addTarget(self, action: #selector(selectFunction), for: .touchUpInside);
        
        heights[indexPath] = cell.height
        return cell
    }
    
    func selectFunction(sender: UIButton!) {
        
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
                        updateData.downloadPercent = dataDownload[0].downloadPercent
                        updateData.lastDulation = dataDownload[0].lastDulation
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
        else {
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
        
        tableView.reloadData();
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIScreen.main.bounds.width == 414 {
            return heights[indexPath] ?? 337.00
        }
        else if UIScreen.main.bounds.width == 375 {
            return heights[indexPath] ?? 324.00
        }
        else {
            return heights[indexPath] ?? 305.00
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.set(lists[indexPath.row].episodeId, forKey: "episodeShow")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "open_play_view"), object: nil)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true);
    }
}
