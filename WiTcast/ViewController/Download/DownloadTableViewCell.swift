//
//  DownloadTableViewCell.swift
//  WiTcast
//
//  Created by Tanakorn Phoochaliaw on 9/24/16.
//  Copyright © 2016 Tanakorn Phoochaliaw. All rights reserved.
//

import UIKit
import Material

class DownloadTableViewCell: UITableViewCell {

    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgMini: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var percentLebel: UILabel!
    @IBOutlet var moreButton: IconButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moreButton.image = Icon.moreVertical
        moreButton.tintColor = Color.blueGrey.base
        imgMini.layer.cornerRadius = imgMini.frame.size.width / 2;
        imgMini.clipsToBounds = true;
        
        lblTitle.font = UIFont(name: font_header_regular, size: lblTitle.font.pointSize);
        lblDetail.font = UIFont(name: font_regular, size: lblDetail.font.pointSize);
        statusLabel.font = UIFont(name: font_header_regular, size: statusLabel.font.pointSize);
        percentLebel.font = UIFont(name: font_header_regular, size: percentLebel.font.pointSize);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
