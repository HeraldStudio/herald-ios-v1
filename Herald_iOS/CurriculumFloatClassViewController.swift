import UIKit
import SwiftyJSON

class CurriculumFloatClassViewController : UITableViewController, LoginUserNeeded {
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        swiper.refresher = {
            self.refreshCache()
        }
        tableView.tableHeaderView = swiper
        
        loadCache()
        
        showTipDialogIfUnknown("浮动课程：是指上课时间存在不确定因素，无法在课表上显示的课程，例如新生军训、短学期实训、辅修课等。\n\n遇到此类课程，请以授课教师指定的时间安排为准。", cachePostfix: "float_class") {}
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationColor(0x00abd4)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        swiper.syncApperance()
    }
    
    func loadCache() {
        dataSource.removeAll()
        let jsonArray = JSON.parse(Cache.curriculumSidebar.value)
        for json in jsonArray.arrayValue {
            let model = SidebarClassModel(sidebarJson: json)
            if !model.isAdded {
                dataSource.append(model)
            }
        }
        tableView.reloadData()
    }
    
    static func getFloatClassCount() -> Int {
        let jsonArray = JSON.parse(Cache.curriculumSidebar.value)
        return jsonArray.arrayValue.map {
            json -> SidebarClassModel in
            SidebarClassModel(sidebarJson: json)
        }.filter {
            !$0.isAdded
        }.count
    }
    
    @IBAction func refreshCache() {
        showProgressDialog()
        Cache.curriculumSidebar.refresh { success, _ in
            self.hideProgressDialog()
            self.loadCache()
            if !success {
                self.showMessage("刷新失败，请重试")
            }
        }
    }
    
    var dataSource : [SidebarClassModel] = []
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// 此处必须有header，否则当列表为空时下拉刷新控件会错位
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "浮动课程列表"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(dataSource.count, 1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 如果数据源没有内容，放没有内容的提示
        if dataSource.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("CurriculumEmptyTableViewCell")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CurriculumFloatClassTableViewCell") as! CurriculumFloatClassTableViewCell
        
        cell.setData(sidebarModel: dataSource[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
