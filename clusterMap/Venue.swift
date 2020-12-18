//
//  Venue.swift
//  clusterMap
//
//  Created by Levi Davis on 12/18/20.
//

import Foundation
import Mapbox
//import MapKit

struct VenueWrapper: Codable {
    let response: Response
    
    static func getVenues(from jsonData: Data) throws -> [Venue]? {
       
            let response = try JSONDecoder().decode(VenueWrapper.self, from: jsonData)
        return response.response.venues

    }
}

struct Response: Codable {
    
    let venues: [Venue]
    
}

struct Venue: Codable {
    let id: String
    let name: String
    let location: LocationWrapper
    
}

class LocationWrapper: NSObject, Codable, MGLAnnotation {
    
    let lat: Double
    let lng: Double
    let crossStreet: String?
    let distance: Int?
    let formattedAddress: [String]
    
    @objc var coordinate: CLLocationCoordinate2D {
        let lattitude = lat
        let longitude = lng
        
        return CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
    }
    
    var hasValidCoordinates: Bool {
        return coordinate.latitude != 0 && coordinate.longitude != 0
    }

}

