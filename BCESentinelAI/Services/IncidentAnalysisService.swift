import Foundation

protocol IncidentAnalysisServiceProtocol {
    func analyze(_ incident: Incident) async throws -> IncidentAnalysis
}

enum IncidentAnalysisServiceError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."

        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message)"

        case .decodingFailed(let error):
            return "Unable to decode the response: \(error.localizedDescription)"
        }
    }
}

private struct IncidentAnalysisRequest: Encodable {
    let id: String
    let title: String
    let service: String
    let severity: String
    let message: String
}

private struct BackendErrorResponse: Decodable {
    let detail: String
}

final class IncidentAnalysisService: IncidentAnalysisServiceProtocol {

    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(
            string: "https://bce-sentinel-api-1074500010864.asia-south1.run.app"
        )!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func analyze(
        _ incident: Incident
    ) async throws -> IncidentAnalysis {
        let url = baseURL.appendingPathComponent("analyze")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let requestBody = IncidentAnalysisRequest(
            id: incident.id,
            title: incident.title,
            service: incident.service,
            severity: incident.severity.rawValue,
            message: incident.message
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        #if DEBUG
        print("Calling analysis endpoint:", url.absoluteString)
        #endif

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            #if DEBUG
            print("Network error:", error)
            #endif

            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw IncidentAnalysisServiceError.invalidResponse
        }

        #if DEBUG
        print("Analysis HTTP status:", httpResponse.statusCode)
        print(
            "Analysis response:",
            String(data: data, encoding: .utf8) ?? "Unreadable response"
        )
        #endif

        guard (200...299).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(
                BackendErrorResponse.self,
                from: data
            )

            let message = backendError?.detail
                ?? String(data: data, encoding: .utf8)
                ?? "Unknown backend error"

            throw IncidentAnalysisServiceError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        do {
            return try JSONDecoder().decode(
                IncidentAnalysis.self,
                from: data
            )
        } catch {
            #if DEBUG
            print("Analysis decoding failed:", error)
            #endif

            throw IncidentAnalysisServiceError.decodingFailed(error)
        }
    }
}
