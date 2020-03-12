//
//  DataModel.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation

public enum RemainStatus {
    case plenty // 100개 이상
    case someThing // 30개 이상 100개 미만
    case few // 2개 이상 30개 미만
    case empty // 1개 이하
    case unknown // 알 수 없음 (nil)
}

public enum StoreType {
    case pharmacy
    case post
    case nonghyup
}

public struct ResultStore {
    var pharmacyName: String? // 약국이름
    var address: String? // 주소
    var stockAt: String? // 입고시간
    var latitude: Float? // 위도
    var longitude: Float? // 경도
    var storeType: StoreType? // 판매점 타입
    var code: String? // 식별 코드
    var remainStatus: RemainStatus? // 재고 타입
}
