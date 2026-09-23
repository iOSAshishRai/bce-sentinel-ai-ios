//
//  PostmortemService.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation

protocol PostmortemServiceProtocol {
    func generate(
        incident: Incident,
        analysis: IncidentAnalysis,
        result: RemediationResult
    ) async throws -> IncidentPostmortem
}

enum PostmortemServiceError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The postmortem service returned an invalid response."

        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message)"

        case .decodingFailed(let error):
            return "Unable to decode the postmortem: \(error.localizedDescription)"
        }
    }
}

private struct PostmortemRequest: Encodable {
    let incident: IncidentRequestPayload
    let analysis: PostmortemAnalysisPayload
    let result: RemediationResultPayload
}

private struct IncidentRequestPayload: Encodable {
    let id: String
    let title: String
    let service: String
    let severity: String
    let message: String
}

private struct PostmortemAnalysisPayload: Encodable {
    let rootCause: String
    let confidence: Int
    let explanation: String
}

private struct RemediationResultPayload: Encodable {
    let action: String
    let recoveryTimeSeconds: Int
    let affectedCustomers: Int
}

private struct PostmortemBackendError: Decodable {
    let detail: String
}

final class PostmortemService: PostmortemServiceProtocol {

    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = APIConfiguration.cloudRunBaseURL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func generate(
        incident: Incident,
        analysis: IncidentAnalysis,
        result: RemediationResult
    ) async throws -> IncidentPostmortem {
        let url = baseURL.appendingPathComponent("postmortem")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = APIConfiguration.requestTimeout

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let payload = PostmortemRequest(
            incident: IncidentRequestPayload(
                id: incident.id,
                title: incident.title,
                service: incident.service,
                severity: incident.severity.rawValue,
                message: incident.message
            ),
            analysis: PostmortemAnalysisPayload(
                rootCause: analysis.rootCause,
                confidence: analysis.confidence,
                explanation: analysis.explanation
            ),
            result: RemediationResultPayload(
                action: result.action,
                recoveryTimeSeconds: result.recoveryTimeSeconds,
                affectedCustomers: result.affectedCustomers
            )
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PostmortemServiceError.invalidResponse
        }

        #if DEBUG
        print("Postmortem status:", httpResponse.statusCode)
        print(
            "Postmortem response:",
            String(data: data, encoding: .utf8) ?? "Unreadable"
        )
        #endif

        guard (200...299).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(
                PostmortemBackendError.self,
                from: data
            )

            throw PostmortemServiceError.serverError(
                statusCode: httpResponse.statusCode,
                message: backendError?.detail ?? "Unknown error"
            )
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(
                IncidentPostmortem.self,
                from: data
            )
        } catch {
            throw PostmortemServiceError.decodingFailed(error)
        }
    }
}
