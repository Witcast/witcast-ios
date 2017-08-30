//
//  DownloadViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 9/24/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import XLActionController
import PopupDialog
import Whisper

class DownloadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView : UITableView!
    @IBOutlet var imgEmpty: UIImageView!
    @IBOutlet var lblNoItem: UILabel!
    
    let realm = try! Realm()
    var lists : Results<ItemLocal>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.updateDownload(_:)),name:NSNotification.Name(rawValue: "updateDownload"), object: nil)
        
        view.backgroundColor = Color.white
        prepareToolbar()
        
        self.tableView.register(UINib(nibName: "DownloadTableViewCell", bundle: nil), forCellReuseIdentifier: "DownloadTableViewCell");
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
        lists = realm.objects(ItemLocal.self).filter("downloadStatus = 'Done' OR downloadStatus = 'Downloading'")
        lblNoItem.text = "No Download Item";
        imgEmpty.image = UIImage(named: "empty-download.png");
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell", for: indexPath as IndexPath) as! DownloadTableViewCell
        
        let dataTemp = lists[indexPath.row]
        let dataDetail = realm.objects(NormalEpisode.self).filter("episodeId = \(dataTemp.episodeId)")
        
        cell.lblTitle.text = dataDetail[0].title;
        cell.lblDetail.text = dataDetail[0].dsc;
        cell.statusLabel.text = "Status:  \(lists[indexPath.row].downloadStatus)";
        cell.percentLebel.text = "\(lists[indexPath.row].downloadPercent) %"
        
        if dataTemp.downloadStatus == "Downloading" {
            cell.moreButton.isHidden = true
        }
        else {
            cell.moreButton.isHidden = false
        }
        
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(DownloadViewController.selectFunction(_:)), for: .touchUpInside);
        
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
    
    func selectFunction(_ sender: UIButton!) {
        
        let dataTemp = lists[sender.tag];
        
        let actionController = PeriscopeActionController()
        actionController.headerData = "Pleast select action."
        actionController.addAction(Action("Delete", style: .cancel, handler: { action in
            InitialData.deleteFile(indexEpisode: dataTemp.episodeId)
        }))
        
        if (dataTemp.downloadStatus != "Done") || (dataTemp.downloadStatus != "Downloading") {
            actionController.addAction(Action("Download again", style: .cancel, handler: { action in
                
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
                    
                    let dataDownload = self.realm.objects(NormalEpisode.self).filter("episodeId = \(dataTemp.episodeId)")
                    
                    let updateData = ItemLocal()
                    updateData.episodeId = dataTemp.episodeId
                    updateData.downloadStatus = "Downloading"
                    updateData.downloadPath = dataTemp.downloadPath
                    updateData.lastDulation = dataTemp.lastDulation
                    updateData.downloadPercent = dataTemp.downloadPercent
                    updateData.isFavourite = dataTemp.isFavourite;
                    
                    try! self.realm.write {
                        self.realm.add(updateData, update: true)
                    }
                    
                    InitialData.downloadFile(indexEpisode: updateData.episodeId, url: dataDownload[0].fileUrl)
                    
                    let announcement = Announcement(title: "Downloading", subtitle: "ตอนนี้กำลังดาวน์โหลดไฟล์จ้า อย่าพึ่งปิดแอพนะคะ สามารถตรวจสอบสถานะได้ที่เมนู Download", image: UIImage(named: "p-bun.png"))
                    Whisper.show(shout: announcement, to: self.navigationController!, completion: {
                        print("The shout was silent.")
                    })
                }
                
                
            }))
        }
        
        actionController.addAction(Action("Cancel", style: .destructive, handler: { action in
        }))
        present(actionController, animated: true, completion: nil)
        
        tableView.reloadData();
    }
    
    func updateDownload(_ notification: NSNotification){
        self.initUI();
    }
}

extension DownloadViewController {
    fileprivate func prepareToolbar() {
        guard let toolbar = toolbarController?.toolbar else {
            return
        }
        
        toolbar.title = "Download"
        toolbar.titleLabel.textColor = .black
        toolbar.titleLabel.textAlignment = .center
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 28);
    }
}
