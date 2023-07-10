//
//  NetworkMontior.swift
//  ChaPoker
//
//  Created by Elad Sabag on 08/07/2023.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor() // Singleton instance
    
    private let monitor = NWPathMonitor()
    private var pathUpdateHandler: ((NWPath) -> Void)?
    
    private init() {
        // Start monitoring
        monitor.start(queue: DispatchQueue.global())
    }
    
    func startMonitoring(completion: @escaping (NWPath) -> Void) {
        pathUpdateHandler = completion
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handleNetworkPathUpdate(path: path)
        }
        
        // Trigger initial update
        monitor.pathUpdateHandler?(monitor.currentPath)
    }
    
    private func handleNetworkPathUpdate(path: NWPath) {
        // Call the completion handler with the updated path
        pathUpdateHandler?(path)
    }
}

