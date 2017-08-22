//
//  AppDelegate.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 2/22/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import WKAwesomeMenu
import Jukebox
import Firebase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JukeboxDelegate {

    var window: UIWindow?
    var jukebox : Jukebox!
    var initialViewController :UIViewController?
    var initialNavi: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // begin receiving remote events
        UIApplication.shared.beginReceivingRemoteControlEvents()
        jukebox = Jukebox(delegate: self, items: [])!
        
        let config = Realm.Configuration(
            schemaVersion: 6,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 6) {
                    //                    migration.enumerateObjects(ofType: NormalEpisode.className()) { oldObject, newObject in
                    //                        newObject!["downloadPath"] = ""
                    //                    }
                }
        })
        
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        let initialViewController  = ContainerViewController(nibName:"ContainerViewController",bundle:nil);
        let initialNavi = UINavigationController(rootViewController: initialViewController);
        
        let menuVC = MenuViewController(nibName:"MenuViewController",bundle:nil);
        
        var options = WKAwesomeMenuOptions.defaultOptions()
        options.backgroundImage = UIImage(named: "general_bg.png")
        options.menuWidth = UIScreen.main.bounds.width;
        options.menuParallax = 0;
        options.shadowColor = UIColor.clear;
        
        let awesomeMenu = WKAwesomeMenu(rootViewController: initialNavi, menuViewController: menuVC, options: options)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = awesomeMenu
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white;
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //        UINavigationBar.appearance().shadowImage = UIImage(named: "general_bg.png");
        //        UINavigationBar.appearance().titleTextAttributes = [
        //            NSFontAttributeName: Font.buttonFont,
        //            NSForegroundColorAttributeName: Color.appTitleColor
        //        ]
        
        FirebaseApp.configure()
        
        return true
    }
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            
            let obj = ["status": true, "timeNow": currentTime, "duration": duration ] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTime"), object: obj)
        } else {
            let obj = ["status": false]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTime"), object: obj)
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStage"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStageMain"), object: nil)
        
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        print("Item updated:\n\(forItem)")
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == .remoteControl {
            switch event!.subtype {
            case .remoteControlPlay :
                jukebox.play()
            case .remoteControlPause :
                jukebox.pause()
            case .remoteControlNextTrack :
//                jukebox.playNext()
                if let currentTime = self.jukebox.currentItem?.currentTime {
                    self.jukebox.seek(toSecond: Int(Double(currentTime) + 15))
                }
            case .remoteControlPreviousTrack:
//                jukebox.playPrevious()
                if let currentTime = self.jukebox.currentItem?.currentTime {
                    self.jukebox.seek(toSecond: Int(Double(currentTime) - 15))
                }
            case .remoteControlTogglePlayPause:
                if jukebox.state == .playing {
                    jukebox.pause()
                } else {
                    jukebox.play()
                }
            default:
                break
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("Terminate")
    }


}

