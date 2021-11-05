import UIKit
import AVFoundation
import TuneURL

var player: AVAudioPlayer?

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		setupTuneURLTrigger()
		setupAppearance()
		return true
	}

	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		API.shared.clearCache()
	}

	fileprivate func setupAppearance() {
		UITabBar.appearance().barTintColor = .white
		UITabBar.appearance().tintColor = .purple
		UITabBar.appearance().unselectedItemTintColor = .lightGray
		UINavigationBar.appearance().prefersLargeTitles = true
	}

	func setupTuneURLTrigger() {
		guard let url = Bundle.main.url(forResource: "trigger", withExtension: "wav") else {
			return
		}

		Detector.setTrigger(url)
	}

}
