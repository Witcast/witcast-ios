//
//  MainEpisode.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 9/21/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation
import RealmSwift

class MainEpisode: Object {
    
    dynamic var mainEpisodeId = 0;
    dynamic var title = "";
    dynamic var dsc = "";
    dynamic var imageUrl = "";
    dynamic var subEpisodeCount = 0;
    
    override class func primaryKey() -> String {
        return "mainEpisodeId"
    }
}
