import UIKit
import SwiftyJSON

/**
 * ActivityViewController | 活动版块界面，活动版块列表视图代理和数据源
 * 负责活动版块列表视图、下拉刷新和上拉加载的处理
 */
class ActivityViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// 整体部分：初始化、下拉刷新、上拉加载
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 绑定的列表视图
    @IBOutlet var tableView : UITableView!
    
    /// 当前加载的页数
    var page = 0
    
    /// 下拉刷新和上拉加载方面的处理
    let swiper = SwipeRefreshHeader()
    let puller = PullLoadFooter()
    
    /// 界面实例化时的初始化
    override func viewDidLoad() {
        
        /// 初始化上拉加载控件
        
        // 上拉加载控件初始高度与 TabBar 一致，防止滚动到底部时部分内容被 TabBar 覆盖
        let tw = tabBarController?.tabBar.frame.width
        let th = tabBarController?.tabBar.frame.height
        puller.frame = CGRect(x: 0, y: 0, width: (tw != nil ? tw! : 0), height: (th != nil ? th! + 8 : 8))
        
        // 设置上拉加载控件的加载事件
        puller.loader = {() in
            self.showProgressDialog()
            self.performSelector(#selector(self.loadNextPage), withObject: nil, afterDelay: 1)
        }
        
        // 设置上拉加载控件为列表页脚视图
        tableView.tableFooterView = puller
        
        // 为列表视图设置自适应高度
        tableView.estimatedRowHeight = 240;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        /// 初始化下拉刷新控件
        
        // 下拉刷新控件蒙版颜色
        swiper.themeColor = navigationController?.navigationBar.barTintColor
        
        // 设置下拉刷新控件刷新事件
        swiper.refresher = {() in
            
            // 此处为了防止列表立即刷新导致列表在下拉后突然弹回，延迟1秒刷新，加载框提前显示
            self.showProgressDialog()
            self.performSelector(#selector(self.refreshCache), withObject: nil, afterDelay: 1)
        }
        
        // 设置下拉刷新控件为列表页头视图
        tableView?.tableHeaderView = swiper
        
        /// 联网刷新列表内容
        refreshCache()
    }
    
    /// 当视图准备显示前，显式调用列表重绘，以便切换 Tab 时产生动画效果
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    /// 下拉刷新和上拉加载控件用到的三个 hook
    // 滚动时刷新显示
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance()
        puller.syncApperance()
    }
    
    // 开始拖动，以下两个函数用于让下拉刷新控件判断是否已经松手，保证不会在松手后出现“[REFRESH]”
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
        puller.beginDrag()
    }
    
    // 结束拖动
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
        puller.endDrag()
    }
    
    /// 活动列表部分：刷新列表（活动列表是带上拉加载的多页结构，只缓存第一页）
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 联网刷新并存入缓存，若成功，载入缓存内容；否则显示错误提示
    @IBAction func refreshCache() {
        showProgressDialog()
        ApiRequest().get().url("http://115.28.27.150/herald/api/v1/huodong/get").toCache("herald_activity")
            .onFinish { success, _, _ in
                self.hideProgressDialog()
                self.loadCache()
                
                if !success {
                    self.showMessage("刷新失败，请重试")
                }
        }.run()
    }
    
    /// 载入缓存内容
    func loadCache() {
        
        // 首先清空数据
        data.removeAll()
        
        // 设置当前页数为0，以便在没有得到数据时，上拉加载仍加载第1页内容而不是第2页
        page = 0
        
        // 如果有数据，逐条添加数据，并设置当前页数为1
        for k in JSON.parse(CacheHelper.get("herald_activity"))["content"].arrayValue {
            self.data.append(ActivityModel(k))
            self.page = 1
        }
        
        // 恢复上拉加载控件的可用性
        puller.enable()
        
        // 显式重载列表内容
        tableView.reloadData()
    }
    
    /// 联网加载下一页内容，若成功，加入列表并自增一页；否则显示错误信息
    func loadNextPage() {
        showProgressDialog()
        ApiRequest().get().url("http://115.28.27.150/herald/api/v1/huodong/get?page=\(page + 1)").onFinish { success, _, response in
                self.hideProgressDialog()
                if success {
                    self.page += 1
                    let array = JSON.parse(response)["content"].arrayValue
                    
                    // 此处使用动态方式增加新的 cell，保证只有新出现的 cell 才会产生动画效果
                    self.tableView.beginUpdates()
                    for k in array {
                        
                        // 注意 TableView 的动态修改需要在数据源和视图两边同时进行，若两边不一致则会报错
                        self.data.append(ActivityModel(k))
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.data.count - 1, inSection: 0)], withRowAnimation: .Bottom)
                    }
                    self.tableView.endUpdates()
                    
                    // 若新增的页面没有任何条目，显示信息并禁用上拉加载控件
                    if array.count == 0 {
                        self.showMessage("没有更多数据")
                        self.puller.disable("没有更多数据")
                    }
                } else {
                    self.showMessage("加载失败，请重试")
                }
        }.run()
    }
    
    /// 活动列表部分：活动列表数据源
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 活动列表
    var data : [ActivityModel] = []
    
    /// 列表某分区中条目数目
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count > 0 ? data.count : 1
    }
    
    /// 实例化列表条目
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 无数据时的处理
        if data.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("ActivityEmptyTableViewCell", forIndexPath: indexPath)
        }
        
        // 实例化
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityTableViewCell", forIndexPath: indexPath) as! ActivityTableViewCell
        let model = data[indexPath.row]
        
        // 数据绑定
        cell.title.text = model.title
        cell.assoc.text = model.assoc
        cell.state.text = model.state.rawValue
        
        if let url = NSURL(string: model.picUrl) {
            cell.pic.kf_setImageWithURL(url, placeholderImage: UIImage(named: "default_herald"))
        } else {
            cell.pic.image = UIImage(named: "default_herald")
        }
        
        cell.intro.text = "活动时间：\(model.activityTime)\n活动地点：\(model.location)\n\n\(model.intro)" + (model.detailUrl != "" ? "\n\n查看详情 >" : "")
        
        // 布局调整
        cell.state.textColor = model.state == .Going ? navigationController?.navigationBar.barTintColor : UIColor.grayColor()
        
        return cell
    }
    
    /// 活动列表部分：活动列表代理
    /////////////////////////////////////////////////////////////////////////////////////
    
    /// 自定义列表条目点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 无数据时的处理
        if data.count == 0 { return }
        
        let model = data[indexPath.row]
        
        // 打开对应的详情页面
        if model.detailUrl != "" {
            AppModule(title: "校园活动", url: model.detailUrl).open(navigationController)
        } else {
            showMessage("该活动没有详情页面")
        }
    }
    
    /// 自定义列表条目显示动效
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var rotation = CATransform3D()
        rotation = CATransform3DMakeTranslation(0, 50, 20)
        
        rotation = CATransform3DScale(rotation, 0.9, 0.9, 1)
        rotation.m34 = 1.0 / -600
        
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(10, 10)
        cell.alpha = 0
        
        cell.layer.transform = rotation
        
        UIView.beginAnimations("rotation", context: nil)
        UIView.setAnimationDuration(0.6)
        cell.layer.transform = CATransform3DIdentity
        cell.alpha = 1
        cell.layer.shadowOffset = CGSizeMake(0, 0)
        UIView.commitAnimations()
    }
}