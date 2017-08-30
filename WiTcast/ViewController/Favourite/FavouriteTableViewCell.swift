//
//  FavouriteTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 6/12/2560 BE.
//  Copyright © 2560 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit

class FavouriteTableViewCell: UITableViewCell {
    
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgMini: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.font = UIFont(name: font_header_regular, size: lblTitle.font.pointSize);
        lblDetail.font = UIFont(name: font_regular, size: lblDetail.font.pointSize);
        imgMini.layer.cornerRadius = imgMini.frame.size.width / 2;
        imgMini.clipsToBounds = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
