//
//  IncidentAnalysisViewModel.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class IncidentAnalysisViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case analyzing
        case loaded
        case failed(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var analysis: IncidentAnalysis?

    private let service: IncidentAnalysisServiceProtocol

    init(service: IncidentAnalysisServiceProtocol) {
        self.service = service
    }

    init() {
        self.service = IncidentAnalysisService()
    }

    func analyze(_ incident: Incident) async {
        guard state != .analyzing else {
            return
        }

        state = .analyzing

        do {
            analysis = try await service.analyze(incident)
            state = .loaded
        } catch {
            state = .failed(
                "Unable to analyze this incident. Please try again."
            )
        }
    }
}
