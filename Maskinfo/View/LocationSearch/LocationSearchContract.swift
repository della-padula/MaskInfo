//
//  LocationSearchContract.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

protocol LocationSearchViewProtocol {
    func setBuyInfo(descTitle: String, lastNumber: String, frontNumber: String)
    
    func addMarkerToMap(resultArray: [ResultStore])
    
    func alertErrorView()
}

protocol LocationSearchPresenterProtocol {
    func loadStoreFromCurrentPosition(lat: Double, lng: Double)
    
    func getCanBuyNumber()
}
