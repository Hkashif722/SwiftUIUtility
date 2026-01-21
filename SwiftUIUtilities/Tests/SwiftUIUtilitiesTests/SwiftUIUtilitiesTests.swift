//
//  SwiftUIUtilitiesTests.swift
//  SwiftUIUtilities
//
//  Created by Package on 13/01/26.
//

import XCTest
@testable import SwiftUIUtilities

final class SwiftUIUtilitiesTests: XCTestCase {
    
    // MARK: - Toast Tests
    
    func testToastCreation() {
        let toast = Toast(
            style: .success,
            message: "Test message",
            duration: 3.0
        )
        
        XCTAssertEqual(toast.style, .success)
        XCTAssertEqual(toast.message, "Test message")
        XCTAssertEqual(toast.duration, 3.0)
    }
    
    func testToastStyleColors() {
        XCTAssertNotNil(ToastStyle.success.themeColor)
        XCTAssertNotNil(ToastStyle.error.themeColor)
        XCTAssertNotNil(ToastStyle.warning.themeColor)
        XCTAssertNotNil(ToastStyle.info.themeColor)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateLoading() {
        let state: LoadingState = .loading(message: "Loading...")
        
        XCTAssertTrue(state.isLoading)
        XCTAssertEqual(state.message, "Loading...")
    }
    
    func testLoadingStateLoaded() {
        let state: LoadingState = .loaded
        
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.message, "")
    }
    
    func testLoadingStateNone() {
        let state: LoadingState = .none
        
        XCTAssertFalse(state.isLoading)
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyStateData() {
        let noDataState = EmptyStateData.noData
        let content = noDataState.content
        
        XCTAssertNotNil(content.icon)
        XCTAssertNotNil(content.title)
        XCTAssertNotNil(content.label)
    }
    
    // MARK: - API Error Tests
    
    func testAPIErrorDescriptions() {
        let invalidResponse = APIError.invalidResponse
        XCTAssertNotNil(invalidResponse.errorDescription)
        
        let noData = APIError.noData
        XCTAssertNotNil(noData.errorDescription)
        
        let unauthorized = APIError.unauthorized
        XCTAssertNotNil(unauthorized.errorDescription)
    }
    
    func testAPIErrorStatusCodes() {
        let unauthorized = APIError.unauthorized
        XCTAssertEqual(unauthorized.statusCode, 401)
        
        let badRequest = APIError.badRequest([:], rawJSON: "")
        XCTAssertEqual(badRequest.statusCode, 400)
    }
    
    // MARK: - String Extension Tests
    
    func testStringTrim() {
        let testString = "  Hello World  "
        XCTAssertEqual(testString.trim(), "Hello World")
    }
    
    func testStringRemoveWhitespace() {
        let testString = "Hello World"
        XCTAssertEqual(testString.removeWhitespace(), "HelloWorld")
    }
    
    func testStringReplace() {
        let testString = "Hello World"
        XCTAssertEqual(testString.replace("World", replacement: "Swift"), "Hello Swift")
    }
    
    // MARK: - Task Utility Tests
    
    func testAnyCancellableTask() {
        let task = Task { }
        let cancellableTask = TaskUtility.AnyCancellableTask(task)
        
        XCTAssertNotNil(cancellableTask)
        cancellableTask.cancel()
        XCTAssertTrue(task.isCancelled)
    }
    
    // MARK: - Logger Tests
    
    func testLoggerSharedInstance() {
        let logger1 = Logger.shared
        let logger2 = Logger.shared
        
        XCTAssertTrue(logger1 === logger2, "Logger should be a singleton")
    }
    
    func testLoggerLogLevels() {
        // Test that logging doesn't crash
        Logger.shared.log(.info, message: "Info message")
        Logger.shared.log(.warning, message: "Warning message")
        Logger.shared.log(.error, message: "Error message")
        Logger.shared.log(.debug, message: "Debug message")
    }
}
