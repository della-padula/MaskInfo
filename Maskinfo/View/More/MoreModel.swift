//
//  MoreModel.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/13.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

public enum MoreCellType {
    case normal
    case button
    case version
    case inquire
}

class MoreModel: MoreModelProtocol {
    
    func checkForUpdates(isUpdateRequired: inout Bool) {
        guard
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=com.elliott.notissu-ios"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else {
                isUpdateRequired = false
                return
        }
        
        print("🗣 Version Checking...")
        print("🗣 ...Current Version : \(version)")
        print("🗣 ...App Store Version : \(appStoreVersion)")
        
        CommonProperty.currentVersion = version
        CommonProperty.recentVersion = appStoreVersion
        
        if CommonProperty.recentVersion.compare(CommonProperty.currentVersion, options: .numeric) == .orderedDescending {
            isUpdateRequired = true
        } else {
            isUpdateRequired = false
        }
    }
}
