//
//  SpecialHeaderTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 7/26/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class SpecialHeaderTableViewCell: UITableViewCell {

    @IBOutlet var lblEpisode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
