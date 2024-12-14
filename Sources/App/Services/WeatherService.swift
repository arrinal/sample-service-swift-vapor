import Vapor

protocol WeatherService: Sendable {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> Weather
}

struct OpenWeatherService: WeatherService {
    private let apiKey: String
    private let client: Client
    
    init(apiKey: String, client: Client) {
        self.apiKey = apiKey
        self.client = client
    }
    
    func getCurrentWeather(lat: Double, lon: Double) async throws -> Weather {
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather") else {
            throw Abort(.internalServerError, reason: "Invalid URL")
        }
        
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        guard let url = components.url?.absoluteString else {
            throw Abort(.internalServerError, reason: "Invalid URL")
        }
        
        let response = try await client.get(URI(string: url))
        
        guard response.status == HTTPStatus.ok else {
            if response.status == HTTPStatus.notFound {
                throw Abort(.notFound, reason: "Location not found")
            }
            throw Abort(.internalServerError, reason: "Failed to fetch weather data")
        }
        
        let weatherResponse = try response.content.decode(OpenWeatherResponse.self)
        return weatherResponse.toWeather()
    }
}
