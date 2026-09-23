//
//  APIConfiguration.swift
//  BCESentinelAI
//
//  Created by aasheesh.kumar on 23/09/26.
//

import Foundation

enum APIConfiguration {
    static let cloudRunBaseURL = URL(
        string: "https://bce-sentinel-api-1074500010864.asia-south1.run.app"
    )!

    static let requestTimeout: TimeInterval = 60
}
