import UIKit
import AVFoundation
import TuneURL

var player: AVAudioPlayer?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        tuneURLTrigger()
        setupAppearance()
        loadMain()
        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        API.shared.clearCache()
    }
    
    func loadMain() {
        let controller = Main()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
    
    fileprivate func setupAppearance() {
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .purple
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    func tuneURLTrigger() {
        guard let url = Bundle.main.url(forResource: "trigger", withExtension: "wav") else { return }

        Detector.setTrigger(url)
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            /* iOS 10 and earlier require the following line:
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//
//            guard let player = player else { return }
//
//            player.play()
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
    }
}

