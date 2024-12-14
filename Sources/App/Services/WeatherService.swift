import Vapor

protocol WeatherService: Sendable {
    func getCurrentWeather(city: String) async throws -> Weather
}

struct OpenWeatherService: WeatherService {
    private let apiKey: String
    private let client: Client
    
    init(apiKey: String, client: Client) {
        self.apiKey = apiKey
        self.client = client
    }
    
    func getCurrentWeather(city: String) async throws -> Weather {
        let url = "https://api.openweathermap.org/data/2.5/weather"
        
        let response = try await client.get(URI(string: url)) { req in
            try req.query.encode([
                "q": city,
                "appid": apiKey,
                "units": "metric" // For Celsius
            ])
        }
        
        guard response.status == .ok else {
            if response.status == .notFound {
                throw Abort(.notFound, reason: "City not found")
            }
            throw Abort(.internalServerError, reason: "Failed to fetch weather data")
        }
        
        let weatherResponse = try response.content.decode(OpenWeatherResponse.self)
        return weatherResponse.toWeather()
    }
}
