import UIKit

class CurriculumSelectAddClassViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, LoginUserNeeded {
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        loadCache()
    }
    
    func loadCache() {
        
    }
    
    var dataSource : [SidebarClassModel] = []
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
