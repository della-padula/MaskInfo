//
//  LocationSearchViewController.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/11.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import Foundation
import UIKit
import NMapsMap
import Alamofire
import SwiftyJSON
import CoreLocation

class LocationSearchViewController: UIViewController, CLLocationManagerDelegate, NMFMapViewDelegate {
    @IBOutlet weak var naverMapView: NMFMapView!
    
    // But Info
    @IBOutlet weak var butInfoView    : UIView!
    @IBOutlet weak var buyDetailView  : UIView!
    @IBOutlet weak var buyShadowView  : UIView!
    @IBOutlet weak var lblLastNumber  : UILabel!
    @IBOutlet weak var lblFrontDesc   : UILabel!
    @IBOutlet weak var lblFrontString : UILabel!
    
    // Detail View
    @IBOutlet weak var detailHeight        : NSLayoutConstraint!
    @IBOutlet weak var detailView          : UIView!
    @IBOutlet weak var detailShadowView    : UIView!
    @IBOutlet weak var lblDetailTitle      : UILabel!
    @IBOutlet weak var lblDetailRemain     : UILabel!
    @IBOutlet weak var lblDetailRemainDesc : UILabel!
    @IBOutlet weak var storeTypeImageView  : UIImageView!
    @IBOutlet weak var lblStockInfo        : UILabel!
    
    
    // Current Position Button View
    @IBOutlet weak var currentPositionView: UIView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBAction func onClickCurrentPosition(_ sender: Any) {
        moveToCurrentPosition()
    }
    
    // User Position Button View
    @IBOutlet weak var searchNowPositionView: UIView!
    @IBOutlet weak var userPositionImageView: UIImageView!
    @IBAction func onClickUserPosition(_ sender: Any) {
        self.loadStoreFromCurrentPosition(lat: self.naverMapView.cameraPosition.target.lat, lng: self.naverMapView.cameraPosition.target.lng)
    }
    
    var locationManager: CLLocationManager!
    var curLatitude: Double = 37.566642
    var curLongitude: Double = 126.978456
    
    var distance: Int = 1000 // 1km (m 단위)
    var isInitialLoaded = false
    
    var markerList = [NMFMarker]()
    
