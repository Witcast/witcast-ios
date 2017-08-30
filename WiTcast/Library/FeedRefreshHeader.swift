//
//  FeedRefreshHeader.swift
//  setscope-ios
//
//  Created by Tanakorn Phoochaliaw on 7/12/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation
import UIKit
import PullToRefreshKit

class FeedRefreshHeader:UIView,RefreshableHeader{
    let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = CGRect(x: 0, y: 0, width: 27, height: 10)
        imageView.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
        imageView.image = UIImage(named: "loading15")
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - RefreshableHeader -
    func heightForRefreshingState()->CGFloat{
        return 50
    }
    func stateDidChanged(_ oldState: RefreshHeaderState, newState: RefreshHeaderState) {
        if newState == .pulling{
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform.identity
            })
        }
        if newState == .idle{
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        }
    }

    func didBeginRefreshingState(){
        imageView.image = nil
        let images = (0...29).map{return $0 < 10 ? "loading0\($0)" : "loading\($0)"}
        imageView.animationImages = images.map{return UIImage(named:$0)!}
        imageView.animationDuration = Double(images.count) * 0.04
        imageView.startAnimating()
    }

    func didBeginEndRefershingAnimation(_ result:RefreshResult){}

    func didCompleteEndRefershingAnimation(_ result:RefreshResult){
        imageView.animationImages = nil
        imageView.stopAnimating()
        imageView.image = UIImage(named: "loading15")
    }
}
