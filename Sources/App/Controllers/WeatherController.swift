import Vapor

struct WeatherController: RouteCollection, Sendable {
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let weather = routes.grouped("api", "v1", "weather")
        weather.get("current", ":city") { [self] req async throws -> APIResponse<Weather> in
            try await self.getCurrentWeather(req)
        }
    }
    
    func getCurrentWeather(_ req: Request) async throws -> APIResponse<Weather> {
        guard let city = req.parameters.get("city") else {
            throw Abort(.badRequest, reason: "City parameter is required")
        }
        
        do {
            let weather = try await weatherService.getCurrentWeather(city: city)
            return APIResponse.success(
                weather,
                path: "/api/v1/weather/current/\(city)",
                message: "Weather data retrieved successfully"
            )
        } catch let error as AbortError {
            throw error
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch weather data")
        }
    }
}
