//
//  FeedHeaderTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/13/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class FeedHeaderTableViewCell: UITableViewCell {

    @IBOutlet var lblTitleCategory: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
