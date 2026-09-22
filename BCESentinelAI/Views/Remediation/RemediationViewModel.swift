//
//  RemediationViewModel.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//

import SwiftUI
import Combine

@MainActor
final class RemediationViewModel: ObservableObject {

    enum State: Equatable {
        case ready
        case executing
        case completed
        case failed(String)
    }

    @Published private(set) var state: State = .ready
    @Published private(set) var currentStep = 0
    @Published private(set) var result: RemediationResult?

    let steps = [
        "Validating remediation policy",
        "Running service diagnostics",
        "Restarting unhealthy instance",
        "Verifying service health",
        "Monitoring recovery"
    ]

    var progress: Double {
        guard !steps.isEmpty else {
            return 0
        }

        return Double(currentStep) / Double(steps.count)
    }

    func execute(
        incident: Incident,
        action: RemediationAction
    ) async {
        guard state != .executing else {
            return
        }

        state = .executing
        currentStep = 0

        for index in steps.indices {
            currentStep = index + 1

            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                state = .failed("The remediation workflow was interrupted.")
                return
            }
        }

        result = RemediationResult(
            incidentID: incident.id,
            action: action.title,
            recoveryTimeSeconds: 15,
            affectedCustomers: 0,
            completedAt: Date()
        )

        state = .completed
    }
}
