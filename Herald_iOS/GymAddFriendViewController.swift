import UIKit
import SwiftyJSON

class GymAddFriendViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var searchBar : UISearchBar!
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text == nil ? "" : searchBar.text!
        searchBar.resignFirstResponder()
        showProgressDialog()
        ApiSimpleRequest(.post).api("yuyue")
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
    
    func loadData (_ response : String) {
        resultList.removeAll()
        for person in JSON.parse(response)["content"].arrayValue {
            resultList.append(GymFriendModel(json: person))
        }
        tableView.reloadData()
    }
    
    var resultList : [GymFriendModel] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GymFriendResultCell") as! GymFriendResultCell
        let model = resultList[indexPath.row]
        cell.name.text = model.name
        cell.department.text = model.department
        let title = model.isMyFriend ? "已添加" : "添加"
        cell.button.setTitle(title, for: .normal)
        cell.button.setTitle(title, for: .highlighted)
        cell.button.setTitle(title, for: .selected)
        cell.toggleAction = { () in
            let isMyself = String(model.userId) == Cache.gymReserveUserId.value
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
