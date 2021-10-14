import UIKit

class Settings: UIViewController {

    @IBOutlet var autoDownloadSwitch: UISwitch!
    @IBOutlet var autoDeleteSwitch: UISwitch!
    @IBOutlet var searchSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func searchCategoryChanged(_ sender: UISwitch) {
        isApplePodcast = sender.isOn
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
