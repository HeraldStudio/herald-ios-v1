import Foundation
import UIKit

class MyInfoViewController: UIViewController {
    
    var parent : MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MyInfoFragment loaded")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
