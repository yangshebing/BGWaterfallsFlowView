//
//  MainViewController.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit
import BGWaterfallsFlowView

class MainViewController: UIViewController,BGWaterfallsFlowViewDataSource,BGRefreshWaterfallsFlowViewDelegate {
    static let bgIsRefresh = true
    static let delayTimeSecond = 3.0
    static let bgPageCount = 100
    static let bgCollectionCellIdentify = "BGCollectionCellIdentify"
    var waterfallsFlowView: BGWaterfallsFlowView?
    var dataArr: NSArray?
    var sourceArr: NSArray?
    var dataList: NSMutableArray?
    var cellHeightDic: NSMutableDictionary?
    var page: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "瀑布流试布局"
        navigationController?.navigationBar.isTranslucent = false
        dataList = NSMutableArray()
        cellHeightDic = NSMutableDictionary()
        loadPicturesUrlDataFromPlistFile()
        initSubViews()
    }
    
    func loadPicturesUrlDataFromPlistFile() {
        guard let plist = Bundle.main.path(forResource: "pic_url", ofType: "plist") else { return }
        guard var dataArr = NSArray(contentsOfFile: plist) else { return }
        guard let copyArr = dataArr.mutableCopy() as? NSMutableArray else { return }
        for _ in 0 ..< MainViewController.bgPageCount {
            copyArr.addObjects(from: dataArr as! [Any])
        }
        
        dataArr = copyArr.copy() as! NSArray
        let spaceArr = NSMutableArray()
        var internalArr:NSMutableArray?
        for index in 0 ..< dataArr.count {
            if (index % MainViewController.bgPageCount == 0) {
                internalArr = NSMutableArray()
                spaceArr.add(internalArr as Any)
            }
            internalArr!.add(dataArr[index])
        }
        sourceArr = dataArr
        self.dataArr = spaceArr
    }
    
    func initSubViews() {
        if MainViewController.bgIsRefresh {
            let waterfallsFlowView = BGRefreshWaterfallsFlowView(frame: view.bounds)
            waterfallsFlowView.dataSource = self
            waterfallsFlowView.delegate = self
            waterfallsFlowView.columnNum = 4
            waterfallsFlowView.horizontalItemSpacing = 10
            waterfallsFlowView.verticalItemSpacing = 10
            waterfallsFlowView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            view.addSubview(waterfallsFlowView)
            loadNewRefreshData(refreshWaterfallsFlowView: waterfallsFlowView)
            waterfallsFlowView.register(BGCollectionViewCell.self, forCellWithReuseIdentifier: MainViewController.bgCollectionCellIdentify)
        } else {
            let waterfallsFlowView = BGWaterfallsFlowView(frame: view.bounds)
            waterfallsFlowView.dataSource = self
            waterfallsFlowView.delegate = self
            waterfallsFlowView.columnNum = 4
            waterfallsFlowView.horizontalItemSpacing = 10
            waterfallsFlowView.verticalItemSpacing = 10
            waterfallsFlowView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            view.addSubview(waterfallsFlowView)
            waterfallsFlowView.register(BGCollectionViewCell.self, forCellWithReuseIdentifier: MainViewController.bgCollectionCellIdentify)
            if dataArr?[0] as? NSMutableArray != nil {
                dataList = (dataArr![0] as! NSMutableArray)
            }
            
            waterfallsFlowView.reloadData()
        }
    }
    
    func loadNewRefreshData(refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
        if dataArr != nil, dataArr!.count > 0 {
            dataList?.removeAllObjects()
            page = 0
            dataList?.addObjects(from: dataArr![page] as! [Any])
        }
        refreshWaterfallsFlowView.reloadData()
        refreshWaterfallsFlowView.pullDownDidFinishedLoadingRefresh()
    }
    
    func loadMoreRefreshData(refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
        if (sourceArr!.count - dataList!.count < MainViewController.bgPageCount) {
            refreshWaterfallsFlowView.isLoadMore = false
        } else {
            refreshWaterfallsFlowView.isLoadMore = true
        }
        page = page + 1
        dataList?.addObjects(from: dataArr![page] as! [Any])
        refreshWaterfallsFlowView.reloadData()
        refreshWaterfallsFlowView.pullUpDidFinishedLoadingMore()
    }
    
    //MARK: BGWaterfallsFlowViewDataSource
    func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, numberOfItemsIn section: NSInteger) -> Int {
        return dataList?.count ?? 0
    }
    
    func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = (waterfallsFlowView.dequeueReusableCell(withReuseIdentifier: MainViewController.bgCollectionCellIdentify, for: indexPath)) as? BGCollectionViewCell else { return UICollectionViewCell() }
        if dataList?[indexPath.row] as? NSString != nil {
            cell.urlStr = (dataList![indexPath.row] as! NSString)
        }
        
        cell.setNeedsLayout()
        return cell
    }
    
    func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let heightNumber = cellHeightDic?[indexPath] as? CGFloat
        if heightNumber != nil {
            return heightNumber!
        } else {
            let cellHeight = 100+(arc4random() % 10)
            cellHeightDic![indexPath] = cellHeight
            return CGFloat(cellHeight)
        }
    }
    
    func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    //MARK: BGRefreshWaterfallsFlowViewDelegate
    func pullUpWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + MainViewController.delayTimeSecond) {
            self.loadMoreRefreshData(refreshWaterfallsFlowView: refreshWaterfallsFlowView)
        }
    }
    
    func pullDownWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + MainViewController.delayTimeSecond) {
            self.loadNewRefreshData(refreshWaterfallsFlowView: refreshWaterfallsFlowView)
        }
    }
}
