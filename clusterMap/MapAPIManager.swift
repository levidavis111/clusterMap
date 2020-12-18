//
//  MapAPIManager.swift
//  clusterMap
//
//  Created by Levi Davis on 12/18/20.
//

import Foundation

enum AppError: Error {
    case badURL
    case errorReturned
    case badResponse
    case noData
    case decodeError
}

struct MapAPIManager {
    static let shared = MapAPIManager()
    
    func getLocations(lat: Double, long: Double, venue: String, completion: @escaping (Result<[Venue], AppError>) -> () ) {
        let formattedVenue = venue.replacingOccurrences(of: " ", with: "")
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/search?ll=\(lat),\(long)&client_id=\(Secret.fourSquareID)&client_secret=\(Secret.fourSquareKey)&v=20191104&query=\(formattedVenue)&limit=3") else {completion(.failure(.badURL)); return}
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {completion(.failure(.errorReturned)); return}
            guard let response = response as? HTTPURLResponse,
                  Set(200...299).contains(response.statusCode) else {completion(.failure(.badResponse)); return}
            guard let data = data else {completion(.failure(.noData)); return}
            
            do {
                let result = try JSONDecoder().decode(VenueWrapper.self, from: data).response.venues
                print(result)
                completion(.success(result))
            } catch {
                print(error)
                completion(.failure(.decodeError)); return
            }
        }.resume()
    }
}
