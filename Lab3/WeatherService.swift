//
//  WeatherService.swift
//  Lab3
//
//  Created by Pratik Byathnal on 2024-11-04.
//


import Foundation
import CoreLocation

class WeatherService {
    let apiKey = "6fae8f690f984fd8b8402048240511"

    
    func fetchWeatherByCoordinates(latitude: Double, longitude: Double, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let session = URLSession.shared
        
        // Make the network request
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // Call the separate method to handle response and parsing
            self?.handleWeatherResponse(data: data, error: error, completion: completion)
        }
        task.resume()
        
    }
    
    func fetchWeatherByName(cityName: String, completion: @escaping (WeatherResponse?) -> Void){
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(cityName)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let session = URLSession.shared
        
        // Make the network request
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // Call the separate method to handle response and parsing
            self?.handleWeatherResponse(data: data, error: error, completion: completion)
        }
        task.resume()
    }
    
    // Separate method to handle and parse the response
    private func handleWeatherResponse(data: Data?, error: Error?, completion: @escaping (WeatherResponse?) -> Void) {
        if let error = error {
            print("Error fetching weather data: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            completion(nil)
            return
        }
        
        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(weatherResponse)
        } catch {
            print("Error decoding weather data: \(error)")
            completion(nil)
        }
    }
    
    struct WeatherResponse: Codable {
        let location: Location
        let current: Current
    }
    
    struct Location: Codable {
        let name: String // City name
        let region: String // Region name
        let country: String // Country name
    }
    
    struct Current: Codable {
        let tempC: Double // Temperature in Celsius
        let tempF: Double // Temprature in Faranheit
        let condition: Condition // Weather condition
        
        // CodingKeys to map JSON keys to struct properties
        private enum CodingKeys: String, CodingKey {
            case tempC = "temp_c"
            case tempF = "temp_f"
            case condition
        }
    }
    
    struct Condition: Codable {
        let text: String // e.g., "Light rain"
        let icon: String // URL for weather icon
        let code: Int
    }
    
}
