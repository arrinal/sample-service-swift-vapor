import Vapor
import Foundation

struct APIResponse<T: Codable & Sendable>: Content {
    let status: String
    let code: Int
    let message: String
    let data: T?
    let timestamp: Date
    let path: String
    
    init(status: String = "success",
         code: Int = 200,
         message: String,
         data: T?,
         path: String) {
        self.status = status
        self.code = code
        self.message = message
        self.data = data
        self.timestamp = Date()
        self.path = path
    }
    
    static func success(_ data: T?, path: String, message: String = "Success") -> APIResponse {
        APIResponse(message: message, data: data, path: path)
    }
}

struct APIError: Error, Content {
    let status: String
    let code: Int
    let message: String
    let details: String?
    let timestamp: Date
    let path: String
    
    init(code: Int,
         message: String,
         details: String? = nil,
         path: String) {
        self.status = "error"
        self.code = code
        self.message = message
        self.details = details
        self.timestamp = Date()
        self.path = path
    }
}
