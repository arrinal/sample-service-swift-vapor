import Vapor

struct WeatherController: RouteCollection, Sendable {
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let weather = routes.grouped("api", "v1", "openweathermap.org")
        weather.get("current-weather") { [self] req async throws -> APIResponse<OpenWeatherResponse> in
            try await self.getCurrentWeather(req)
        }
        weather.get("current-forecast") { [self] req async throws -> APIResponse<OpenWeatherForecastResponse> in
            try await self.getForecast(req)
        }
        weather.get("search-cities") { [self] req async throws -> APIResponse<[GeocodingResponse]> in
            try await self.searchCities(req)
        }
    }
    
    func getCurrentWeather(_ req: Request) async throws -> APIResponse<OpenWeatherResponse> {
        guard let lat = req.query[Double.self, at: "lat"],
              let lon = req.query[Double.self, at: "lon"] else {
            throw Abort(.badRequest, reason: "Latitude and longitude are required")
        }
        
        do {
            let weather = try await weatherService.getCurrentWeather(lat: lat, lon: lon)
            return APIResponse.success(
                weather,
                path: "/api/v1/openweathermap.org/current-weather",
                message: "Weather data retrieved successfully"
            )
        } catch let error as AbortError {
            throw error
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch weather data")
        }
    }
    
    func getForecast(_ req: Request) async throws -> APIResponse<OpenWeatherForecastResponse> {
        guard let lat = req.query[Double.self, at: "lat"],
              let lon = req.query[Double.self, at: "lon"] else {
            throw Abort(.badRequest, reason: "Latitude and longitude are required")
        }
        
        do {
            let forecast = try await weatherService.getForecast(lat: lat, lon: lon)
            return APIResponse.success(
                forecast,
                path: "/api/v1/openweathermap.org/current-forecast",
                message: "Forecast data retrieved successfully"
            )
        } catch let error as AbortError {
            throw error
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch forecast data")
        }
    }
    
    func searchCities(_ req: Request) async throws -> APIResponse<[GeocodingResponse]> {
        guard let query = req.query[String.self, at: "q"] else {
            throw Abort(.badRequest, reason: "Query parameter 'q' is required")
        }
        
        do {
            let limit = req.query[Int.self, at: "limit"] ?? 5
            let cities = try await weatherService.searchCities(query: query, limit: limit)
            return APIResponse.success(
                cities,
                path: "/api/v1/openweathermap.org/search-cities",
                message: "Cities data retrieved successfully"
            )
        } catch let error as AbortError {
            throw error
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch cities data")
        }
    }
}
