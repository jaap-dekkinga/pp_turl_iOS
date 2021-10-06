//
//  HomeVC.swift
//  PPTurl
//
//  Created by mac on 10/6/21.
//

import UIKit

class HomeVC: UIViewController {
    
    var episodes : [Episode] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadEpisodes()
    }
    
    func loadEpisodes() {
        API.shared.getEpisodes { result, resultCnt in
            if (resultCnt > 0) {
                self.episodes = result
            }
        }
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
