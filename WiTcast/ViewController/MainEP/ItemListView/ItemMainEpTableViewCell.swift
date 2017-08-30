//
//  ItemMainEpTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/18/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class ItemMainEpTableViewCell: UITableViewCell {

    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var imgBg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
