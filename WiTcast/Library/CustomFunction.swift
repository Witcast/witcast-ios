//
//  CustomFunction.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/13/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import SystemConfiguration

class CustomFunc {
    class func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func dateFromString(dateStr: String) -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = locale as Locale!
        
        let date = dateFormatter.date(from: dateStr)
        
        return date! as NSDate;
    }
    
    class func getDateShow(dateIn: NSDate) -> NSString {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "dd MMM yyyy";
        
        let dateString = dateFormatter.string(from: dateIn as Date);
        
        return dateString as NSString;
    }
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
