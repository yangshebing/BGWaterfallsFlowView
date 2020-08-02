//
//  BGWaterfallsFlowView.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit

func UIColorFromHex(rgbValue:Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}

//MARK: BGWaterfallsFlowViewDataSource

public protocol BGWaterfallsFlowViewDataSource: NSObjectProtocol {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, numberOfItemsIn section:NSInteger) -> Int
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell;
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, heightForItemAt indexPath:IndexPath) -> CGFloat
}

//MARK: BGWaterfallsFlowViewDelegate

public protocol BGWaterfallsFlowViewDelegate: NSObjectProtocol {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, didSelectItemAt indexPath:IndexPath)
}

extension BGWaterfallsFlowViewDelegate {
    func waterfallsFlowView(_ waterfallsFlowView:BGWaterfallsFlowView, didSelectItemAt indexPath:IndexPath) {
    }
}

public class BGWaterfallsFlowView: UIView, BGWaterfallsFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    static let bgCollectionRefreshHeaderView = "BGCollectionRefreshHeaderView"
    static let bgCollectionRefreshFooterView = "BGCollectionRefreshFooterView"
    static let bgScreenWidth = UIScreen.main.bounds.size.width
    static let bgScreenHeight = UIScreen.main.bounds.size.height
    static let footerHeight = 60
    
    public var columnNum: Int = 0 {
        didSet {
            waterFlowLayout?.columnNum = columnNum
        }
    }
    public var horizontalItemSpacing: CGFloat = 0.0 {
        didSet {
            waterFlowLayout?.horizontalItemSpacing = horizontalItemSpacing
        }
    }
    public var verticalItemSpacing: CGFloat = 0.0 {
        didSet {
            waterFlowLayout?.verticalItemSpacing = verticalItemSpacing
        }
    }
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            waterFlowLayout?.contentInset = contentInset
        }
    }
    public weak var dataSource: BGWaterfallsFlowViewDataSource?
    public weak var delegate: BGWaterfallsFlowViewDelegate?
    
    var collectionView: UICollectionView?
    private var waterFlowLayout: BGWaterfallsFlowLayout?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        let waterFlowLayout = BGWaterfallsFlowLayout()
        waterFlowLayout.columnNum = 4
        waterFlowLayout.horizontalItemSpacing = 15
        waterFlowLayout.verticalItemSpacing = 15
        waterFlowLayout.contentInset = .zero
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: waterFlowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        addSubview(collectionView)
        
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        self.waterFlowLayout = waterFlowLayout
        self.collectionView = collectionView
        
    }
    
    //MARK: UICollectionView的公共方法
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath))!
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    //MARK: UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.waterfallsFlowView(self, numberOfItemsIn: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.waterfallsFlowView(self, cellForItemAt: indexPath)
    }
    
    //MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.waterfallsFlowView(self, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, _ layout: BGWaterfallsFlowLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        return dataSource!.waterfallsFlowView(self, heightForItemAt: indexPath)
    }
}

//MARK: BGRefreshWaterfallsFlowViewDelegate

public protocol BGRefreshWaterfallsFlowViewDelegate : BGWaterfallsFlowViewDelegate {
    /**
    *  下拉刷新加载数据代理方法
    */
    func pullDownWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView:BGRefreshWaterfallsFlowView)
    /**
    *  带刷新的瀑布流
    */
    func pullUpWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView:BGRefreshWaterfallsFlowView)
}

extension BGRefreshWaterfallsFlowViewDelegate {
    func pullDownWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView:BGRefreshWaterfallsFlowView) {
        
    }
    func pullUpWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView:BGRefreshWaterfallsFlowView) {
        
    }
}

//MARK: BGRefreshWaterfallsFlowView
public class BGRefreshWaterfallsFlowView: BGWaterfallsFlowView, EGORefreshTableHeaderViewDelegate {
    /**
    *  加载更多
    */
    public var isLoadMore: Bool = false
    private var refreshTableHeaderView: EGORefreshTableHeaderView?
    private var reloading: Bool = false
    private var loadMoreButton: UIButton?
    private var activityView: UIActivityIndicatorView?
    private var showHintDescLabel: UILabel?
    
