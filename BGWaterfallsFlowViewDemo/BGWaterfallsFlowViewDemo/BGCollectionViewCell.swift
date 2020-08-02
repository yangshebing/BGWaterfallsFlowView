//
//  BGCollectionViewCell.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit
import SDWebImage

class BGCollectionViewCell: UICollectionViewCell {
    var picImgView: UIImageView?
    var urlStr: NSString? {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        picImgView = UIImageView(frame: bounds)
        picImgView?.contentMode = .scaleAspectFill
        picImgView?.image = UIImage(named: "example.png")
        clipsToBounds = true
        contentView.addSubview(picImgView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        picImgView?.frame = bounds
        let url = URL(string: urlStr! as String)
        picImgView?.sd_setImage(with: url, completed: nil)
    }
}
