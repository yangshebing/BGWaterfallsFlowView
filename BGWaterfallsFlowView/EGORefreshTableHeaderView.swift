//
//  EGORefreshTableHeaderView.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit
import QuartzCore

func textColor() -> UIColor {
    return UIColor(red: 87.0/255.0, green: 108.0/255.0, blue: 137.0/255.0, alpha: 1.0)
}

public protocol EGORefreshTableHeaderViewDelegate : NSObjectProtocol {
    func egoRefreshTableHeaderViewDidTriggerRefresh(_ view:EGORefreshTableHeaderView)
    func egoRefreshTableHeaderDataSourceIsLoading(_ view:EGORefreshTableHeaderView) -> Bool
    func egoRefreshTableHeaderDataSourceLastUpdated(_ view:EGORefreshTableHeaderView) -> NSDate?
    
}

extension EGORefreshTableHeaderViewDelegate {
    func egoRefreshTableHeaderDataSourceLastUpdated(_ view:EGORefreshTableHeaderView) -> NSDate? {
        return nil
    }
}

public class EGORefreshTableHeaderView: UIView {
    enum EGOPullRefreshState: Int {
        case pulling
        case normal
        case loading
    }
    
    static let flipAnimationDuration = 0.18
    static let topInset = CGFloat(65.0)
    weak var delegate: EGORefreshTableHeaderViewDelegate?
    var state: EGOPullRefreshState = .normal {
        willSet {
            switch newValue {
            case .pulling: do {
                statusLabel?.text = NSLocalizedString("Release to refresh...", comment: "Release to refresh status")
                CATransaction.begin()
                CATransaction.setAnimationDuration(EGORefreshTableHeaderView.flipAnimationDuration)
                arrowImage?.transform = CATransform3DMakeRotation(CGFloat((Double.pi / 180.0) * 180.0), 0.0, 0.0, 1.0)
                CATransaction.commit()
            }
            case .normal: do {
                if (state == .pulling) {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(EGORefreshTableHeaderView.flipAnimationDuration)
                    arrowImage?.transform = CATransform3DIdentity
                    CATransaction.commit()
                }
                statusLabel?.text = NSLocalizedString("Pull down to refresh...", comment: "Pull down to refresh status")
                activityView?.stopAnimating()
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                arrowImage?.isHidden = false
                arrowImage?.transform = CATransform3DIdentity
                CATransaction.commit()
            }
            case .loading: do {
                statusLabel?.text = NSLocalizedString("Loading...", comment: "Loading Status")
                activityView?.startAnimating()
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                arrowImage?.isHidden = true
                CATransaction.commit()
            }}
        }
    }
    var lastUpdatedLabel: UILabel?
    var statusLabel: UILabel?
    var arrowImage: CALayer?
    var activityView: UIActivityIndicatorView?
    
    public init(_ frame:CGRect, arrowImageName arrow:String, _ textColor:(UIColor)) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor(red: 226.0/255.0, green: 231.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        let lastUpdatedLabel = UILabel(frame: CGRect.init(x: 0.0, y: frame.size.height - 30, width: frame.size.width, height: 20.0))
        lastUpdatedLabel.autoresizingMask = .flexibleWidth
        lastUpdatedLabel.font = UIFont.systemFont(ofSize: 12.0)
        lastUpdatedLabel.textColor = textColor
        lastUpdatedLabel.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        lastUpdatedLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        lastUpdatedLabel.backgroundColor = UIColor.clear
        lastUpdatedLabel.textAlignment = .center
        addSubview(lastUpdatedLabel)
        self.lastUpdatedLabel = lastUpdatedLabel
        
        let statusLabel = UILabel(frame: CGRect.init(x: 0.0, y: frame.size.height - 48, width: frame.size.width, height: 20.0))
        statusLabel.autoresizingMask = .flexibleWidth
        statusLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        statusLabel.textColor = textColor
        statusLabel.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        statusLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        statusLabel.backgroundColor = UIColor.clear
        statusLabel.textAlignment = .center
        addSubview(statusLabel)
        self.statusLabel = statusLabel
        
        let layer = CALayer()
        layer.frame = CGRect(x: 25.0, y: frame.size.height - EGORefreshTableHeaderView.topInset, width: 30, height: 55)
        layer.contentsGravity = .resizeAspect
        layer.contents = named(name: arrow).cgImage
        layer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(layer)
    
        self.arrowImage = layer
        
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.frame = CGRect(x: 25, y: frame.size.height - 38.0, width: 20.0, height: 20.0)
        addSubview(activityView)
        self.activityView = activityView
        
        state = .normal
    }
    
    override convenience init(frame: CGRect) {
       self.init(frame, arrowImageName: "blueArrow.png", textColor())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshLastUpdatedDate() {
        let date = delegate?.egoRefreshTableHeaderDataSourceLastUpdated(self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if date != nil {
            lastUpdatedLabel?.text = String(format: "Last Updated: %@", dateFormatter.string(from: date! as Date))
            UserDefaults.standard.set(lastUpdatedLabel?.text, forKey: "EGORefreshTableView_LastRefresh")
        } else {
            lastUpdatedLabel?.text = nil
        }
    }

    //MARK: 代理方法
    public func egoRefreshScrollViewDidScroll(_ scrollView:UIScrollView) {
        if state == .loading {
            var offset = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsets(top: offset, left: 0.0, bottom: 0.0, right: 0.0)
        } else if scrollView.isDragging {
            var loading = false
            loading = self.delegate!.egoRefreshTableHeaderDataSourceIsLoading(self)
            if (state == .pulling && scrollView.contentOffset.y > -EGORefreshTableHeaderView.topInset && scrollView.contentOffset.y < 0.0 && loading == false) {
                state = .normal
            } else if (state == .normal && scrollView.contentOffset.y < -EGORefreshTableHeaderView.topInset && loading == false) {
                state = .pulling
            }
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = .zero
            }
        }
    }
    
    public func egoRefreshScrollViewDidEndDragging(_ scrollView:UIScrollView) {
        var loading = false
        loading = delegate!.egoRefreshTableHeaderDataSourceIsLoading(self)
        if (scrollView.contentOffset.y <= -EGORefreshTableHeaderView.topInset && loading == false) {
            delegate?.egoRefreshTableHeaderViewDidTriggerRefresh(self)
            state = .loading
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            scrollView.contentInset = UIEdgeInsets(top: 60.0, left: 0.0, bottom: 0.0, right: 0.0)
            UIView.commitAnimations()
        }
    }
    
    public func egoRefreshScrollViewDataSourceDidFinishedLoading(_ scrollView:UIScrollView) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        scrollView.contentInset = .zero
        UIView.commitAnimations()
        state = .normal
    }
    
    func named(name: String) -> UIImage {
        guard let path = Bundle(for: type(of: self)).path(forResource: "BGWaterfallsFlowView", ofType: "bundle") else {
            return UIImage()
        }
        
        guard let image = UIImage(named: name, in: Bundle(path: path), compatibleWith: nil) else {
            return UIImage()
        }
        
        return image
    }
}
