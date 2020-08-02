Pod::Spec.new do |spec|
  #项目名称
  spec.name         = 'BGWaterfallsFlowView'
  #版本号
  spec.version      = '1.0.0'
  #开源协议
  spec.license      = 'MIT'
  #对开源项目的描述
  spec.summary      = 'BGWaterfallsFlowView是一个Swift版基于UICollectionView封装瀑布流控件，内部自带上下拉刷新'
  #开源项目的首页
  spec.homepage     = 'https://github.com/yangshebing/BGWaterfallsFlowView'
  #作者信息
  spec.author       = {'yangshebing' => '811068990@qq.com'}
  #项目的源和版本号
  spec.source       = { :git => 'https://github.com/yangshebing/BGWaterfallsFlowView.git', :tag => spec.version }
  #源文件，这个就是供第三方使用的源文件
  spec.source_files = 'BGWaterfallsFlowView/*'
  #依赖的资源文件
  spec.resource_bundles = {
     'BGWaterfallsFlowView' => ['BGWaterfallsFlowView/Resources/*']
  }
  #适用于ios7及以上版本
  spec.platform     = :ios, '8.0'
  #使用的是ARC
  spec.requires_arc = true

  spec.dependency 'SDWebImage', '~> 5.7.3'

end