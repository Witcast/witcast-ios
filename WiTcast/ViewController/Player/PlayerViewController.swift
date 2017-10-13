//
//  PlayerViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/16/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import MarqueeLabel
import RealmSwift
import Kingfisher
import Jukebox
import Material
import Whisper
import PopupDialog

class PlayerViewController: UIViewController {
    
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDetail: MarqueeLabel!
    @IBOutlet var favouriteButton: IconButton!
    @IBOutlet var downloadButton: IconButton!
    @IBOutlet var imgCover: UIImageView!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var btnRewindlbl: UIButton!
    @IBOutlet var btnForwardlbl: UIButton!
    @IBOutlet var btnPlaylbl: UIButton!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var slider: UISlider!
    
    let realm = try! Realm()
    var isPlay = false;
    var lists : Results<NormalEpisode>!
    fileprivate var titleTab: String = ""
    let appDelegate: AppDelegate = AppDelegate.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateTimeLabel(_:)),name:NSNotification.Name(rawValue: "updateTime"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateStage(_:)),name:NSNotification.Name(rawValue: "updateStageMain"), object: nil)
        
        configureView()
        self.loadData()
    }

    func configureView() {
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
        slider.minimumTrackTintColor = UIColor.black
        slider.maximumTrackTintColor = UIColor.gray

        self.favouriteButton.image = Icon.favorite
        self.downloadButton.image = Icon.arrowDownward
        self.resetUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false;
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateButton"), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func initView(titleTab: String) {
        self.titleTab = titleTab
        preparePageTabBarItem()
    }
    
    @IBAction func btnRewind(_ sender: AnyObject) {
        if (self.isPlay == true) {
            if let currentTime = self.appDelegate.jukebox.currentItem?.currentTime {
                self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) - 15))
            }
        }
    }
    
    @IBAction func btnForward(_ sender: AnyObject) {
        if (self.isPlay == true) {
            if let currentTime = self.appDelegate.jukebox.currentItem?.currentTime {
                self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) + 15))
            }
        }
    }
    
    @IBAction func progressSliderValueChanged() {
        if (self.isPlay == true) {
            if let duration = self.appDelegate.jukebox.currentItem?.meta.duration {
                self.appDelegate.jukebox.seek(toSecond: Int(Double(self.slider.value) * duration))
            }
        }
    }
    
    @IBAction func btnPlay(_ sender: AnyObject) {
        var index = 1;
        
        if (self.isPlay == true) {
            switch self.appDelegate.jukebox.state {
            case .ready :
                self.appDelegate.jukebox.play(atIndex: 0)
            case .playing :
                self.appDelegate.jukebox.pause()
            case .paused :
                self.appDelegate.jukebox.play()
            default:
                self.appDelegate.jukebox.stop()
            }
        }
        else {
            self.appDelegate.jukebox.stop();
            
            if (UserDefaults.standard.object(forKey: "episodeShow") as? Int) != nil {
                index = UserDefaults.standard.object(forKey: "episodeShow") as! Int;
            }
            
            UserDefaults.standard.set(index, forKey: "episodeNow")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateButton"), object: nil)
            self.isPlay = true
            
            let itemUrl = self.appDelegate.jukebox.currentItem?.URL
            if itemUrl != nil {
                self.appDelegate.jukebox.removeItems(withURL: itemUrl!)
            }
            
            var data: Results<NormalEpisode>!;
            data = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
            let dataLocal = realm.objects(ItemLocal.self).filter("episodeId = \(data[0].episodeId)")
            if dataLocal.count != 0 {
                if dataLocal[0].downloadPath != "" {
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(dataLocal[0].episodeId).mp3")
                    self.appDelegate.jukebox.append(item: JukeboxItem (URL: destinationUrl, localTitle: data[0].dsc), loadingAssets: true)
                } else {
                    self.appDelegate.jukebox.append(item: JukeboxItem (URL: URL(string: data[0].fileUrl)!, localTitle: data[0].dsc), loadingAssets: true)
                }
            } else {
                self.appDelegate.jukebox.append(item: JukeboxItem (URL: URL(string: data[0].fileUrl)!, localTitle: data[0].dsc), loadingAssets: true)
            }

            self.appDelegate.jukebox.play(atIndex: 0)
        }
    }
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        let dataTemp = self.lists[0];
        let dataFavourite = realm.objects(ItemLocal.self).filter("episodeId = \(dataTemp.episodeId)")
        
        let updateData = ItemLocal()
        if dataFavourite.count == 0 {
            updateData.episodeId = dataTemp.episodeId
            updateData.downloadStatus = "None"
            updateData.isFavourite = true
            updateData.downloadPath = ""
            updateData.downloadPercent = 0
            updateData.lastDulation = 0.0
        } else {
            updateData.episodeId = dataFavourite[0].episodeId
            updateData.downloadStatus = dataFavourite[0].downloadStatus
            updateData.downloadPath = dataFavourite[0].downloadPath
            updateData.downloadPercent =  dataFavourite[0].downloadPercent
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
        
        self.loadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_feed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_favourite"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_search"), object: nil)
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        if UserDefaults.standard.integer(forKey: "downloadCount") == 2 {
            let popup = PopupDialog(title: "ขออภัยค่ะ!", message: "ตอนนี้มีไฟล์ที่กำลังโหลดอยู่ 2 ไฟล์ เพื่อความมีเสถียรภาพกรุณาให้ไฟล์ใดไฟล์หนึ่งโหลดเสร็จสิ้นก่อนนะคะ", buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
            }
            
            let buttonOK = DefaultButton(title: "OK") {

            }
            
            popup.addButtons([buttonOK])
            self.present(popup, animated: true, completion: nil)
        } else {
            let downloadNow = UserDefaults.standard.integer(forKey: "downloadCount")
            UserDefaults.standard.set((downloadNow + 1), forKey: "downloadCount")
            
            let dataTemp = self.lists[0];
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
                
            } else {
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
        
        self.downloadButton.tintColor = Color.red.base
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_feed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_search"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
    }
    
    func updateStage(_ notification: NSNotification){
        self.updateUI()
    }
    
    func updateTimeLabel(_ notification: NSNotification){
        guard let notiInfo = notification.object as? NSDictionary,
            let status = notiInfo["status"] as? Bool,
            let currentTime = notiInfo["timeNow"] as? Double,
            let duration = notiInfo["duration"] as? Double,
            self.isPlay && status else {
                self.resetUI()
                return
        }

        let value = Float(currentTime / duration)
        self.slider.isEnabled = true
        self.slider.value = value
        self.lblTime.text = "\(self.timeLabelString(duration: Int(currentTime))) / \(self.timeLabelString(duration: Int(duration)))"

    }
    
    func resetUI() {
        self.lblTime.text = "0:00 / 0:00"
        self.slider.value = 0
        self.loadingIndicator.alpha = 0
        
        self.updateUI()
    }
    
    func updateUI(){
        if (self.isPlay) {
            UIView.animate(withDuration: 0.3) {
                self.loadingIndicator.alpha = self.appDelegate.jukebox.state == .loading ? 1 : 0
                self.btnPlaylbl.alpha = self.appDelegate.jukebox.state == .loading ? 0 : 1
                self.btnPlaylbl.isEnabled = self.appDelegate.jukebox.state == .loading ? false : true
            }

            let imageName: String
            switch self.appDelegate.jukebox.state {
            case .ready:
                imageName = "ic-play"
            case .loading:
                imageName = "ic-pause"
            case .playing:
                imageName = "ic-pause"
            case .paused, .failed:
                imageName = "ic-play"
            }
            self.btnPlaylbl.setImage(UIImage(named: imageName), for: UIControlState())
        } else {
            self.btnPlaylbl.setImage(UIImage(named: "ic-play"), for: .normal)
        }
    }
    
    func timeLabelString(duration: Int) -> String {
        let currentHours = Int(duration) / 3600
        let currentMinutes = (Int(duration) % 3600) / 60
        let currentSeconds = (Int(duration) % 36000) % 60
        
        let stringHours = currentHours < 10 ? "0\(currentHours)" : "\(currentHours)"
        let stringMinutes = currentMinutes < 10 ? "0\(currentMinutes)" : "\(currentMinutes)"
        let stringSeconds = currentSeconds < 10 ? "0\(currentSeconds)" : "\(currentSeconds)"
        
        return "\(stringHours):\(stringMinutes):\(stringSeconds)"
    }
    
    func loadData() {
        var index = 1;
        var episodeNow = 1;
        var episodeShow = 1;
        
        if (UserDefaults.standard.object(forKey: "episodeNow") as? Int) != nil {
            episodeNow = UserDefaults.standard.object(forKey: "episodeNow") as! Int;
        }
        
        if (UserDefaults.standard.object(forKey: "episodeShow") as? Int) != nil {
            episodeShow = UserDefaults.standard.object(forKey: "episodeShow") as! Int;
        }
        
        if (episodeNow == episodeShow) {
            self.isPlay = true
        }
        
        if (self.isPlay == true) {
            index = episodeNow;
            self.slider.isEnabled = true
        }
        else {
            index = episodeShow;
            self.lblTime.text = "0:00 / 0:00"
            self.btnPlaylbl.setImage(UIImage(named: "ic-play"), for: .normal)
            self.slider.value = 0.00
            self.slider.isEnabled = false
        }
        
        self.lists = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
        self.lblTitle.text = self.lists.first?.title;
        self.lblDetail.text = self.lists.first?.dsc;

        guard
            let URLString = self.lists.first?.coverImageUrl,
            let url = URL(string: URLString) else {
            return
        }
        self.imgCover.kf.setImage(with: url)
        
        let dataLocal = realm.objects(ItemLocal.self).filter("episodeId = \(self.lists[0].episodeId)")
        if dataLocal.count > 0 {
            if dataLocal[0].isFavourite == false {
                self.favouriteButton.tintColor = Color.blueGrey.base
            }
            else {
                self.favouriteButton.tintColor = Color.red.base
            }
            
            if (dataLocal[0].downloadStatus == "Done") || (dataLocal[0].downloadStatus == "Downloading") {
                self.downloadButton.tintColor = Color.red.base
            }
            else {
                self.downloadButton.tintColor = Color.blueGrey.base
            }
        }
        else {
            self.favouriteButton.tintColor = Color.blueGrey.base
            self.downloadButton.tintColor = Color.blueGrey.base
        }
        
        self.updateUI();
    }
}

/// PageTabBar.
extension PlayerViewController {
    func preparePageTabBarItem() {
        tabItem.title = self.titleTab
        tabItem.titleColor = .black
        tabItem.titleLabel?.font = UIFont(name: font_header_regular, size: 20);
    }
}
