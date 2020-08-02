# BGWaterfallsFlowView
一个Swift版基于UICollectionView封装的瀑布流控件，自带上下拉刷新功能。简单易用，集成到项目中仅仅只需要三步，轻轻松松分分钟。

## 主要功能
  - 瀑布流布局
  - 上下拉刷新加载数据
  
## 环境要求
  - iOS8.0+    
  - Xcod11.0+
 
## Installation
#### CocoaPods:

```
 pod "BGWaterfallsFlowView"
```  

#### 手动安装：

导入"BGWaterfallsFlowView"文件夹至目标工程。

## 使用方法：

内部封装了BGWaterfallsFlowView和BGRefreshWaterfallsFlowView两个瀑布流视图。BGRefreshWaterfallsFlowView自带EGO下拉刷新和自定义加载更多，以下就是BGRefreshWaterfallsFlowView使用步骤（如使用BGWaterfallsFlowView详见[使用方法](https://github.com/yangshebing/BGWaterfallsFlowView/blob/master/BGWaterfallsFlowView.md)）。

（1）初始化瀑布流控件视图

```
    let waterFlowView = BGRefreshWaterfallsFlowView(frame: view.bounds)
    //设置代理
    waterFlowView.dataSource = self
    waterFlowView.delegate = self
    //设置瀑布流列数
    waterFlowView.columnNum = 4
    //设置cell与cell之间的水平间距
    waterFlowView.horizontalItemSpacing = 10
    //设置cell与cell之间的垂直间距
    waterFlowView.verticalItemSpacing = 10
    waterFlowView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    view.addSubview(waterFlowView)
    //注册Cells
    waterFlowView.register(BGCollectionViewCell.self, forCellWithReuseIdentifier: MainViewController.bgCollectionCellIdentify)
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

（3）实现`BGRefreshWaterfallsFlowViewDelegate`上下拉刷新加载数据代理方法

```
func pullDownWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
    //下拉加载最新数据
    ...
    refreshWaterfallsFlowView.reloadData()
    refreshWaterfallsFlowView.pullDownDidFinishedLoadingRefresh()
}

func pullDownWithRefreshWaterfallsFlowView(_ refreshWaterfallsFlowView: BGRefreshWaterfallsFlowView) {
    //上拉加载更多数据
    ...
    refreshWaterfallsFlowView.reloadData()
    refreshWaterfallsFlowView.pullUpDidFinishedLoadingMore()
}

//点击cell的代理方法
func waterfallsFlowView(_ waterfallsFlowView: BGWaterfallsFlowView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath)
}
```
## Demo效果截图
![](http://ww1.sinaimg.cn/mw690/7f266405jw1ey22tbuohvg20ab0inqva.gif)

## 协议许可
BGWaterfallsFlowView遵循MIT许可协议。有关详细信息,请参阅许可协议。

