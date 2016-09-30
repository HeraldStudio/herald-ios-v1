import UIKit
import SwiftyJSON

class GymChooseTimeViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    var header : GymReserveTableViewHeader!
    
    var picker : UISegmentedControl!
    
    var sport : GymSportModel!
    
    var dateList : [String] = []
    
    let swiper = SwipeRefreshHeader()
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(swiper, 0x0075ef)
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
    override func viewDidLoad() {
        swiper.refresher = {() in self.refreshCache()}
        tableView?.tableHeaderView = swiper
        
        header = tableView.dequeueReusableCellWithIdentifier("GymReserveTableViewHeader") as! GymReserveTableViewHeader
        picker = header.picker
        
        dateList.removeAll()
        picker.removeAllSegments()
        let cache = Cache.gymReserveGetDate.value
        for time in JSON.parse(cache)["content"]["timeList"].arrayValue {
            let title = time["dayInfo"].stringValue
            dateList.append(title)
            var shortTitleComps = title.split("-")
            shortTitleComps.removeAtIndex(0)
            let shortTitle = shortTitleComps.joinWithSeparator("-")
            picker.insertSegmentWithTitle(shortTitle, atIndex: picker.numberOfSegments, animated: false)
        }
        picker.selectedSegmentIndex = 0
        
        refreshCache()
    }
    
    @IBAction func refreshCache() {
        timeList.removeAll()
        tableView.reloadData()
        let index = picker.selectedSegmentIndex
        
        showProgressDialog()
        ApiSimpleRequest(.Post)
            .api("yuyue").uuid().post("method", "getOrder", "itemId", "\(sport.id)", "dayInfo", dateList[picker.selectedSegmentIndex])
            .onResponse { success, _, response in
                self.hideProgressDialog()
                if self.picker.selectedSegmentIndex == index {
                    if success {
                        self.loadData(response)
                    } else {
                        self.showMessage("获取失败，请重试")
                    }
                }
            }.run()
    }
    
    func loadData(response : String) {
        
        timeList.removeAll()
        for time in JSON.parse(response)["content"]["orderIndexs"].arrayValue {
            timeList.append(GymTimeModel(json: time))
        }
        tableView.reloadData()
    }
    
    var timeList : [GymTimeModel] = []
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["选择预约日期", "选择预约时段"][section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, max(1, timeList.count)][section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return header
        }
        
        if timeList.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("GymReserveEmptyTableViewCell")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GymReserveTableViewCell") as! GymReserveTableViewCell
        let time = timeList[indexPath.row]
        cell.name.text = "\(time.availableTime)（剩余\(time.surplus)）"
        cell.setEnabled(time.surplus != 0 && time.enable)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {return}
        
        let date = dateList[picker.selectedSegmentIndex].split(" ")[0]
        let time = timeList[indexPath.row].availableTime
        
        showProgressDialog()
        ApiSimpleRequest(.Post).api("yuyue").uuid().post("method", "judgeOrder", "itemId", String(sport.id), "dayInfo", date, "time", time)
            .onResponse { _, _, response in
                self.hideProgressDialog()
                let success = JSON.parse(response)["content"]["code"].stringValue == "0"
                let code = JSON.parse(response)["content"]["code"].stringValue
                let message = JSON.parse(response)["content"]["msg"].stringValue
                
                if success {
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MODULE_GYMRESERVE_NEW") as! GymNewViewController
                    vc.useTime = date + " " + time
                    vc.sport = self.sport
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showMessage("错误：" + message + "（" + code + "）")
                }
            }.run()
    }
}