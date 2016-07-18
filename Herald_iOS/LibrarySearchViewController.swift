import UIKit
import SwiftyJSON

class LibrarySearchViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    
    @IBOutlet var searchBar : UISearchBar!
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56
    }
    
    override func viewDidAppear(animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let keyword = searchBar.text == nil ? "" : searchBar.text!
        searchBar.resignFirstResponder()
        showProgressDialog()
        ApiSimpleRequest(checkJson200: true).api("search").uuid().post("book", keyword)
            .onResponse { success, _, response in
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
        for book in JSON.parse(response)["content"].arrayValue {
            resultList.append(LibraryBookModel(searchResultJson: book))
        }
        tableView.reloadData()
    }
    
    var resultList : [LibraryBookModel] = []
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, resultList.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if resultList.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("LibrarySearchEmptyTableViewCell")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LibrarySearchTableViewCell") as! LibrarySearchTableViewCell
        let model = resultList[indexPath.row]
        cell.title.text = model.title
        cell.line1.text = model.line1
        cell.line2.text = model.line2
        cell.count.text = model.count
        return cell
    }
}
