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
        terms.removeAll()
        
        let termStrs = JSON.parse(Cache.curriculumTerm.value).arrayValue.map {$0.stringValue}.sorted(by: >)
        let advance = Cache.curriculumAdvance.value == "1"
        
        for term in termStrs {
            let t = TermModel(term)
            if t.isAfterUserRegister && (!advance || t.period != 1) {
                terms.append(t)
            }
        }
        
        if terms.count > 0 {
            terms.insert(terms[0].nextTerm, at: 0)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func refreshCache() {
        showProgressDialog()
        Cache.curriculumTerm.refresher.onFinish { success, code in
            self.hideProgressDialog()
            self.loadCache()
            if !success {
                self.showMessage("刷新失败，请重试")
            }
        }.run()
    }
    
    var terms : [TermModel] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["设置", "所有学期列表"][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ["适用于没有短学期的院系，开启后秋季学期将自动提前4周。",
                "点击可查看或切换到其它学期；已自动隐藏你入学前的学期。"][section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, max(terms.count, 1)][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        
        // 如果是第一分区，放开关
        if indexPath.section == 0 {
            let state = Cache.curriculumAdvance.value == "1"
            let cell = CurriculumOptionTableViewCell.instance(for: tableView, state: state, onSwitch: nil)
            cell.onSwitch = {
                Cache.curriculumAdvance.value = cell.sw.isOn ? "1" : "0"
                self.loadCache()
            }
            return cell
        }
        
        // 如果数据源没有内容，放没有内容的提示
        if terms.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "CurriculumEmptyTableViewCell")!
        }
        
        return CurriculumTermTableViewCell.instance(for: tableView, termModel: terms[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && terms.count > 0,
            let v = storyboard?.instantiateViewController(withIdentifier: "MODULE_QUERY_CURRICULUM") as? CurriculumViewController {
            v.term = terms[indexPath.row].rawString
            self.navigationController?.pushViewController(v, animated: true)
        }
    }
}
