/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
import Kingfisher
import RealmSwift
//import Graph

class SearchTableViewCell: TableViewCell {
    private var spacing: CGFloat = 10
    
    public lazy var card: PresenterCard = PresenterCard()
    
    /// Toolbar views.
    private var toolbar: Toolbar!
//    public var moreButton: IconButton!
    
    /// Presenter area.
    private var presenterImageView: UIImageView!
    
    /// Content area.
    private var contentLabel: UILabel!
    
    /// Bottom Bar views.
    private var bottomBar: Bar!
    public var favoriteButton: IconButton!
    public var downloadButton: IconButton!
    public var shareButton: IconButton!
    private var dateLabel: UILabel!
    
    let realm = try! Realm()
    var item: NormalEpisode = NormalEpisode()
    var lists : Results<ItemLocal>!
    
    public func reloadData(data: NormalEpisode){
        //        public
        contentView.backgroundColor = nil
        self.item = data
        self.lists = realm.objects(ItemLocal.self).filter("episodeId = \(self.item.episodeId)")
        layoutSubviews()
    }
    
    /// Calculating dynamic height.
    open override var height: CGFloat {
        get {
            return card.height + spacing
        }
        set(value) {
            super.height = value
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        toolbar.titleLabel.font = UIFont(name: font_header_regular, size: 22);
        toolbar.title = "\(self.item.title)"
        
        if UIScreen.main.bounds.width == 414 {
            presenterImageView.height = 139
        }
        else if UIScreen.main.bounds.width == 375 {
            presenterImageView.height = 126.0
        }
        else {
            presenterImageView.height = 107.0
        }
        
        let URLString = self.item.coverImageUrl;
        let url = URL(string: URLString)
        presenterImageView.kf.setImage(with: url)
        
        contentLabel.font = UIFont(name: font_regular, size: 12.0);
        dateLabel.font = UIFont(name: font_header_regular, size: 18.0);
        
        contentLabel.text = self.item.dsc;
        dateLabel.text = CustomFunc.getDateShow(dateIn: self.item.onAir) as String
        
        if self.lists.count > 0 {
            if self.lists[0].isFavourite == false {
                favoriteButton.tintColor = Color.blueGrey.base
            }
            else {
                favoriteButton.tintColor = Color.red.base
            }
            
            if (self.lists[0].downloadStatus == "Done") || (self.lists[0].downloadStatus == "Downloading") {
                downloadButton.tintColor = Color.red.base
            }
            else {
                downloadButton.tintColor = Color.blueGrey.base
            }
        }
        else {
            favoriteButton.tintColor = Color.blueGrey.base
            downloadButton.tintColor = Color.blueGrey.base
        }
        
        card.x = 0
        card.y = 0
        card.width = width
        
        card.setNeedsLayout()
        card.layoutIfNeeded()
    }
    
    open override func prepare() {
        super.prepare()
        
        layer.rasterizationScale = Screen.scale
        layer.shouldRasterize = true
        
        pulseAnimation = .none
        backgroundColor = nil
        
        prepareDateLabel()
//        prepareMoreButton()
        prepareToolbar()
        prepareFavoriteButton()
        prepareShareButton()
        preparePresenterImageView()
        prepareContentLabel()
        prepareBottomBar()
        preparePresenterCard()
    }
    
//    private func prepareMoreButton() {
//        moreButton = IconButton(image: Icon.cm.moreVertical, tintColor: Color.blueGrey.base)
//    }
    
    private func prepareFavoriteButton() {
        favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.blueGrey.base)
        downloadButton = IconButton(image: Icon.arrowDownward, tintColor: Color.blueGrey.base)
    }
    
    private func prepareShareButton() {
        shareButton = IconButton(image: Icon.cm.share, tintColor: Color.blueGrey.base)
    }
    
    private func prepareDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .right
    }
    
    private func prepareToolbar() {
        toolbar = Toolbar()
        toolbar.heightPreset = .medium
        toolbar.contentEdgeInsetsPreset = .square3
        toolbar.titleLabel.textAlignment = .left
        toolbar.detailLabel.textAlignment = .left
        toolbar.centerViews = [dateLabel]
//        toolbar.rightViews = [moreButton]
        toolbar.dividerColor = Color.grey.lighten3
        toolbar.dividerAlignment = .top
    }
    
    private func preparePresenterImageView() {
        presenterImageView = UIImageView()
        presenterImageView.contentMode = .scaleAspectFill
    }
    
    private func prepareContentLabel() {
        contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        contentLabel.font = RobotoFont.regular(with: 14)
    }
    
    private func prepareBottomBar() {
        bottomBar = Bar()
        bottomBar.heightPreset = .xlarge
        bottomBar.contentEdgeInsetsPreset = .square3
        bottomBar.centerViews = [dateLabel]
        bottomBar.leftViews = [favoriteButton, downloadButton]
        bottomBar.rightViews = [shareButton]
        bottomBar.dividerColor = Color.grey.lighten3
    }
    
    private func preparePresenterCard() {
        card.toolbar = toolbar
        card.presenterView = presenterImageView
        card.contentView = contentLabel
        card.contentViewEdgeInsetsPreset = .square3
        card.contentViewEdgeInsets.bottom = 0
        card.bottomBar = bottomBar
        card.depthPreset = .none
        
        contentView.addSubview(card)
    }
}
