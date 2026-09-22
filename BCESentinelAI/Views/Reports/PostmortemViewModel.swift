//
//  PostmortemViewModel.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PostmortemViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case generating
        case loaded
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var postmortem: IncidentPostmortem?

    private let service: PostmortemServiceProtocol

    init(service: PostmortemServiceProtocol) {
        self.service = service
    }

    init() {
        self.service = PostmortemService()
    }

    func generate(
        incident: Incident,
        analysis: IncidentAnalysis,
        result: RemediationResult
    ) async {
        guard state != .generating else {
            return
        }

        state = .generating

        do {
            postmortem = try await service.generate(
                incident: incident,
                analysis: analysis,
                result: result
            )

            state = .loaded
        } catch {
            state = .failed(
                "Unable to generate the incident postmortem."
            )
        }
    }
}
