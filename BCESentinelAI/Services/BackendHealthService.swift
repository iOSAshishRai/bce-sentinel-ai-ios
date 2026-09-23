//
//  BackendHealthService.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 23/09/26.
//

import Foundation

struct BackendHealth: Decodable {
    let status: String
    let projectConfigured: Bool
    let project: String?
    let location: String
    let model: String

    var isOperational: Bool {
        status == "healthy" && projectConfigured
    }
}

enum BackendHealthError: LocalizedError {
    case invalidResponse
    case unhealthy

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The backend returned an invalid response."

        case .unhealthy:
            return "The AI backend is not fully configured."
        }
    }
}

final class BackendHealthService {
    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = APIConfiguration.cloudRunBaseURL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func checkHealth() async throws -> BackendHealth {
        let url = baseURL.appendingPathComponent("health")

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await session.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw BackendHealthError.invalidResponse
        }

        let health = try JSONDecoder().decode(
            BackendHealth.self,
            from: data
        )

        guard health.isOperational else {
            throw BackendHealthError.unhealthy
        }

        return health
    }
}
