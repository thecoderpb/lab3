//
//  ViewController.swift
//  Lab3
//
//  Created by Pratik Byathnal on 2024-11-03.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tempratureText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var conditionsText: UILabel!
    
    var weatherInfo: WeatherService.WeatherResponse?
    var typingTimer: Timer?
    
    let locationManager = CLLocationManager()
    let weatherService = WeatherService()
    
    @IBAction func locationClicked(_ sender: UIButton) {
        print("Location clicked")
        checkLocationPermission()
    }
    
    @IBAction func onSwitchClicked(_ sender: UISwitch) {
        setCurrentTemprature()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.switchButton.isEnabled = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        typingTimer?.invalidate()
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.userStoppedTyping(searchText: searchText)
        }
    }
    
    private func userStoppedTyping(searchText: String) {
        print("User stopped typing with text: \(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {return}
        print("Search button clicked with text " + searchText)
        searchBar.resignFirstResponder()
        weatherService.fetchWeatherByName(cityName: searchText){ weatherInfo in
            DispatchQueue.main.async {
                if let weatherInfo = weatherInfo {
                    self.weatherInfo = weatherInfo
                    self.switchButton.isEnabled = true
                    print("Weather: \(weatherInfo.current.condition.icon)")
                    self.setCurrentTemprature()
                    self.conditionsText.text = weatherInfo.current.condition.text
                    self.locationText.text = weatherInfo.location.name
                    self.updateWeatherSymbol(code: weatherInfo.current.condition.code)
                    
                } else {
                    print("Failed to fetch weather info.")
                }
                
            }
        }
    }
    
    func setCurrentTemprature() {
        if let weatherInfo = weatherInfo {
            if(switchButton.isOn){
                tempratureText.text = String(weatherInfo.current.tempF) + "°F"
            } else {
                tempratureText.text = String(weatherInfo.current.tempC) + "°C"
            }
            
        }
    }
    
    
    func updateWeatherSymbol(code: Int){
        let symbolName = getSymbolByCode(code: code)
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .systemYellow, .systemBlue])
        weatherImage.image = UIImage(systemName: symbolName, withConfiguration: config)
    }
    
    private func getSymbolByCode(code: Int) -> String {
        switch code {
        case 1000: return "sun.max"               // Sunny
        case 1003: return "cloud.sun"             // Partly cloudy
        case 1006: return "cloud"                 // Cloudy
        case 1009: return "smoke"                 // Overcast
        case 1030: return "cloud.fog"             // Mist
        case 1063: return "cloud.drizzle"         // Patchy rain possible
        case 1066: return "cloud.snow"            // Patchy snow possible
        case 1069: return "cloud.sleet"           // Patchy sleet possible
        case 1072: return "cloud.hail"            // Patchy freezing drizzle possible
        case 1087: return "cloud.bolt"            // Thundery outbreaks possible
        case 1114: return "wind.snow"             // Blowing snow
        case 1117: return "cloud.snow.fill"       // Blizzard
        case 1135: return "cloud.fog.fill"        // Fog
        case 1147: return "cloud.fog"             // Freezing fog
        case 1150: return "cloud.drizzle"         // Patchy light drizzle
        case 1153: return "cloud.drizzle.fill"    // Light drizzle
        case 1168: return "cloud.hail.fill"       // Freezing drizzle
        case 1171: return "cloud.hail.circle"     // Heavy freezing drizzle
        case 1180: return "cloud.rain"            // Patchy light rain
        case 1183: return "cloud.rain.fill"       // Light rain
        case 1186: return "cloud.heavyrain"       // Moderate rain at times
        case 1189: return "cloud.heavyrain.fill"  // Moderate rain
        case 1192: return "cloud.rain.circle"     // Heavy rain at times
        case 1195: return "cloud.rain.circle.fill"// Heavy rain
        case 1198: return "cloud.sleet"           // Light freezing rain
        case 1201: return "cloud.sleet.fill"      // Moderate or heavy freezing rain
        case 1204: return "cloud.snow"            // Light sleet
        case 1207: return "cloud.snow.fill"       // Moderate or heavy sleet
        case 1210: return "cloud.snow"            // Patchy light snow
        case 1213: return "cloud.snow.fill"       // Light snow
        case 1216: return "snow"                  // Patchy moderate snow
        case 1219: return "snow.circle"           // Moderate snow
        case 1222: return "snow.circle.fill"      // Patchy heavy snow
        case 1225: return "snowflake"             // Heavy snow
        case 1237: return "cloud.hail"            // Ice pellets
        case 1240: return "cloud.rain"            // Light rain shower
        case 1243: return "cloud.rain.fill"       // Moderate or heavy rain shower
        case 1246: return "cloud.heavyrain.fill"  // Torrential rain shower
        case 1249: return "cloud.sleet"           // Light sleet showers
        case 1252: return "cloud.sleet.fill"      // Moderate or heavy sleet showers
        case 1255: return "cloud.snow"            // Light snow showers
        case 1258: return "cloud.snow.fill"       // Moderate or heavy snow showers
        case 1261: return "cloud.hail"            // Light showers of ice pellets
        case 1264: return "cloud.hail.fill"       // Moderate or heavy showers of ice pellets
        case 1273: return "cloud.bolt.rain"       // Patchy light rain with thunder
        case 1276: return "cloud.bolt.rain.fill"  // Moderate or heavy rain with thunder
        case 1279: return "cloud.bolt.snow"       // Patchy light snow with thunder
        case 1282: return "cloud.bolt.snow.fill"  // Moderate or heavy snow with thunder
        default: return "cloud.sun.rain"          // Default icon
        }
        
    }
    
    
    func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Handle restricted/denied state (e.g., show alert)
            showAlert("Location access denied", "Please enable location services in settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            // Permissions are granted, request current location
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation() // Start getting the location once permission is granted
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("User's current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            // Handle the location here, e.g., update UI
            weatherService.fetchWeatherByCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
                weatherInfo in
                DispatchQueue.main.async {
                    if let weatherInfo = weatherInfo {
                        self.weatherInfo = weatherInfo
                        self.switchButton.isEnabled = true
                        print("Weather: \(weatherInfo.location.name)")
                        self.setCurrentTemprature()
                        self.locationText.text = weatherInfo.location.name
                        self.conditionsText.text = weatherInfo.current.condition.text
                        self.updateWeatherSymbol(code: weatherInfo.current.condition.code)
                    } else {
                        print("Failed to fetch weather info.")
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
    
    
    
}

