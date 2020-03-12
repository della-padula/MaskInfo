//
//  PositionViewController.swift
//  Maskinfo
//
//  Created by TaeinKim on 2020/03/12.
//  Copyright © 2020 TaeinKim. All rights reserved.
//

import UIKit
import NMapsMap

class PositionViewController: UIViewController {
    
    var item: ResultStore?
    
    @IBOutlet weak var naverMapView: NMFMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.naverMapView.minZoomLevel = 13.0
        self.naverMapView.maxZoomLevel = 16.0
        
        self.addMarkerToStoreLocation()
    }
    
    private func addMarkerToStoreLocation() {
        let marker = NMFMarker()
        if let store = item {
            marker.position = NMGLatLng(lat: Double(store.latitude!), lng: Double(store.longitude!))
            marker.mapView = self.naverMapView
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: Double(store.latitude!), lng: Double(store.longitude!)))
            cameraUpdate.animation = .easeIn
            naverMapView.moveCamera(cameraUpdate)
        }
    }
    
}
