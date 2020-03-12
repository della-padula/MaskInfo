//
//  FetchModule.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum APIResult {
    case success
    case addrError
    case error
}

class FetchModule {
    static let distance = 1000
    static func fetchStoreListByLocation(lat: Double, lng: Double, completion: @escaping (APIResult, [ResultStore]?) -> Void) {
        let requestURL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json?lat=\(lat)&lng=\(lng)&m=\(distance)"
        
        AF.request(requestURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                var itemArray = [ResultStore]()
                
                if let jsonArray = JSON(value)["stores"].array {
                    for jsonObject in jsonArray {
                        itemArray.append(self.parseStoreData(jsonObject: jsonObject))
                    }
                    completion(.success, itemArray)
                } else {
                    completion(.error, nil)
                }
            case .failure(_):
                completion(.error, nil)
            }
        }
    }
    
    static func fetchStoreListByAddress(address: String, completion: @escaping (APIResult, [ResultStore]?) -> Void) {
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.addrError, nil)
            return
        }
        
        let requestURL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByAddr/json?address=\(encodedAddress)"
        
        AF.request(requestURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                var itemArray = [ResultStore]()
                
                if let jsonArray = JSON(value)["stores"].array {
                    for jsonObject in jsonArray {
                        itemArray.append(self.parseStoreData(jsonObject: jsonObject))
                    }
                    completion(.success, itemArray)
                } else {
                    completion(.error, nil)
                }
            case .failure(_):
                completion(.error, nil)
            }
        }
    }
    
    static func parseStoreData(jsonObject: JSON) -> ResultStore {
        let pharmacyName       = jsonObject["name"].string
        let stockAt            = jsonObject["stock_at"].string
        let remainStatusString = jsonObject["remain_stat"].string
        let storeType          = jsonObject["type"].string
        let address            = jsonObject["addr"].string
        let uniqueCode         = jsonObject["code"].string
        let latitude           = jsonObject["lat"].float
        let longitude          = jsonObject["lng"].float
        
        var type: StoreType?
        var remainStatus: RemainStatus?
        
        switch(storeType) {
        case "01":
            type = .pharmacy
        case "02":
            type = .post
        case "03":
            type = .nonghyup
        default:
            break
        }
        
        switch(remainStatusString) {
        case "plenty":
            remainStatus = .plenty
        case "some":
            remainStatus = .someThing
        case "few":
            remainStatus = .few
        case "empty":
            remainStatus = .empty
        default:
            remainStatus = .unknown
        }
        
        return ResultStore(pharmacyName: pharmacyName, address: address, stockAt: stockAt, latitude: latitude, longitude: longitude, storeType: type, code: uniqueCode, remainStatus: remainStatus)
    }
}
