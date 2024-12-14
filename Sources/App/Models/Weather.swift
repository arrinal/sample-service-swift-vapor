import Vapor

struct Weather: Content, Sendable {
    let cityName: String
    let temperature: Double
    let description: String
    let humidity: Int
    let windSpeed: Double
}
