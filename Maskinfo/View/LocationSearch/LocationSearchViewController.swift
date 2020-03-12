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

class LocationSearchViewController: UIViewController, LocationSearchViewProtocol, CLLocationManagerDelegate, NMFMapViewDelegate {
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
        self.presenter.loadStoreFromCurrentPosition(lat: self.naverMapView.cameraPosition.target.lat, lng: self.naverMapView.cameraPosition.target.lng)
    }
    
    private var presenter: LocationSearchPresenterProtocol!
    
    var locationManager: CLLocationManager!
    var curLatitude: Double = 37.566642
    var curLongitude: Double = 126.978456
    
    var distance: Int = 1000 // 1km (m 단위)
    var isInitialLoaded = false
    
    var markerList = [NMFMarker]()
    var infoViewList = [NMFInfoWindow]()
    
    func setBuyInfo(descTitle: String, lastNumber: String, frontNumber: String) {
        lblFrontDesc.text = descTitle
        lblLastNumber.text = lastNumber
        lblFrontString.text = frontNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.getCanBuyNumber()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocation()
        
        self.presenter = LocationSearchPresenter(view: self)
        
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
        
        self.naverMapView.minZoomLevel = 12.0
        self.naverMapView.maxZoomLevel = 16.0
        self.naverMapView.delegate = self
        
        let image = UIImage(named: "compass")?.withRenderingMode(.alwaysTemplate)
        self.locationImageView.tintColor = .white
        self.locationImageView.image = image
        
        self.userPositionImageView.tintColor = .MAIN
        self.userPositionImageView.image = image
        
        self.searchNowPositionView.layer.cornerRadius = 24
        self.searchNowPositionView.layer.borderWidth = 1.5
        self.searchNowPositionView.layer.borderColor = UIColor.MAIN.cgColor
    }
    
    private func setLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // View Protocol
    func addMarkerToMap() {
        for marker in self.markerList {
            marker.mapView = nil
        }
        
        for infoView in self.infoViewList {
            infoView.mapView = nil
        }
        
        self.markerList.removeAll()
        self.infoViewList.removeAll()
        
        for result in self.presenter.getResultList() {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: Double(result.latitude!), lng: Double(result.longitude!))
            
            switch(result.remainStatus) {
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
                for infoView in self.infoViewList {
                    infoView.mapView = nil
                }
                
                self.infoViewList.removeAll()
                
                if result.pharmacyName != nil {
                    let infoWindow = NMFInfoWindow()
                    let dataSource = NMFInfoWindowDefaultTextSource.data()
                    dataSource.title = result.pharmacyName!
                    infoWindow.dataSource = dataSource
                    infoWindow.open(with: marker)
                    
                    self.infoViewList.append(infoWindow)
                }
                self.showDetailView(item: result)
                return true
            }
            self.markerList.append(marker)
        }
    }
    
    func alertErrorView() {
        print("Error Occurred.")
    }
    
    func moveToCurrentPosition() {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: curLatitude, lng: curLongitude))
        cameraUpdate.animation = .easeIn
        naverMapView.moveCamera(cameraUpdate)
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
                self.presenter.loadStoreFromCurrentPosition(lat: curLatitude, lng: curLongitude)
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
        
        for infoView in self.infoViewList {
            infoView.mapView = nil
        }
        
    }
}
