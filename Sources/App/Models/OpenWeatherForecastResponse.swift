import Vapor

struct OpenWeatherForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Codable {
        let dt: Int
        let main: MainWeather
        let weather: [WeatherDescription]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int?
        let pop: Double
        let rain: Rain?
        let sys: Sys
        let dtTxt: String
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather, clouds, wind, visibility, pop, rain, sys
            case dtTxt = "dt_txt"
        }
    }
    
    struct MainWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let seaLevel: Int
        let groundLevel: Int
        let humidity: Int
        let tempKf: Double
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case seaLevel = "sea_level"
            case groundLevel = "grnd_level"
            case humidity
            case tempKf = "temp_kf"
        }
    }
    
    struct WeatherDescription: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }
    
    struct Rain: Codable {
        let threeHour: Double
        
        enum CodingKeys: String, CodingKey {
            case threeHour = "3h"
        }
    }
    
    struct Sys: Codable {
        let pod: String
    }
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coordinate
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
    }
    
    struct Coordinate: Codable {
        let lat: Double
        let lon: Double
    }
}
