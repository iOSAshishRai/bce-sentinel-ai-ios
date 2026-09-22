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
    
    private let incidentService = IncidentDataService()
    
    var criticalIncidentCount: Int {
        incidents.filter { $0.severity == .critical }.count
    }
    
    func loadIncidents() {
        isLoading = true
        incidents = incidentService.fetchActiveIncidents()
        isLoading = false
    }
}
