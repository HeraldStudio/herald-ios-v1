import UIKit
import SwiftyJSON

class GymAddFriendViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var searchBar : UISearchBar!
    
    override func viewDidAppear(animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let keyword = searchBar.text == nil ? "" : searchBar.text!
        searchBar.resignFirstResponder()
        showProgressDialog()
        ApiSimpleRequest(checkJson200: true).api("yuyue")
            .uuid().post("method", "getFriendList", "cardNo", keyword).onResponse { success, _, response in
            self.hideProgressDialog()
            if success {
                self.loadData(response)
            } else {
                self.searchBar.resignFirstResponder()
                self.showMessage("加载失败，请重试")
            }
        }.run()
    }
    
    func loadData (response : String) {
        resultList.removeAll()
        for person in JSON.parse(response)["content"].arrayValue {
            resultList.append(GymFriendModel(json: person))
        }
        tableView.reloadData()
    }
    
    var resultList : [GymFriendModel] = []
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GymFriendResultCell") as! GymFriendResultCell
        let model = resultList[indexPath.row]
        cell.name.text = model.name
        cell.department.text = model.department
        let title = model.isMyFriend ? "已添加" : "添加"
        cell.button.setTitle(title, forState: .Normal)
        cell.button.setTitle(title, forState: .Highlighted)
        cell.button.setTitle(title, forState: .Selected)
        cell.toggleAction = { () in
            let isMyself = String(model.userId) == CacheHelper.get("herald_gymreserve_userid")
            if isMyself {
                self.searchBar.resignFirstResponder()
                self.showMessage("不允许添加自己为好友喔~")
                return
            }
            model.toggleFriend()
            self.tableView.reloadData()
        }
        return cell
    }
}