    override func initViews() {
        super.initViews()
        let waterFlowLayout = (collectionView!.collectionViewLayout) as! BGWaterfallsFlowLayout
        waterFlowLayout.headerHeight = 1.0
        waterFlowLayout.footerHeight = CGFloat(BGWaterfallsFlowView.footerHeight)
        isLoadMore = true
        //注册头部、尾部
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BGWaterfallsFlowView.bgCollectionRefreshHeaderView)
        collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: BGWaterfallsFlowView.bgCollectionRefreshFooterView)
    }
    
    public override func reloadData() {
        super.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if(kind == UICollectionView.elementKindSectionHeader) {
            //解决多组造成的下拉刷新UI显示异常
            let collectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BGWaterfallsFlowView.bgCollectionRefreshHeaderView, for: indexPath)
            if (refreshTableHeaderView == nil) {
                refreshTableHeaderView = EGORefreshTableHeaderView(frame: CGRect(x: 0.0, y: 0.0 - bounds.size.height, width: frame.size.width, height: bounds.size.height)
                )
                refreshTableHeaderView?.delegate = self
                collectionHeaderView.addSubview(refreshTableHeaderView!)
                refreshTableHeaderView?.backgroundColor = .clear
                refreshTableHeaderView?.refreshLastUpdatedDate()
            }
            return collectionHeaderView
            
        } else {
            let collectionFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: BGWaterfallsFlowView.bgCollectionRefreshFooterView, for: indexPath)
            if (loadMoreButton == nil) {
                loadMoreButton = UIButton(type: .custom)
                loadMoreButton?.backgroundColor = .clear
                loadMoreButton?.frame = CGRect(x: 0, y: 0, width: BGWaterfallsFlowView.bgScreenWidth, height: 40)
                let font = UIFont.systemFont(ofSize: 13.0)
                loadMoreButton?.addTarget(self, action: #selector(loadMoreDataAction), for: .touchUpInside)
                showHintDescLabel = UILabel(frame: CGRect(x: 0, y: 0, width: BGWaterfallsFlowView.bgScreenWidth, height: 13))
                showHintDescLabel?.text = "上拉加载更多图片..."
                showHintDescLabel?.font = font
                showHintDescLabel?.textColor = UIColorFromHex(rgbValue: 0xaaaaaa)
                loadMoreButton?.addSubview(showHintDescLabel!)
                activityView = UIActivityIndicatorView(style: .gray)
                activityView?.frame = CGRect(x: 100, y: 10, width: 20, height: 20)
                activityView?.isHidden = false
                activityView?.stopAnimating()
                refreshHintLabelFrame()
                loadMoreButton?.addSubview(activityView!)
                collectionFooterView.addSubview(loadMoreButton!)
            }
            return collectionFooterView
        }
    }
    
    @objc func loadMoreDataAction() {
        if (isLoadMore == false) {
            return
        }
        loadMoreDataLoadingUI()
        guard let delegate = self.delegate as? BGRefreshWaterfallsFlowViewDelegate else { return }
        delegate.pullUpWithRefreshWaterfallsFlowView(self)
    }
    
    func loadMoreDataLoadingUI() {
        showHintDescLabel?.text = "正在加载中..."
        refreshHintLabelFrame()
        loadMoreButton?.isEnabled = false
        activityView?.startAnimating()
    }
    
    public func pullUpDidFinishedLoadingMore() {
        if isLoadMore == true {
            resetPullUpShowDescriptionString(str: "上拉加载更多图片...")
        } else {
            resetPullUpShowDescriptionString(str: "没有更多图片")
        }
    }
    
    func resetPullUpShowDescriptionString(str: String) {
        loadMoreButton?.isHidden = false
        loadMoreButton?.isEnabled = true
        showHintDescLabel?.text = str
        refreshHintLabelFrame()
        activityView?.stopAnimating()
    }
    
    func refreshHintLabelFrame() {
        let showHintLabelAttDic = [NSAttributedString.Key.font:showHintDescLabel?.font ?? UIFont.systemFont(ofSize: 13.0)]
        let showHintLabelSize = ((showHintDescLabel?.text ?? "") as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 13), options: .usesFontLeading, attributes: showHintLabelAttDic as [NSAttributedString.Key : Any], context: nil).size
        guard let loadMoreButton = self.loadMoreButton else { return }
        let showHintDescLabelX = (loadMoreButton.frame.size.width - showHintLabelSize.width) / 2.0
        let showHintDescLabelY = (loadMoreButton.frame.size.height - showHintLabelSize.height) / 2.0
        showHintDescLabel?.frame = CGRect(x: showHintDescLabelX, y: showHintDescLabelY, width: showHintLabelSize.width, height: showHintLabelSize.height)
        let activityViewX = showHintDescLabel!.frame.origin.x - 5 - activityView!.frame.size.width
        let activityViewY = (loadMoreButton.frame.size.height - activityView!.frame.size.height) / 2.0
        activityView?.frame = CGRect(x: activityViewX, y: activityViewY, width: activityView!.frame.size.width, height: activityView!.frame.size.height)
    }
    
    //MARK: EGORefreshTableHeaderDelegate
    
    public func egoRefreshTableHeaderViewDidTriggerRefresh(_ view: EGORefreshTableHeaderView) {
        let delegate = self.delegate as! BGRefreshWaterfallsFlowViewDelegate
        delegate.pullDownWithRefreshWaterfallsFlowView(self)
    }
    
    public func egoRefreshTableHeaderDataSourceIsLoading(_ view: EGORefreshTableHeaderView) -> Bool {
        return reloading // should return if data source model is reloading
    }
    
    public func egoRefreshTableHeaderDataSourceLastUpdated(_ view: EGORefreshTableHeaderView) -> NSDate? {
        return NSDate() // should return date data source was last changed
    }
    
    //MARK: Data Source Loading / Reloading Methods
    
    func reloadTableViewDataSource() {
        reloading = true
    }
    
    public func pullDownDidFinishedLoadingRefresh() {
        reloading = false
        isLoadMore = true
        resetPullUpShowDescriptionString(str: "上拉加载更多图片...")
        refreshTableHeaderView?.egoRefreshScrollViewDataSourceDidFinishedLoading(collectionView!)
    }
    
    //MARK: UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshTableHeaderView?.egoRefreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshTableHeaderView?.egoRefreshScrollViewDidEndDragging(scrollView)
        let sub = scrollView.contentSize.height - scrollView.contentOffset.y
        if (scrollView.frame.size.height - sub > CGFloat(BGWaterfallsFlowView.footerHeight)) {
            loadMoreDataAction()
        }
    }
}

