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
//    var sliderTimer: Timer?
    var isPlay = false;
    var lists : Results<NormalEpisode>!
    internal var titleTab: String = ""
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateTimeLabel(_:)),name:NSNotification.Name(rawValue: "updateTime"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateStage(_:)),name:NSNotification.Name(rawValue: "updateStageMain"), object: nil)
        
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: (UIScreen.main.bounds.size.height - 138))
        
        if UIScreen.main.bounds.width == 414 {
            self.viewTitle.frame = CGRect(x: self.imgCover.frame.origin.x, y: (self.imgCover.frame.origin.y + self.imgCover.frame.height), width: 414, height: self.viewTitle.frame.height);
        }
        else if UIScreen.main.bounds.width == 375 {
            self.viewTitle.frame = CGRect(x: self.imgCover.frame.origin.x, y: (self.imgCover.frame.origin.y + self.imgCover.frame.height), width: 375, height: self.viewTitle.frame.height);
        }
        
        self.lblTitle.font = UIFont(name: font_header_regular, size: self.lblTitle.font.pointSize);
        self.lblTime.font = UIFont(name: font_header_regular, size: self.lblTime.font.pointSize);
        self.lblDetail.font = UIFont(name: font_regular, size: self.lblDetail.font.pointSize);
        self.lblDetail.tag = 101
        self.lblDetail.type = .continuous
        self.lblDetail.animationCurve = .easeInOut
        self.lblDetail.speed = .duration(12.0)
        self.lblDetail.fadeLength = 15.0
        
        slider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState())
        slider.minimumTrackTintColor = UIColor.black
        slider.maximumTrackTintColor = UIColor.gray
        
        self.favouriteButton.image = Icon.favorite
        self.downloadButton.image = Icon.arrowDownward
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true;
        self.resetUI()
        self.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false;
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateButton"), object: nil)
    }
    
    func initView(titleTab: String) {
        self.titleTab = titleTab
        preparePageTabBarItem()
    }
    
    @IBAction func btnRewind(_ sender: AnyObject) {
        if (self.isPlay == true) {
            if let currentTime = self.appDelegate.jukebox.currentItem?.currentTime {
                self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) - 15))
//                self.checkTime()
            }
        }
    }
    
    @IBAction func btnForward(_ sender: AnyObject) {
        if (self.isPlay == true) {
            if let currentTime = self.appDelegate.jukebox.currentItem?.currentTime {
                self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) + 15))
//                self.checkTime()
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
                }
                else {
                    self.appDelegate.jukebox.append(item: JukeboxItem (URL: URL(string: data[0].fileUrl)!, localTitle: data[0].dsc), loadingAssets: true)
                }
            }
            else {
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
        }
        else {
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
        }
        else {
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_feed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_search"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
    }
    
    func updateStage(_ notification: NSNotification){
        self.updateUI()
    }
    
    func updateTimeLabel(_ notification: NSNotification){
        if (self.isPlay == true) {
            let notiInfo = notification.object as! NSDictionary
            if notiInfo["status"] as! Bool == true {
                let currentTime = notiInfo["timeNow"] as! Double
                let duration = notiInfo["duration"] as! Double
                
                let value = Float(currentTime / duration)
                self.slider.isEnabled = true
                self.slider.value = value
                self.lblTime.text = "\(self.timeLabelString(duration: Int(currentTime))) / \(self.timeLabelString(duration: Int(duration)))"
            }
            else {
                self.resetUI()
            }
        }
        else {
            self.resetUI()
        }
    }
    
    func resetUI()
    {
        self.lblTime.text = "0:00 / 0:00"
        self.slider.value = 0
        self.loadingIndicator.alpha = 0
        
        self.updateUI()
    }
    
    func updateUI(){
        if (self.isPlay == true) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.loadingIndicator.alpha = self.appDelegate.jukebox.state == .loading ? 1 : 0
                self.btnPlaylbl.alpha = self.appDelegate.jukebox.state == .loading ? 0 : 1
                self.btnPlaylbl.isEnabled = self.appDelegate.jukebox.state == .loading ? false : true
            })
            
            if self.appDelegate.jukebox.state == .ready {
                self.btnPlaylbl.setImage(UIImage(named: "ic-play"), for: UIControlState())
            } else if self.appDelegate.jukebox.state == .loading  {
                self.btnPlaylbl.setImage(UIImage(named: "ic-pause"), for: UIControlState())
            } else {
                let imageName: String
                switch self.appDelegate.jukebox.state {
                case .playing, .loading:
                    imageName = "ic-pause"
                case .paused, .failed, .ready:
                    imageName = "ic-play"
                }
                self.btnPlaylbl.setImage(UIImage(named: imageName), for: UIControlState())
            }
        }
        else {
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
        self.lblTitle.text = self.lists[0].title;
        self.lblDetail.text = self.lists[0].dsc;
        
        let URLString = self.lists[0].coverImageUrl;
        let url = URL(string: URLString)!
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
    internal func preparePageTabBarItem() {
        tabItem.title = self.titleTab
        tabItem.titleColor = .black
        tabItem.titleLabel?.font = UIFont(name: font_header_regular, size: 20);
    }
}
