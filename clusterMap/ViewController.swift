//
//  ViewController.swift
//  clusterMap
//
//  Created by Levi Davis on 12/18/20.
//

import UIKit
import Mapbox

class ViewController: UIViewController {
    
    var venues = [Venue]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.removeAnnocations()
                self?.mapView.addAnnotations(self?.venues.map{$0.location} ?? [])
                self?.venues.forEach { location in
                    let annotation = MGLPointAnnotation()
                    annotation.title = location.name
                    annotation.coordinate = location.location.coordinate
                    self?.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    let lat: Double = 40.77014
    let long: Double = -73.97480
    
    lazy var mapView: MGLMapView = {
        guard let url = URL(string: "mapbox://styles/mapbox/streets-v11") else {print("bad url"); return MGLMapView()}
        let map = MGLMapView(frame: view.bounds, styleURL: url)
        let initialLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.setCenter(initialLocation, zoomLevel: 9, animated: false)
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        getVenues()
    }
    
    private func addMap() {
        view.addSubview(mapView)
    }
    
    private func getVenues() {
        MapAPIManager.shared.getLocations(lat: lat, long: long, venue: "pizza") { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let venues):
                self.venues = venues
            }
        }
    }

    private func removeAnnocations() {
        guard let annotations = mapView.annotations else {return}
        self.mapView.removeAnnotations(annotations)
        
    }
}
