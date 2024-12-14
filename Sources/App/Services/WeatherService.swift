import Vapor

protocol WeatherService: Sendable {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> OpenWeatherResponse
    func getForecast(lat: Double, lon: Double) async throws -> OpenWeatherForecastResponse
    func searchCities(query: String, limit: Int) async throws -> [GeocodingResponse]
}

struct OpenWeatherService: WeatherService {
    private let apiKey: String
    private let client: Client
    
    init(apiKey: String, client: Client) {
        self.apiKey = apiKey
        self.client = client
    }
    
    func getCurrentWeather(lat: Double, lon: Double) async throws -> OpenWeatherResponse {
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
        
        return try response.content.decode(OpenWeatherResponse.self)
    }
    
    func getForecast(lat: Double, lon: Double) async throws -> OpenWeatherForecastResponse {
        guard var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast") else {
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
            throw Abort(.internalServerError, reason: "Failed to fetch forecast data")
        }
        
        return try response.content.decode(OpenWeatherForecastResponse.self)
    }
    
    func searchCities(query: String, limit: Int) async throws -> [GeocodingResponse] {
        guard var components = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct") else {
            throw Abort(.internalServerError, reason: "Invalid URL")
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url?.absoluteString else {
            throw Abort(.internalServerError, reason: "Invalid URL")
        }
        
        let response = try await client.get(URI(string: url))
        
        guard response.status == HTTPStatus.ok else {
            if response.status == HTTPStatus.notFound {
                throw Abort(.notFound, reason: "Cities not found")
            }
            throw Abort(.internalServerError, reason: "Failed to fetch cities data")
        }
        
        return try response.content.decode([GeocodingResponse].self)
    }
}
