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

@objc(ClusteringExample_Swift)

class ViewController: UIViewController {
    
    var venues = [Venue]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.removeAnnocations()
                self?.addAnnotations()
                self?.createFeatures()
//                self?.addPorts()
            }
        }
    }
    
    var features = [MGLPointFeature]()
    
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
    
    let mapIcon: UIImage? = UIImage(named: "port")
    
    lazy var popUp: UIView = {
        let popUp = UIView()
        return popUp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
//        getVenues()
        addDoubleTapRecognizer()
        addSingleTapRecognizer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        getVenues()
//        createFeatures()
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
    
    private func createFeatures() {
        features.removeAll()
        DispatchQueue.main.async {
            for venue in self.venues {
                let point = MGLPointFeature()
                point.coordinate = venue.location.coordinate
                point.title = venue.name
                point.attributes["title"] = venue.name
                self.features.append(point)
            }
        }
    }
    
    private func addSingleTapRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        guard let recongnizers = mapView.gestureRecognizers else {return}
        
        for recognizer in recongnizers where recognizer is UITapGestureRecognizer {
            gesture.require(toFail: recognizer)
        }
        
        mapView.addGestureRecognizer(gesture)
    }
    
    private func firstCluster(with gestureRecognizer: UIGestureRecognizer) -> MGLPointFeatureCluster? {
        let icon = mapIcon ?? UIImage()
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        let width = icon.size.width
        let rect = CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width)
        
        // This example shows how to check if a feature is a cluster by
        // checking for that the feature is a `MGLPointFeatureCluster`. Alternatively, you could
        // also check for conformance with `MGLCluster` instead.
        let features = mapView.visibleFeatures(in: rect, styleLayerIdentifiers: ["clusteredPorts", "ports"])
        let clusters = features.compactMap { $0 as? MGLPointFeatureCluster }
        
        // Pick the first cluster, ideally selecting the one nearest nearest one to
        // the touch point.
        return clusters.first
    }
    
//    func addPorts() {
//        print("addPorts")
//        let style = MGLStyle()
//        print(features)
////        guard let path = Bundle.main.path(forResource: "ports", ofType: "geojson") else {return}
//        guard let icon = mapIcon else {return}
//
////        let url = URL(fileURLWithPath: path)
////        print(features)
//        let source = MGLShapeSource(identifier: "clusteredPorts", features: features, options: [.clustered: true, .clusterRadius: mapIcon?.size.width])
//
//        style.addSource(source)
//        style.setImage(icon.withRenderingMode(.alwaysTemplate), forName: "icon")
//
//        print("hi")
//        print(source)
//
//        let ports = MGLSymbolStyleLayer(identifier: "ports", source: source)
//        ports.iconImageName = NSExpression(forConstantValue: "icon")
//        ports.iconColor = NSExpression(forConstantValue: UIColor.darkGray.withAlphaComponent(0.9))
//        ports.predicate = NSPredicate(format: "cluster != YES")
//        ports.iconAllowsOverlap = NSExpression(forConstantValue: true)
//        style.addLayer(ports)
//
//        //Color based on cluster counts
//
//        let stops = [
//            20: UIColor.lightGray,
//            50: UIColor.orange,
//            100: UIColor.red,
//            200: UIColor.purple
//        ]
//
//        let circlesLayer = MGLCircleStyleLayer(identifier: "clusteredPorts", source: source)
//        circlesLayer.circleRadius = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
//        circlesLayer.circleOpacity = NSExpression(forConstantValue: 0.75)
//        circlesLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white.withAlphaComponent(0.75))
//        circlesLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)
//        circlesLayer.circleColor = NSExpression(format: "mgl_step:from:stops:(point_count, %@, %@)", UIColor.lightGray, stops)
//        circlesLayer.predicate = NSPredicate(format: "cluster == YES")
//        style.addLayer(circlesLayer)
//
//        let numbersLayer = MGLSymbolStyleLayer(identifier: "clusteredPortsNumbers", source: source)
//        numbersLayer.textColor = NSExpression(forConstantValue: UIColor.white)
//        numbersLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
//        numbersLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
//        numbersLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
//
//        numbersLayer.predicate = NSPredicate(format: "cluster == YES")
//        style.addLayer(numbersLayer)
//    }
}

extension ViewController: MGLMapViewDelegate {
        
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    
        print(features)
        guard let path = Bundle.main.path(forResource: "ports", ofType: "geojson") else {return}
        guard let icon = mapIcon else {return}
        
        let url = URL(fileURLWithPath: path)
//        print(features)
        let source = MGLShapeSource(identifier: "clusteredPorts", url: url, options: [.clustered: true, .clusterRadius: mapIcon?.size.width])
        style.addSource(source)
        style.setImage(icon.withRenderingMode(.alwaysTemplate), forName: "icon")
        
        let ports = MGLSymbolStyleLayer(identifier: "ports", source: source)
        ports.iconImageName = NSExpression(forConstantValue: "icon")
        ports.iconColor = NSExpression(forConstantValue: UIColor.darkGray.withAlphaComponent(0.9))
        ports.predicate = NSPredicate(format: "cluster != YES")
        ports.iconAllowsOverlap = NSExpression(forConstantValue: true)
        style.addLayer(ports)
        
        //Color based on cluster counts
        
        let stops = [
            20: UIColor.lightGray,
            50: UIColor.orange,
            100: UIColor.red,
            200: UIColor.purple
        ]
        
        let circlesLayer = MGLCircleStyleLayer(identifier: "clusteredPorts", source: source)
        circlesLayer.circleRadius = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
        circlesLayer.circleOpacity = NSExpression(forConstantValue: 0.75)
        circlesLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white.withAlphaComponent(0.75))
        circlesLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)
        circlesLayer.circleColor = NSExpression(format: "mgl_step:from:stops:(point_count, %@, %@)", UIColor.lightGray, stops)
        circlesLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(circlesLayer)
        
        let numbersLayer = MGLSymbolStyleLayer(identifier: "clusteredPortsNumbers", source: source)
        numbersLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        numbersLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: Double(icon.size.width) / 2))
        numbersLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        numbersLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
        
        numbersLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(numbersLayer)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
}
