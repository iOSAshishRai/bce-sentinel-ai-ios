//
//  DashboardViewModel.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 22/09/26.
//
import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    
    @Published private(set) var incidents: [Incident] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isBackendOnline = false
    @Published private(set) var backendModel = "Checking..."
    
    private let incidentService = IncidentDataService()
    private let healthService = BackendHealthService()
    var criticalIncidentCount: Int {
        incidents.filter { $0.severity == .critical }.count
    }
    
    func loadIncidents() {
        isLoading = true
        incidents = incidentService.fetchActiveIncidents()
        isLoading = false
    }
    func checkBackendHealth() async {
        do {
            let health = try await healthService.checkHealth()

            isBackendOnline = health.isOperational
            backendModel = health.model
        } catch {
            isBackendOnline = false
            backendModel = "Demo Mode"

            #if DEBUG
            print("Backend health check failed:", error)
            #endif
        }
    }
}
