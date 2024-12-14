import Vapor

struct WeatherController: RouteCollection, Sendable {
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let weather = routes.grouped("api", "v1", "weather")
        weather.get("current-weather") { [self] req async throws -> APIResponse<OpenWeatherResponse> in
            try await self.getCurrentWeather(req)
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
                path: "/api/v1/weather/current-weather",
                message: "Weather data retrieved successfully"
            )
        } catch let error as AbortError {
            throw error
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch weather data")
        }
    }
}
