//
//  ApiReachabilityManager.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation
import Network

public final class ApiReachabilityManager: @unchecked Sendable {
    
    // MARK: - Singleton
    public static let shared = ApiReachabilityManager()
    
    // MARK: - Properties
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.app.networkreachability")
    
    public private(set) var currentNetworkStatus: Bool? = nil
    
    public static let networkStatusChanged = Notification.Name("NetworkStatusChanged")
    
    // MARK: - Initialization
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isConnected = path.status == .satisfied
            
            if self.currentNetworkStatus != isConnected {
                self.currentNetworkStatus = isConnected
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ApiReachabilityManager.networkStatusChanged,
                        object: nil,
                        userInfo: ["isConnected": isConnected]
                    )
                }
                
                self.logNetworkStatus(path: path)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    public var isConnectedViaWiFi: Bool {
        guard let path = monitor.currentPath as NWPath? else { return false }
        return path.usesInterfaceType(.wifi)
    }
    
    public var isConnectedViaCellular: Bool {
        guard let path = monitor.currentPath as NWPath? else { return false }
        return path.usesInterfaceType(.cellular)
    }
    
    public var isConnectedViaEthernet: Bool {
        guard let path = monitor.currentPath as NWPath? else { return false }
        return path.usesInterfaceType(.wiredEthernet)
    }
    
    public var connectionType: String {
        if isConnectedViaWiFi {
            return "WiFi"
        } else if isConnectedViaCellular {
            return "Cellular"
        } else if isConnectedViaEthernet {
            return "Ethernet"
        } else {
            return "Unknown"
        }
    }
    
    // MARK: - Private Methods
    
    private func logNetworkStatus(path: NWPath) {
        var status = "Network Status: "
        
        switch path.status {
        case .satisfied:
            status += "Connected"
            if path.usesInterfaceType(.wifi) {
                status += " via WiFi"
            } else if path.usesInterfaceType(.cellular) {
                status += " via Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                status += " via Ethernet"
            }
        case .unsatisfied:
            status += "Not Connected"
        case .requiresConnection:
            status += "Requires Connection"
        @unknown default:
            status += "Unknown"
        }
        
        if path.isExpensive {
            status += " (Expensive)"
        }
        
        if path.isConstrained {
            status += " (Constrained)"
        }
        
        print(status)
    }
}

// MARK: - Extension for easier usage
public extension ApiReachabilityManager {
    
    var isNetworkAvailable: Bool {
        return currentNetworkStatus ?? false
    }
    
    var isNetworkUnavailable: Bool {
        return !(currentNetworkStatus ?? true)
    }
}
