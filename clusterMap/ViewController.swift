//
//  ViewController.swift
//  clusterMap
//
//  Created by Levi Davis on 12/18/20.
//

import UIKit
import Mapbox

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
    }
    
    private func addMap() {
        guard let url = URL(string: "mapbox://styles/mapbox/streets-v11") else {print("bad url"); return}
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let initialLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06)
        mapView.setCenter(initialLocation, zoomLevel: 9, animated: false)
        view.addSubview(mapView)
    }

}
/**
 let url = URL(string: "mapbox://styles/mapbox/streets-v11")
 let mapView = MGLMapView(frame: view.bounds, styleURL: url)
 mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
 mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
 view.addSubview(mapView)
 */

