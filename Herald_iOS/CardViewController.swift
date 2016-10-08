import Foundation
import UIKit
import SwiftyJSON

class CardViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    static let url = "http://58.192.115.47:8088/wechat-web/login/initlogin.html"
    
    let swiper = SwipeRefreshHeader()
    let puller = PullLoadFooter()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        
        // 设置上拉加载控件的加载事件
        puller.loader = {() in
            let oldCount = self.history.count
            self.displayDays += 7
            self.loadCache()
            let newCount = self.history.count
            if oldCount == newCount {
                self.puller.disable("没有更多数据")
            }
        }
        
        // 设置上拉加载控件为列表页脚视图
        tableView.tableFooterView = puller
        
        loadCache()
        refreshCache() // 自动判断是否需要刷新流水，不需要的话只刷新余额
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(0x03a9f4)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadCache()
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
    
    var history : [[CardRecordModel]] = []
    
    var displayDays = 7
    
    func loadCache() {
        if Cache.cardToday.isEmpty || Cache.card.isEmpty {
            return
        }
        
        // 当天的缓存，这个缓存刷新永远比完整的缓存快
        let todayCache = Cache.cardToday.value
        let cache = Cache.card.value
        
        let extra = JSON.parse(todayCache)["content"]["left"].stringValue.replaceAll(",", "")
        title = "余额：" + extra
        
        history.removeAll()
        let jsonCache = JSON.parse(cache)["content"]
        let jsonTodayCache = JSON.parse(todayCache)["content"]
        let jsonArray = jsonTodayCache["detial"].arrayValue + jsonCache["detial"].arrayValue
        
        var lastDate = ""
        for json in jsonArray {
            let model = CardRecordModel(json: json)
            if model.date != lastDate {
                if history.count >= displayDays {
                    break
                }
                history.append([])
                lastDate = model.date
            }
            
            guard var lastSection = history.last else { self.showError(); return }
            history.removeLast()
            lastSection.append(model)
            history.append(lastSection)
        }
        
        tableView?.reloadData()
    }
    
    @IBAction func refreshCache () {
        showProgressDialog()
        
        // 先加入刷新余额的请求
        var request : ApiRequest = Cache.cardToday.refresher
        
        // 取上次刷新日期，与当前日期比较
        let lastRefresh = Cache.cardDate.value
        let date = GCalendar(.Day)
        let stamp = "\(date.year)/\(date.month)/\(date.day)"
        
        // 若与当前日期不同，刷新完整流水记录
        if lastRefresh != stamp {
            request |= Cache.card.refresher
        }
        
        // 若刷新成功，保存当前日期
        request.onFinish { success, _ in
                    self.hideProgressDialog()
                    if success {
                        Cache.cardDate.value = stamp
                        self.displayDays = 7
                        self.puller.enable()
                        self.loadCache()
                    } else {
                        self.showMessage("刷新失败，请重试或到充值页面查询")
            }
        }.run()
    }
    
    func showError () {
        title = "一卡通"
        showMessage("解析失败，请刷新")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 { return 1 }
        return history[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 {
            return "消费记录"
        }
        var consume : Float = 0.0
        var charge : Float = 0.0
        for model in history[section] {
            if model.isConsume {
                consume -= model.costNum
            } else {
                charge += model.costNum
            }
        }
        
        let consumeTip = consume == 0 ? "" : " / 总支出：\(consume)"
        let chargeTip = charge == 0 ? "" : " / 总收入：\(charge)"
        
        return history[section][0].displayDate + consumeTip + chargeTip
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 若为空，加一个条目提示用户这里是空的
        if history.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("CardEmptyTableViewCell", forIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("CardTableViewCell", forIndexPath: indexPath) as! CardTableViewCell
        
        let model = history[indexPath.section][indexPath.row]
        cell.time?.text = model.time
        cell.place?.text = model.place
        cell.type?.text = model.type
        cell.cost?.text = model.cost
        cell.left?.text = model.left
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 若为空，加一个条目提示用户这里是空的
        return history.count > 0 ? history.count : 1
    }
    
    @IBAction func goToChargePage () {
        showTipDialogIfUnknown("注意：充值之后需要在食堂刷卡机上刷卡，充值金额才能到账哦", cachePostfix: "card_charge") {
            () -> Void in
                self.title = "一卡通"
                AppModule(title: "一卡通充值", url: CardViewController.url).open()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}