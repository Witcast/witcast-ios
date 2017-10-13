//
//  ContainerViewController.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 8/28/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import WKAwesomeMenu
import MarqueeLabel
import RealmSwift
import Kingfisher
import Jukebox

class ContainerViewController: UIViewController {
    
    @IBOutlet var contantView: UIView!
    @IBOutlet var miniPlayerView : LineView!
    @IBOutlet var miniPlayerButton : UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDetail: MarqueeLabel!
    @IBOutlet var btnPlaylbl: UIButton!
    @IBOutlet var imgMini: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    let realm = try! Realm()
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    private var controllerVC: PlayerViewController!
    private var detailVC: PlayerDetailViewController!
    
    private var playerVC : PlayerToolbarController!
    
    var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController()
        }
    }
    
    func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParentViewController: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            activeVC.view.frame = contantView.bounds
            contantView.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMove(toParentViewController: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.isHidden = true;
        self.initData();
        self.updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.loadViewController(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.openSideMenu(_:)),name:NSNotification.Name(rawValue: "menu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.playView(_:)),name:NSNotification.Name(rawValue: "open_play_view"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.updateButton(_:)),name:NSNotification.Name(rawValue: "updateButton"), object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.updateStage(_:)),name:NSNotification.Name(rawValue: "updateStage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.loading(_:)),name:NSNotification.Name(rawValue: "load_data"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.loadEnd(_:)),name:NSNotification.Name(rawValue: "load_data_end"), object: nil)
        
        if (currentReachabilityStatus == .reachableViaWiFi) || (currentReachabilityStatus == .reachableViaWWAN) {
            InitialData.loadData();
        }
        else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_data_end"), object: nil)
        }
        
        UserDefaults.standard.set(true, forKey: "launchedContain")
        
        self.lblTitle.font = UIFont(name: font_header_regular, size: self.lblTitle.font.pointSize);
        self.lblDetail.font = UIFont(name: font_regular, size: self.lblDetail.font.pointSize);
        self.lblDetail.tag = 101
        self.lblDetail.type = .continuous
        self.lblDetail.animationCurve = .easeInOut
        self.lblDetail.speed = .duration(12.0)
        self.lblDetail.fadeLength = 15.0
        
        let feedController  = FeedViewController(nibName:"FeedViewController",bundle:nil);
        let feedNavi = FeedToolbarController(rootViewController: feedController);
        activeViewController = feedNavi

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadViewController(_ notification: NSNotification){
        //load data here
        
        if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 0 {
            let feedView  = FeedViewController(nibName:"FeedViewController",bundle:nil);
            let feedNavi = FeedToolbarController(rootViewController: feedView);
            activeViewController = feedNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 1 {
            let mainEPView  = MainEPViewController(nibName:"MainEPViewController",bundle:nil);
            let mainEPNavi = MainEPToolbarController(rootViewController: mainEPView)
            activeViewController = mainEPNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 2 {
            let specialView  = SpecialViewController(nibName:"SpecialViewController",bundle:nil);
            specialView.isSpecial = true
            let specialNavi = SpecialToolbarController(rootViewController: specialView)
            activeViewController = specialNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 3 {
            let specialView  = SpecialViewController(nibName:"SpecialViewController",bundle:nil);
            specialView.isSpecial = false
            let specialNavi = SpecialToolbarController(rootViewController: specialView)
            activeViewController = specialNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 4 {
            let otherView = OtherToolbarController(rootViewController: OtherViewController(nibName:"OtherViewController",bundle:nil))
            activeViewController = otherView;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 5 {
            let favoritesView  = FavouriteViewController(nibName:"FavouriteViewController",bundle:nil);
            let favoritesNavi = FavouriteToolbarViewController(rootViewController: favoritesView)
            activeViewController = favoritesNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 6 {
            let downloadView  = DownloadViewController(nibName:"DownloadViewController",bundle:nil);
            let downloadNavi = DownloadToolbarController(rootViewController: downloadView)
            activeViewController = downloadNavi;
        }
        else if (UserDefaults.standard.object(forKey: "index") as! NSInteger) == 7 {
            let donateView  = DonateViewController(nibName:"DonateViewController",bundle:nil);
            let donateNavi = DonateToolbarController(rootViewController: donateView)
            activeViewController = donateNavi;
        }
        else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "About", bundle:nil)
            let aboutViewController = storyBoard.instantiateViewController(withIdentifier: "About") as! AboutViewController
            let aboutView = AboutToolbarViewController(rootViewController: aboutViewController)
            activeViewController = aboutView;
        }
    }
    
    func openSideMenu(_ notification: NSNotification){
        self.openSideMenu()
    }
    
    func playView(_ notification: NSNotification){

        self.controllerVC = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        self.detailVC = PlayerDetailViewController(nibName: "PlayerDetailViewController", bundle: nil)
        self.controllerVC.initView(titleTab: "Controller")
        self.detailVC.initView(titleTab: "Detail")

        self.controllerVC.isPlay = false;
        self.detailVC.isPlay = false;
        
        let viewControllers = [self.controllerVC, self.detailVC] as [Any]
        let pageTabBarController = PlayerPageTabBarController(viewControllers: viewControllers as! [UIViewController])
        self.playerVC = PlayerToolbarController(rootViewController: pageTabBarController)
        self.playerVC.modalPresentationStyle = .overFullScreen
        self.present(self.playerVC, animated: true, completion: nil)
    }
    
    func updateButton(_ notification: NSNotification){
        self.updateMiniBar();
    }
    
    func loading(_ notification: NSNotification){
        print("Load")
    }
    
    func loadEnd(_ notification: NSNotification){
        self.updateMiniBar();
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_feed"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_main"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_item"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_special"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_other"), object: nil)
    }
    
    
    
    func updateStage(_ notification: NSNotification){
        self.updateUI()
    }
    
    func updateUI(){
        UIView.animate(withDuration: 3.0, animations: { () -> Void in
            self.loadingIndicator.alpha = self.appDelegate.jukebox.state == .loading ? 1 : 0
            self.btnPlaylbl.alpha = self.appDelegate.jukebox.state == .loading ? 0 : 1
            self.btnPlaylbl.isEnabled = self.appDelegate.jukebox.state == .loading ? false : true
        })
        
        if self.appDelegate.jukebox.state == .ready {
            self.btnPlaylbl.setImage(UIImage(named: "ic-play-yellow.png"), for: UIControlState())
        } else if self.appDelegate.jukebox.state == .loading  {
            self.btnPlaylbl.setImage(UIImage(named: "ic-pause-yellow.png"), for: UIControlState())
        } else {
            let imageName: String
            switch self.appDelegate.jukebox.state {
            case .playing, .loading:
                imageName = "ic-pause-yellow.png"
            case .paused, .failed, .ready:
                imageName = "ic-play-yellow.png"
            }
            self.btnPlaylbl.setImage(UIImage(named: imageName), for: UIControlState())
        }
    }
    
    func initData(){
        let itemUrl = self.appDelegate.jukebox.currentItem?.URL
        if itemUrl != nil {
            self.appDelegate.jukebox.removeItems(withURL: itemUrl!)
        }
        
        var index = 1;
        var data: Results<NormalEpisode>!;
        
        if (UserDefaults.standard.object(forKey: "episodeNow") as? Int) != nil {
            index = UserDefaults.standard.object(forKey: "episodeNow") as! Int;
        }
        
        data = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
        if data.count != 0 {
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
        }
    }
    
    func updateMiniBar(){
        var index = 1;
        var data: Results<NormalEpisode>!;
        
        if (UserDefaults.standard.object(forKey: "episodeNow") as? Int) != nil {
            index = UserDefaults.standard.object(forKey: "episodeNow") as! Int;
        }
        
        data = realm.objects(NormalEpisode.self).filter("episodeId = \(index)")
        let URLString = data[0].miniImageUrl;
        let url = URL(string: URLString)
        self.lblTitle.text = data[0].title;
        self.lblDetail.text = data[0].dsc;
        self.imgMini.kf.setImage(with: url)
        
        self.updateUI()
    }
    
    @IBAction func tapMiniPlayerButton(_ sender: AnyObject) {
        self.controllerVC = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        self.detailVC = PlayerDetailViewController(nibName: "PlayerDetailViewController", bundle: nil)
        self.controllerVC.initView(titleTab: "Controller")
        self.detailVC.initView(titleTab: "Detail")
        self.controllerVC.isPlay = true;
        self.detailVC.isPlay = true;
        
        let viewControllers = [self.controllerVC, self.detailVC] as [Any]
        let pageTabBarController = PlayerPageTabBarController(viewControllers: viewControllers as! [UIViewController])
        self.playerVC = PlayerToolbarController(rootViewController: pageTabBarController)
        self.playerVC.modalPresentationStyle = .overFullScreen
        self.present(self.playerVC, animated: true, completion: nil)
    }
    
    @IBAction func btnPlay(_ sender: AnyObject) {
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
}
