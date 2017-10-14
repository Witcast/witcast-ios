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
    var episodeShow: Int? {
        get {
            return valueFromUserDefaultFromKey(key: "episodeShow")
        }
        set {
            saveObjectToUserDefault(key: "episodeShow", value: newValue)
        }
    }
    var episodeNow: Int? {
        get {
            return valueFromUserDefaultFromKey(key: "episodeNow")
        }
        set {
            saveObjectToUserDefault(key: "episodeNow", value: newValue)
        }
    }
    var downloadCount: Int? {
        get {
            return valueFromUserDefaultFromKey(key: "downloadCount")
        }
        set {
            saveObjectToUserDefault(key: "downloadCount", value: newValue)
        }
    }
    
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

    func initView(titleTab: String) {
        self.titleTab = titleTab
        preparePageTabBarItem()
    }
    
    @IBAction func btnRewind(_ sender: AnyObject) {
        guard let currentTime = self.appDelegate.jukebox.currentItem?.currentTime, self.isPlay else {
            return
        }
        self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) - 15))
    }
    
    @IBAction func btnForward(_ sender: AnyObject) {
        guard let currentTime = self.appDelegate.jukebox.currentItem?.currentTime, self.isPlay else {
            return
        }
        self.appDelegate.jukebox.seek(toSecond: Int(Double(currentTime) + 15))
    }
    
    @IBAction func progressSliderValueChanged() {
        guard let duration = self.appDelegate.jukebox.currentItem?.meta.duration, self.isPlay else {
            return
        }
        self.appDelegate.jukebox.seek(toSecond: Int(Double(self.slider.value) * duration))
    }
    
    @IBAction func btnPlay(_ sender: AnyObject) {
        let index = episodeShow ?? 1;
        
        if self.isPlay {
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
        } else {
            self.appDelegate.jukebox.stop();
            episodeNow = index
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateButton"), object: nil)
            if let itemUrl = self.appDelegate.jukebox.currentItem?.URL {
                self.appDelegate.jukebox.removeItems(withURL: itemUrl)
            }
            guard let data = realm.objects(NormalEpisode.self).filter("episodeId = \(index)").first,
                var fileURL = URL(string: data.fileUrl) else {
                return
            }
            if let dataLocal = realm.objects(ItemLocal.self).filter("episodeId = \(data.episodeId)").first, !dataLocal.downloadPath.isEmpty {
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(dataLocal.episodeId).mp3")
                    fileURL = destinationUrl

            }
            self.appDelegate.jukebox.append(item: JukeboxItem (URL: fileURL, localTitle: data.dsc), loadingAssets: true)
            self.appDelegate.jukebox.play(atIndex: 0)
            self.isPlay = true
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
        let downloadCount = self.downloadCount ?? 0
        if downloadCount == 2 {
            let popup = PopupDialog(title: "ขออภัยค่ะ!", message: "ตอนนี้มีไฟล์ที่กำลังโหลดอยู่ 2 ไฟล์ เพื่อความมีเสถียรภาพกรุณาให้ไฟล์ใดไฟล์หนึ่งโหลดเสร็จสิ้นก่อนนะคะ", buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
            }
            
            let buttonOK = DefaultButton(title: "OK") {

            }
            
            popup.addButtons([buttonOK])
            self.present(popup, animated: true, completion: nil)
        } else {
            self.downloadCount = downloadCount + 1
            
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
        var imageName = "ic-play"
        if (self.isPlay) {
            UIView.animate(withDuration: 0.3) {
                self.loadingIndicator.alpha = self.appDelegate.jukebox.state == .loading ? 1 : 0
                self.btnPlaylbl.alpha = self.appDelegate.jukebox.state == .loading ? 0 : 1
                self.btnPlaylbl.isEnabled = self.appDelegate.jukebox.state == .loading ? false : true
            }
            switch self.appDelegate.jukebox.state {
            case .ready:
                imageName = "ic-play"
            case .loading:
                imageName = "ic-pause"
            case .playing:
                imageName = "ic-pause"
            default: break
            }
        }
        self.btnPlaylbl.setImage(UIImage(named: imageName), for: .normal)
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
        let episodeNow = self.episodeNow ?? 1
        let episodeShow = self.episodeShow ?? 1

        self.isPlay = episodeNow == episodeShow
        
        if !self.isPlay {
            self.lblTime.text = "0:00 / 0:00"
            self.btnPlaylbl.setImage(UIImage(named: "ic-play"), for: .normal)
            self.slider.value = 0.00
        }
        index = self.isPlay ? episodeNow : episodeShow
        self.slider.isEnabled = self.isPlay
        
        self.lists = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
        self.lblTitle.text = self.lists.first?.title;
        self.lblDetail.text = self.lists.first?.dsc;

        guard let URLString = self.lists.first?.coverImageUrl,
            let url = URL(string: URLString),
            let dataLocal = realm.objects(ItemLocal.self).filter("episodeId = \(self.lists[0].episodeId)").first else {
            return
        }
        self.imgCover.kf.setImage(with: url)
        let isDoneOrDownloading = (dataLocal.downloadStatus == "Done") || (dataLocal.downloadStatus == "Downloading")
        self.favouriteButton.tintColor = dataLocal.isFavourite ? Color.red.base : Color.blueGrey.base
        self.downloadButton.tintColor = isDoneOrDownloading ? Color.red.base : Color.blueGrey.base
        
        self.updateUI();
    }

    private func valueFromUserDefaultFromKey<T>(key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }

    private func saveObjectToUserDefault(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
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
