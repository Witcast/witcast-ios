//
//  NormalEpisode.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 9/29/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import Foundation
import RealmSwift

class NormalEpisode: Object {
    
    dynamic var episodeId = 0;
    dynamic var title = "";
    dynamic var dsc = "";
    dynamic var fileUrl = "";
    dynamic var detail = "";
    dynamic var type = "";
    dynamic var onAir = NSDate();
    dynamic var miniImageUrl = "";
    dynamic var mainImageUrl = "";
    dynamic var coverImageUrl = "";
    dynamic var mainEpisodeId = 0;
    
    override class func primaryKey() -> String {
        return "episodeId"
    }
}
