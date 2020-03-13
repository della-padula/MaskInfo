//
//  AppDelegate.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/10.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit
import NMapsMap

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NMFAuthManager.shared().clientId = "yp1i7pygla"
        
        if
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=com.elliott.notissu-ios"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String {
            
            print("🗣 Version Checking...")
            print("🗣 ...Current Version : \(version)")
            print("🗣 ...App Store Version : \(appStoreVersion)")
            
            CommonProperty.currentVersion = version
            CommonProperty.recentVersion = appStoreVersion
        }
        return true
    }
}

