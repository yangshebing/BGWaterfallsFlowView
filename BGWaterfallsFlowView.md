## BGWaterfallsFlowView使用方法
（1）初始化瀑布流控件视图

```   
    let waterfallsFlowView = BGWaterfallsFlowView(frame: view.bounds)
    //设置代理
    waterfallsFlowView.dataSource = self
    waterfallsFlowView.delegate = self
    //设置列数
    waterfallsFlowView.columnNum = 4
    //设置cell与cell之间的水平间距
    waterfallsFlowView.horizontalItemSpacing = 10
    //设置cell与cell之间的垂直间距
    waterfallsFlowView.verticalItemSpacing = 10
    waterfallsFlowView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    view.addSubview(waterfallsFlowView)
    //注册Cells
    waterfallsFlowView.register(BGCollectionViewCell.self, forCellWithReuseIdentifier: MainViewController.bgCollectionCellIdentify)
```
    
（2）实现`BGWaterfallsFlowViewDataSource`数据源代理方法

```
func waterFlowView(_ waterFlowView: BGWaterfallsFlowView, numberOfItemsIn section: NSInteger) -> Int {
    return dataList?.count ?? 0
}

func waterFlowView(_ waterFlowView: BGWaterfallsFlowView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = (waterFlowView.dequeueReusableCell(withReuseIdentifier: bgCollectionCellIdentify, for: indexPath)) as? BGCollectionViewCell else { return UICollectionViewCell() }
    ...
    return cell
}

//返回Cells指定的高度，一般从服务器获取。
func waterFlowView(_ waterFlowView: BGWaterfallsFlowView, heightForItemAt indexPath: IndexPath) -> CGFloat {
    //return cellHeight
    return 100 + (rand() % 100)
}
```

（3）实现`BGWaterfallsFlowViewDelegate`代理方法

```
//点击cell的代理方法
func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath)
}
```
