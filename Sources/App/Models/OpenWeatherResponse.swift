import Vapor

struct OpenWeatherResponse: Codable {
    let name: String
    let main: MainWeather
    let weather: [WeatherDescription]
    let wind: Wind
    
    struct MainWeather: Codable {
        let temp: Double
        let humidity: Int
    }
    
    struct WeatherDescription: Codable {
        let description: String
        let icon: String
    }
    
    struct Wind: Codable {
        let speed: Double
    }
    
    func toWeather() -> Weather {
        Weather(
            cityName: name,
            temperature: main.temp,
            description: weather.first?.description ?? "",
            humidity: main.humidity,
            windSpeed: wind.speed
        )
    }
}
