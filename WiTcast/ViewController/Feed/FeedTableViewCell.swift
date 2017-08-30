//
//  FeedTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 2/25/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import Material

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var imgBackgroud: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var btnViewDetail: UIButton!
    @IBOutlet var favouriteButton: IconButton!
    @IBOutlet var downloadButton: IconButton!
    @IBOutlet var shareButton: IconButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
