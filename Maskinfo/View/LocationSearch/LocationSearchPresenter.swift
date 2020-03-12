//
//  LocationSearchPresenter.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LocationSearchPresenter: LocationSearchPresenterProtocol {
    private var view: LocationSearchViewProtocol!
    private var model = LocationSearchModel()
    
    init(view: LocationSearchViewProtocol) {
        self.view = view
    }
    
    func loadStoreFromCurrentPosition(lat: Double, lng: Double) {
        FetchModule.fetchStoreListByLocation(lat: lat, lng: lng, completion: { (result, list) in
            switch(result) {
            case .success:
                self.model.resultList.removeAll()
                self.model.resultList.append(contentsOf: list!)
                self.view.addMarkerToMap()
            case .error:
                self.view.alertErrorView()
            default:
                break
            }
        })
    }
    
    func getResultList() -> [ResultStore] {
        return self.model.resultList
    }
    
    func getCanBuyNumber() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .weekday], from: date)
        
        let weekday = components.weekday ?? 1
        var descTitle = ""
        var lastNumber = ""
        var frontNumber = ""
        
        // 1, 2, 3, 4, 5
        // 6, 7, 8, 9, 10
        if weekday > 1 && weekday < 7 {
            descTitle = "주민번호 연도 끝자리"
            lastNumber = "\(weekday - 1), \(weekday + 4)"
            frontNumber = "주민번호 앞자리가 X\(weekday - 1)XXXX, X\(weekday + 4)XXXX"
        } else {
            descTitle = "마스크를 판매하지 않습니다."
            lastNumber = ""
            frontNumber = "평일에 구매 가능합니다."
        }
        
        self.view.setBuyInfo(descTitle: descTitle, lastNumber: lastNumber, frontNumber: frontNumber)
    }
}
