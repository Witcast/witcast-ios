//
//  InitialData.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 9/21/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import FirebaseDatabase
import Alamofire

class InitialData {

    class func loadData() {
        var ref: DatabaseReference!
        let realm = try! Realm()
//        var waitResultMain = true;
//        var waitResult = true;
        var app_version = 0.0;
        
        ref = Database.database().reference() //.child("data_version")
        ref.observe(DataEventType.value, with: { (snapshot) in
            let list = snapshot.value as! NSDictionary
            let version_data = list["data_version"] as! NSDictionary
            let version = version_data["version"] as! NSNumber
            
            if (UserDefaults.standard.object(forKey: "data_version") as? Double != nil) {
                app_version = UserDefaults.standard.object(forKey: "data_version") as! Double
            }
            
            if ((version.doubleValue) > app_version) {
                
                let feedData = list["feed"] as! NSArray
                let mainData = list["main_episode"] as! NSArray
                
                for i in 0..<feedData.count {
                    let dataTemp = feedData[i] as! NSDictionary
                    
                    let normalEP = NormalEpisode()
                    normalEP.episodeId = dataTemp["episodeId"] as! Int
                    normalEP.title = dataTemp["title"] as! String
                    normalEP.dsc = dataTemp["dsc"] as! String
                    normalEP.fileUrl = dataTemp["fileUrl"] as! String
                    normalEP.detail = dataTemp["detail"] as! String
                    normalEP.type = dataTemp["type"] as! String
                    normalEP.onAir = CustomFunc.dateFromString(dateStr: dataTemp["onAir"] as! String);
                    normalEP.miniImageUrl = dataTemp["miniImageUrl"] as! String
                    normalEP.mainImageUrl = dataTemp["mainImageUrl"] as! String
                    normalEP.coverImageUrl = dataTemp["coverImageUrl"]as! String
                    normalEP.mainEpisodeId = dataTemp["mainEpisodeId"] as! Int
                    
                    try! realm.write {
                        realm.add(normalEP, update: true)
                    }
                }
                
                for i in 0..<mainData.count {
                    let dataTemp = mainData[i] as! NSDictionary
                    
                    let mainEP = MainEpisode()
                    mainEP.mainEpisodeId = dataTemp["mainEpisodeId"] as! Int
                    mainEP.title = dataTemp["title"] as! String
                    mainEP.dsc = dataTemp["dsc"] as! String
                    mainEP.imageUrl = dataTemp["imageUrl"] as! String
                    mainEP.subEpisodeCount = dataTemp["subEpisodeCount"] as! Int
                    
                    try! realm.write {
                        realm.add(mainEP, update: true)
                    }
                }
                
                UserDefaults.standard.set((version.doubleValue), forKey: "data_version")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_data_end"), object: nil)
        })
    }
    
    class func downloadFile(indexEpisode: Int, url: String){
        
        let realm = try! Realm()
        var temp = 0
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(indexEpisode).mp3")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination)
            .downloadProgress { progress in
                let update = Int(progress.fractionCompleted * 100)
                
                if temp != update {
                    temp = update
                    print("Download Progress \(indexEpisode): \(update))")
                    
                    let dataDownload = realm.objects(ItemLocal.self).filter("episodeId = \(indexEpisode)")
                    let updateData = ItemLocal()
                    updateData.episodeId = dataDownload[0].episodeId
                    updateData.downloadStatus = dataDownload[0].downloadStatus
                    updateData.isFavourite = dataDownload[0].isFavourite
                    updateData.downloadPath = dataDownload[0].downloadPath
                    updateData.downloadPercent = update
                    updateData.lastDulation = dataDownload[0].lastDulation
                    
                    try! realm.write {
                        realm.add(updateData, update: true)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
                }
            }
            .response { response in
                if response.error == nil, let filePath = response.destinationURL?.path {
                    print(filePath)
                    
                    let dataDownload = realm.objects(ItemLocal.self).filter("episodeId = \(indexEpisode)")
                    let updateData = ItemLocal()
                    updateData.episodeId = dataDownload[0].episodeId
                    updateData.downloadStatus = "Done"
                    updateData.isFavourite = dataDownload[0].isFavourite
                    updateData.downloadPath = filePath
                    updateData.downloadPercent = dataDownload[0].downloadPercent
                    updateData.lastDulation = dataDownload[0].lastDulation
                    
                    try! realm.write {
                        realm.add(updateData, update: true)
                    }
                    
                    let downloadNow = UserDefaults.standard.integer(forKey: "downloadCount")
                    UserDefaults.standard.set((downloadNow - 1), forKey: "downloadCount")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
                }
                else {
                    let dataDownload = realm.objects(ItemLocal.self).filter("episodeId = \(indexEpisode)")
                    let updateData = ItemLocal()
                    updateData.episodeId = dataDownload[0].episodeId
                    updateData.downloadStatus = "Fail"
                    updateData.isFavourite = dataDownload[0].isFavourite
                    updateData.downloadPath = dataDownload[0].downloadPath
                    updateData.downloadPercent = dataDownload[0].downloadPercent
                    updateData.lastDulation = dataDownload[0].lastDulation
                    
                    try! realm.write {
                        realm.add(updateData, update: true)
                    }
                    
                    let downloadNow = UserDefaults.standard.integer(forKey: "downloadCount")
                    UserDefaults.standard.set((downloadNow - 1), forKey: "downloadCount")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
                }
        }
    }
    
    class func deleteFile(indexEpisode: Int) {
        let realm = try! Realm()
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        
        let filePath = "\(dirPath)/\(indexEpisode).mp3"
        
        do {
            try fileManager.removeItem(atPath: filePath)
            print("========== \(filePath)")
            
            let dataDownload = realm.objects(ItemLocal.self).filter("episodeId = \(indexEpisode)")
            let updateData = ItemLocal()
            updateData.episodeId = dataDownload[0].episodeId
            updateData.downloadStatus = "None"
            updateData.isFavourite = dataDownload[0].isFavourite
            updateData.downloadPath = ""
            updateData.downloadPercent = dataDownload[0].downloadPercent
            updateData.lastDulation = dataDownload[0].lastDulation
            
            try! realm.write {
                realm.add(updateData, update: true)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_feed"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_search"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDownload"), object: nil)
            
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}
