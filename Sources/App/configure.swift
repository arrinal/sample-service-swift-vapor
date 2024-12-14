import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Create weather service
    let weatherService = OpenWeatherService(
        apiKey: "d8f0fbba1d25bb2c195c9680a4dbc57d",
        client: app.client
    )

    // register routes
    try routes(app)
    
    // register weather routes
    try app.register(collection: WeatherController(weatherService: weatherService))
    
    // Custom error middleware
    app.middleware.use(ErrorMiddleware { req, error in
        let status: HTTPStatus
        let message: String
        let details: String?
        
        if let abort = error as? AbortError {
            status = abort.status
            message = abort.reason
            details = nil
        } else {
            status = .internalServerError
            message = "Something went wrong"
            #if DEBUG
            details = error.localizedDescription
            #else
            details = nil
            #endif
        }
        
        let response = APIError(
            code: Int(status.code),
            message: message,
            details: details,
            path: req.url.path
        )
        
        return Response(status: status, body: .init(data: try! JSONEncoder().encode(response)))
    })
}
