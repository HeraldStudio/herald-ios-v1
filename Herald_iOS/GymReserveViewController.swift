import UIKit
import SwiftyJSON

class GymReserveViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, ForceTouchPreviewable, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadCache()
        if GCalendar().hour < 8 || GCalendar().hour >= 20 {
            showMessage("当前不在预约时间，晚些再来吧~")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(0x0075ef)
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshCache()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    @IBAction func refreshCache() {
        showProgressDialog()
        
        // 获取可预约项目列表
        ( Cache.gymReserveGetDate.refresher
        // 获取我的预约列表
        | Cache.gymReserveMyOrder.refresher
        // 预获取用户手机号
        | Cache.gymReserveGetPhone.refresher
        ).onFinish { success, _ in
            self.hideProgressDialog()
            if success {
                self.loadCache()
            } else {
                self.showMessage("获取失败，请重试")
            }
        }.run()
        
        // 如果缓存的用户ID为空，预查询用户ID
        Cache.gymReserveUserId.refreshIfEmpty()
    }
    
    func loadCache() {
        let timeAndItemListCache = Cache.gymReserveGetDate.value
        let userIdCache = Cache.gymReserveUserId.value
        let myOrderCache = Cache.gymReserveMyOrder.value
        
        if timeAndItemListCache == "" || userIdCache == "" {
            refreshCache()
            return
        }
        
        sports.removeAll()
        for item in JSON.parse(timeAndItemListCache)["content"]["itemList"].arrayValue {
            sports.append(GymSportModel(json: item))
        }
        
        myOrder.removeAll()
        var hasInvalid = false
        
        for item in JSON.parse(myOrderCache)["content"]["rows"].arrayValue {
            let model = GymRecordModel(json: item)
            myOrder.append(model)
            
            if model.floorName == "" && model.state == 2 {
                hasInvalid = true
            }
        }
        if hasInvalid {
            showQuestionDialog("预约记录中包含无效地点记录，预约将无法正常生效，请及时取消！") {}
        }
        
        tableView.reloadData()
    }
    
    var sports : [GymSportModel] = []
    
    var myOrder : [GymRecordModel] = []
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["新增预约", "最近预约记录"][section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [max(1, sports.count), max(1, myOrder.count)][section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if sports.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("GymReserveEmptyTableViewCell")!
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("GymReserveTableViewCell") as! GymReserveTableViewCell
            cell.name.text = sports[indexPath.row].name
            return cell
        } else {
            if myOrder.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("GymReserveRecordEmptyTableViewCell")!
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("GymReserveRecordTableViewCell") as! GymReserveRecordTableViewCell
            let model = myOrder[indexPath.row]
            cell.title.text = model.title
            cell.state.text = model.stateTip
            cell.desc.text = model.desc
            cell.userInteractionEnabled = model.canCancel
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("MODULE_GYMRESERVE_CHOOSETIME") as! GymChooseTimeViewController
            vc.title = sports[indexPath.row].name
            vc.sport = sports[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            let model = myOrder[indexPath.row]
            if model.canCancel {
                showQuestionDialog("确定要取消该预约吗？", runAfter: {
                    self.showProgressDialog()
                    ApiSimpleRequest(.Post).api("yuyue").uuid().post("method", "cancelUrl", "id", String(model.id)).onResponse { _, _, response in
                        self.hideProgressDialog()
                        let success = JSON.parse(response)["content"]["msg"].stringValue == "success"
                        if success {
                            self.refreshCache()
                        } else {
                            self.showMessage("取消预约失败")
                        }
                    }.run()
                })
            }
        }
    }
}
