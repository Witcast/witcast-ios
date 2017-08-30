//
//  ItemLocal.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 8/6/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import RealmSwift

class ItemLocal: Object {
    
    dynamic var episodeId = 0;
    dynamic var downloadStatus = "None";
    dynamic var isFavourite = false;
    dynamic var downloadPath = "";
    dynamic var downloadPercent = 0;
    dynamic var lastDulation = 0.0;
    
    override class func primaryKey() -> String {
        return "episodeId"
    }
}
