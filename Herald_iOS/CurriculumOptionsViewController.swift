import UIKit
import SwiftyJSON

class CurriculumOptionsViewController : UITableViewController, LoginUserNeeded {
    
    let swiper = SwipeRefreshHeader()
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        swiper.refresher = {
            self.refreshCache()
        }
        tableView.tableHeaderView = swiper
        
        loadCache()
        refreshCache()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationColor(0x00abd4)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        swiper.beginDrag()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        swiper.endDrag()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        swiper.syncApperance()
    }
    
    func loadCache() {
        floatClasses.removeAll()
        terms.removeAll()
        nextTerm.removeAll()
        let jsonArray = JSON.parse(Cache.curriculumSidebar.value)
        for json in jsonArray.arrayValue {
            let model = SidebarClassModel(sidebarJson: json)
            if !model.isAdded {
                floatClasses.append(model)
            }
        }
        
        let termStrs = JSON.parse(Cache.curriculumTerm.value).arrayValue.map {$0.stringValue}
        for term in termStrs {
            let t = TermModel(term)
            if t.isAfterUserRegister {
                terms.append(t)
            }
        }
        
        if terms.count > 0 {
            nextTerm.append(terms[0].nextTerm)
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
        (Cache.curriculumSidebar.refresher | Cache.curriculumTerm.refresher).onFinish { success, code in
            self.hideProgressDialog()
            self.loadCache()
            if !success {
                self.showMessage("刷新失败，请重试")
            }
        }.run()
    }
    
    var floatClasses : [SidebarClassModel] = []
    
    var terms : [TermModel] = []
    
    var nextTerm : [TermModel] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["浮动课程", "开学日期修正", "下一学期概览", "历史学期概览"][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return [
            "浮动课程：是指上课时间存在不确定因素，无法在课表上显示的课程，例如新生军训、短学期实训、辅修课、MOOC等。\n\n遇到此类课程，请以授课教师指定的时间安排为准。",
            "设置当前学期提前四周开始，适用于部分无短学期的院系使用。",
            "点击可查看下学期课表概览。临近选课时，该课表只包含院系统一安排课程；选课期间，该课表则为实时选课效果，可供参考。",
            "已自动隐藏你入学前的学期。"
        ][section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(([floatClasses, [], nextTerm, terms][section] as! [Any]).count, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        // 如果数据源没有内容，放没有内容的提示
        if ([floatClasses, [1], nextTerm, terms][indexPath.section] as! [Any]).count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "CurriculumEmptyTableViewCell")!
        }
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumFloatClassTableViewCell") as! CurriculumFloatClassTableViewCell
            cell.setData(sidebarModel: floatClasses[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumOptionTableViewCell") as! CurriculumOptionTableViewCell
            cell.sw.isOn = Cache.curriculumWeekOffset.value == "-4"
            cell.onSwitch = {
                Cache.curriculumWeekOffset.value = cell.sw.isOn ? "-4" : "0"
                SettingsHelper.notifyModuleSettingsChanged()
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurriculumTermTableViewCell") as! CurriculumTermTableViewCell
            cell.setData(term: ([floatClasses, [], nextTerm, terms][indexPath.section] as! [TermModel])[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section > 0 {
            let term = [[], [], nextTerm, terms][indexPath.section][indexPath.row]
            let termStr = term.rawString
            showProgressDialog()
            ApiSimpleRequest(.post).api("curriculum").uuid().post("term", termStr).onResponse { s, c, r in
                self.hideProgressDialog()
                if s {
                    let content = JSON.parse(r)["content"]
                    let v = CurriculumOverviewView()
                    v.title = term.desc
                    v.view.backgroundColor = UIColor.groupTableViewBackground
                    v.data(obj: content, sidebar: [:])
                    self.navigationController?.pushViewController(v, animated: true)
                } else {
                    self.showMessage("加载该学期课表失败，请重试")
                }
            }.run()
        }
    }
}
