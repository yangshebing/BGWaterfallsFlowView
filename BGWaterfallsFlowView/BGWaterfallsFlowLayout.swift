//
//  BGWaterfallsFlowLayout.swift
//  BGWaterfallsFlowViewDemo
//
//  Created by yangshebing on 2020/8/01.
//  Copyright © 2020 yangshebing. All rights reserved.
//

import UIKit

public protocol BGWaterfallsFlowLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView:UICollectionView, _ layout:BGWaterfallsFlowLayout, heightForItemAt indexPath:IndexPath) -> CGFloat
}

class BGWaterfallsFlowModel: NSObject {
    var column: Int = 0
    var height: CGFloat = 0.0
    
    required override init() {
        super.init()
    }
    
    class func model(column:Int) -> Self {
        let model = self.init()
        model.column = column
        model.height = 0.0
        return model
    }
}

public class BGWaterfallsFlowLayout: UICollectionViewLayout {
    public var columnNum: Int = 0 {
        didSet {
            invalidateLayout()
        }
    }
    public var horizontalItemSpacing: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    public var verticalItemSpacing: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    public var itemWidth: CGFloat = 0.0  {
        didSet {
            invalidateLayout()
        }
    }
    public var contentInset: UIEdgeInsets = .zero  {
        didSet {
            invalidateLayout()
        }
    }
    public var headerHeight: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    public var footerHeight: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    var cellLayoutInfoDic: NSDictionary?
    var contentSize: CGSize = .zero
    var headerLayoutAttributes: UICollectionViewLayoutAttributes?
    var footerLayoutAttributes: UICollectionViewLayoutAttributes?
    public override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    /**
    *  创建列的信息数组，内部是BGWaterfallsFlowModel对象
    */
    func columnInfoArray() -> NSMutableArray {
        let columnInfoArr = NSMutableArray()
        for index in 0 ..< columnNum {
            let model = BGWaterfallsFlowModel.model(column: index)
            columnInfoArr.add(model)
        }
        return columnInfoArr
    }
    
    /**
    * 数组排序，由于每次只有第一个model的高度会发生变化，所以取出第一个model从后面往前面进行比较，直到找到比高度小于等于它的对象为止
    */
    
    func sortCellLayoutInfoArrayByHeight(infoArray:NSMutableArray) {
        guard let firstModel = infoArray.firstObject as? BGWaterfallsFlowModel else { return }
        infoArray.remove(firstModel)
        
        var insert = false
        for index in (0 ..< infoArray.count).reversed() {
            let obj = infoArray[index] as! BGWaterfallsFlowModel
            if (obj.height <= firstModel.height) {
                infoArray.insert(firstModel, at: index + 1)
                insert = true
                break
            }
        }
        
        if (!insert) {
            infoArray.insert(firstModel, at: 0)
        }
    }
    
    public override func prepare() {
        super.prepare()
        headerLayoutAttributes = nil
        footerLayoutAttributes = nil
        guard let collectionView = self.collectionView else { return }
        //计算宽度
        let space = horizontalItemSpacing * (CGFloat(columnNum) - 1)
        let actual_width = collectionView.frame.size.width - space - contentInset.left - contentInset.right
        itemWidth = actual_width / CGFloat(columnNum)
        
        //头视图
        if (headerHeight > 0) {
            headerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0) as IndexPath)
            headerLayoutAttributes?.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: headerHeight)
        }
        let cellLayoutInfoDic = NSMutableDictionary()
        let columnInfoArray = self.columnInfoArray()
        let numSections = collectionView.numberOfSections
        for section in 0 ..< numSections {
            let numItems = collectionView.numberOfItems(inSection: section)
            for item in 0 ..< numItems {
                //获取第一个model，以它的高作为y坐标
                guard let firstModel = columnInfoArray.firstObject as? BGWaterfallsFlowModel else { continue }
                let y = firstModel.height;
                let x = contentInset.left + (horizontalItemSpacing + itemWidth) * CGFloat(firstModel.column)
                //获取item高度
                let indexPath = IndexPath(item: item, section: section)
                let itemHeight = (collectionView.delegate as! BGWaterfallsFlowLayoutDelegate).collectionView(collectionView, self, heightForItemAt: indexPath)
                //生成itemAttributes
                let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                itemAttributes.frame = CGRect(x: x, y: y + contentInset.top + headerHeight, width: itemWidth, height: itemHeight)
                //保存新的列高，并进行排序
                firstModel.height = firstModel.height + itemHeight + verticalItemSpacing
                sortCellLayoutInfoArrayByHeight(infoArray: columnInfoArray)
                
                //保存布局信息
                cellLayoutInfoDic[indexPath] = itemAttributes
            }
        }
        
        let dic = cellLayoutInfoDic.copy() as? NSDictionary
        if dic != nil {
            //保存到全局
            self.cellLayoutInfoDic = dic
        }
        
        //内容尺寸
        guard let lastModel = columnInfoArray.lastObject as? BGWaterfallsFlowModel else { return }
        //尾部视图
        if (footerHeight > 0) {
            footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: 0))
            let footer_y = lastModel.height + headerHeight + contentInset.top + contentInset.bottom
            footerLayoutAttributes?.frame = CGRect(x: 0, y: footer_y, width: collectionView.frame.size.width, height: footerHeight)
        }
        let contentSizeHeight = lastModel.height + headerHeight + contentInset.top + contentInset.bottom + footerHeight
        contentSize = CGSize(width: collectionView.frame.size.width, height: contentSizeHeight)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesArrs = NSMutableArray()
        cellLayoutInfoDic?.enumerateKeysAndObjects({ (indexPath, attributes,  stop) in
            if (rect.intersects((attributes as! UICollectionViewLayoutAttributes).frame)) {
                attributesArrs.add(attributes)
            }
        })
        
        if ((headerLayoutAttributes != nil) && rect.intersects(headerLayoutAttributes!.frame)) {
            attributesArrs.add(headerLayoutAttributes as Any)
        }
        if (footerLayoutAttributes != nil && rect.intersects(footerLayoutAttributes!.frame)) {
            attributesArrs.add(footerLayoutAttributes as Any)
        }
        return attributesArrs as? [UICollectionViewLayoutAttributes]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        return attributes
    }
    
    
}
