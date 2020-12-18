//
//  ViewController.swift
//  clusterMap
//
//  Created by Levi Davis on 12/18/20.
//

import UIKit
import Mapbox

enum CastingError: Error {
    case castingError(String)
}

class ViewController: UIViewController {
    
    var venues = [Venue]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.removeAnnocations()
                self?.addAnnotations()
            }
        }
    }
    
    let lat: Double = 40.77014
    let long: Double = -73.97480
    
    lazy var mapView: MGLMapView = {
        guard let url = URL(string: "mapbox://styles/mapbox/streets-v11") else {print("bad url"); return MGLMapView()}
        let map = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL)
        let initialLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.setCenter(initialLocation, zoomLevel: 9, animated: false)
        map.tintColor = .darkGray
        map.delegate = self
        return map
    }()
    
    lazy var mapIcon: UIImage = {
        let icon = UIImage()
        return icon
    }()
    
    lazy var popUp: UIView = {
        let popUp = UIView()
        return popUp
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        getVenues()
        addDoubleTapRecognizer()
        addSingleTapRecognizer()
    }
    
    
    @objc private func handleDoubleTap(_ sender: UIGestureRecognizer) {}
    
    @objc private func handleSingleTap(_ sender: UIGestureRecognizer) {}
    
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
    
    private func addAnnotations() {
        for venue in venues {
            let annotation = MGLPointAnnotation()
            annotation.title = venue.name
            annotation.coordinate = venue.location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    private func addDoubleTapRecognizer() {
        //Double-tap to zoom in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        
        guard let recognizers = mapView.gestureRecognizers else {return}
        
        for recognizer in recognizers where (recognizer as? UITapGestureRecognizer)?.numberOfTapsRequired == 2 {
            recognizer.require(toFail: gesture)
        }
        
        mapView.addGestureRecognizer(gesture)
    }
    private func addSingleTapRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        guard let recongnizers = mapView.gestureRecognizers else {return}
        
        for recognizer in recongnizers where recognizer is UITapGestureRecognizer {
            gesture.require(toFail: recognizer)
        }
        
        mapView.addGestureRecognizer(gesture)
    }
}

extension ViewController: MGLMapViewDelegate {
    
}

extension ViewController: UIGestureRecognizerDelegate {
    
}