    private func setBuyInfo() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .weekday], from: date)
        
        let weekday = components.weekday ?? 1
        
        // 1, 2, 3, 4, 5
        // 6, 7, 8, 9, 10
        if weekday > 1 && weekday < 7 {
            lblFrontDesc.text = "주민번호 연도 끝자리"
            lblLastNumber.text = "\(weekday - 1), \(weekday + 4)"
            lblFrontString.text = "주민번호 앞자리가 X\(weekday - 1)XXXX, X\(weekday + 4)XXXX"
        } else {
            lblFrontDesc.text = "마스크를 판매하지 않습니다."
            lblLastNumber.text = ""
            lblFrontString.text = "평일에 구매 가능합니다."
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocation()
        self.setBuyInfo()
        
        self.detailHeight.constant = 0
        
        self.detailView.layer.cornerRadius = 12
        self.detailView.clipsToBounds = true
        
        self.buyDetailView.layer.cornerRadius = 12
        self.buyDetailView.clipsToBounds = true
        
        self.buyShadowView.layer.shadowPath = UIBezierPath(rect: self.buyShadowView.bounds).cgPath
        self.buyShadowView.layer.shadowColor = UIColor.black.cgColor
        self.buyShadowView.layer.shadowOffset = .zero
        self.buyShadowView.layer.shadowOpacity = 0.4
        self.buyShadowView.layer.shadowRadius = 12
        
        self.detailShadowView.layer.shadowPath = UIBezierPath(rect: self.detailShadowView.bounds).cgPath
        self.detailShadowView.layer.shadowColor = UIColor.black.cgColor
        self.detailShadowView.layer.shadowOffset = .zero
        self.detailShadowView.layer.shadowOpacity = 0.4
        self.detailShadowView.layer.shadowRadius = 12
        
        self.naverMapView.minZoomLevel = 13.0
        self.naverMapView.maxZoomLevel = 15.0
        self.naverMapView.delegate = self
        
        let image = UIImage(named: "compass")?.withRenderingMode(.alwaysTemplate)
        self.locationImageView.tintColor = .white
        self.locationImageView.image = image
        
        self.userPositionImageView.tintColor = UIColor(hex: "#1B3B86", alpha: 1.0)
        self.userPositionImageView.image = image
        
        self.searchNowPositionView.layer.cornerRadius = 24
        self.searchNowPositionView.layer.borderWidth = 1.5
        self.searchNowPositionView.layer.borderColor = UIColor(hex: "#1B3B86", alpha: 1.0).cgColor
    }
    
    private func setLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func moveToCurrentPosition() {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: curLatitude, lng: curLongitude))
        cameraUpdate.animation = .easeIn
        naverMapView.moveCamera(cameraUpdate)
    }
    
    func loadStoreFromCurrentPosition(lat: Double, lng: Double) {
        let requestURL = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json?lat=\(lat)&lng=\(lng)&m=\(distance)"
        
        AF.request(requestURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                print(JSON(value)["count"])
                if let jsonArray = JSON(value)["stores"].array {
                    for marker in self.markerList {
                        marker.mapView = nil
                    }
                    
                    self.markerList.removeAll()
                    
                    for jsonObject in jsonArray {
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
                            print("remainStatusString : \(remainStatusString)")
                            remainStatus = .unknown
                            break
                        }
                        
                        if let lat = jsonObject["lat"].double, let lng = jsonObject["lng"].double {
                            let marker = NMFMarker()
                            marker.position = NMGLatLng(lat: lat, lng: lng)
                            
                            switch(remainStatus) {
                            case .plenty:
                                marker.iconImage = NMFOverlayImage(image: UIImage(named: "circle_green")!)
                            case .someThing:
                                marker.iconImage = NMFOverlayImage(image: UIImage(named: "circle_yellow")!)
                            case .few:
                                marker.iconImage = NMFOverlayImage(image: UIImage(named: "circle_red")!)
                            case .empty:
                                marker.iconImage = NMFOverlayImage(image: UIImage(named: "circle_gray")!)
                            default:
                                marker.iconImage = NMFOverlayImage(image: UIImage(named: "circle_unknown")!)
                            }
                            marker.width = 40
                            marker.height = 40
                            marker.mapView = self.naverMapView
                            
                            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                                
                                

                                self.showDetailView(item: ResultStore(pharmacyName: pharmacyName, address: address, stockAt: stockAt, latitude: latitude, longitude: longitude, storeType: type, code: uniqueCode, remainStatus: remainStatus))
                                return true
                            }
                            self.markerList.append(marker)
                        }
                    }
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    func showDetailView(item: ResultStore) {
        self.lblDetailTitle.text = item.pharmacyName ?? ""
        detailHeight.constant = 136
        
        var remainStatusString = ""
        var remainStatusStringDesc = ""
        
        switch(item.remainStatus) {
        case .plenty:
            remainStatusString = "충분"
            self.lblDetailRemain.textColor = .GREEN
            remainStatusStringDesc = "(100개 이상)"
        case .someThing:
            remainStatusString = "보통"
            self.lblDetailRemain.textColor = .YELLOW
            remainStatusStringDesc = "(30개 이상 100개 미만)"
        case .few:
            remainStatusString = "부족"
            self.lblDetailRemain.textColor = .RED
            remainStatusStringDesc = "(30개 미만)"
        case .empty:
            remainStatusString = "품절"
            self.lblDetailRemain.textColor = .GRAY
            remainStatusStringDesc = "(2개 미만)"
        case .unknown:
            remainStatusString = "알 수 없음"
            self.lblDetailRemain.textColor = .UNKNOWN
            remainStatusStringDesc = ""
        default:
            break
        }
        
        var image: UIImage?
        
        switch(item.storeType) {
        case .pharmacy:
            image = UIImage(named: "pharmacy")!
        case .post:
            image = UIImage(named: "post")!
        case .nonghyup:
            image = UIImage(named: "nonghyup")!
        default:
            break
        }
        if image != nil {
            self.storeTypeImageView.image = image!
        }
        self.lblDetailRemain.text = remainStatusString
        self.lblDetailRemainDesc.text = remainStatusStringDesc
        
        var stockText = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        if let date = dateFormatter.date(from: item.stockAt ?? "") {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let hour = calendar.component(.day, from: date)
            let min = calendar.component(.minute, from: date)
            
            stockText = "\(year)년 \(month)월 \(day)일 \(hour)시 \(min)분"
        }
        
        self.lblStockInfo.text = stockText
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        var isLatChanged = false
        var isLngChanged = false
        
        if curLatitude != Double(locValue.latitude) {
            curLatitude = Double(locValue.latitude)
            isLatChanged = true
        }
        
        if curLongitude != Double(locValue.longitude) {
            curLongitude = Double(locValue.longitude)
            isLngChanged = true
        }
        
        if isLatChanged && isLngChanged {
            print("curLat : \(curLatitude), curLng : \(curLongitude)")
            
            if !isInitialLoaded {
                self.isInitialLoaded = true
                self.moveToCurrentPosition()
                self.loadStoreFromCurrentPosition(lat: curLatitude, lng: curLongitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // Naver Map Delegate
    
    func mapViewRegionIsChanging(_ mapView: NMFMapView, byReason reason: Int) {
        print("카메라 변경 - reason: \(reason)")
    }
    
    // 지도를 탭하면 정보 창을 닫음
    func didTapMapView(_ point: CGPoint, latLng latlng: NMGLatLng) {
        print("지도 탭")
        detailHeight.constant = 0
    }
}

extension UIColor {
    open class var GREEN: UIColor {
        get {
            return UIColor(hex: "#00B140", alpha: 1.0)
        }
    }
    
    open class var YELLOW: UIColor {
        get {
            return UIColor(hex: "#C7622D", alpha: 1.0)
        }
    }
    
    open class var RED: UIColor {
        get {
            return UIColor(hex: "#C72B4F", alpha: 1.0)
        }
    }
    
    open class var GRAY: UIColor {
        get {
            return UIColor(hex: "#DADADA", alpha: 1.0)
        }
    }
    
    open class var UNKNOWN: UIColor {
        get {
            return UIColor(hex: "#343434", alpha: 1.0)
        }
    }
}
