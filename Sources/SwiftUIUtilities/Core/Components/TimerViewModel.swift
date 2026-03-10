import SwiftUI
import Combine

public class TimerViewModel: ObservableObject {
    
    public enum TimerMode {
        case countDown(minutes: Int)
        case countUp
    }
    
    @Published public var timeRemaining: Int
    @Published public var elapsedTime: Int = 0
    
    private let mode: TimerMode
    private let initialTime: Int
    private let onTimeCompletion: (() -> Void)?
    private var timer: AnyCancellable?
    
    // MARK: - New Mode-Based Initializers
    
    public init(mode: TimerMode, onTimeCompletion: (() -> Void)? = nil) {
        self.mode = mode
        self.onTimeCompletion = onTimeCompletion
        
        switch mode {
        case .countDown(let minutes):
            let timeInSeconds = minutes * 60
            self.timeRemaining = timeInSeconds
            self.initialTime = timeInSeconds
        case .countUp:
            self.timeRemaining = 0
            self.initialTime = 0
        }
    }
    
    // MARK: - Legacy Initializers (Backward Compatibility)
    
    public convenience init(timeInSeconds: Int, onTimeCompletion: @escaping () -> Void) {
        self.init(mode: .countDown(minutes: timeInSeconds / 60), onTimeCompletion: onTimeCompletion)
    }
    
    public convenience init(timeInMinutes: Int, onTimeCompletion: @escaping () -> Void) {
        self.init(mode: .countDown(minutes: timeInMinutes), onTimeCompletion: onTimeCompletion)
    }
    
    // MARK: - Timer Display
    
    public var timerText: String {
        let time: Int
        switch mode {
        case .countDown:
            time = timeRemaining
        case .countUp:
            time = elapsedTime
        }
        
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Timer Controls
    
    public func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                switch self.mode {
                case .countDown:
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    } else {
                        self.timer?.cancel()
                        self.onTimeCompletion?()
                    }
                case .countUp:
                    self.elapsedTime += 1
                }
            }
    }
    
    public func stopTimer() {
        timer?.cancel()
    }
    
    public func resetTimer() {
        stopTimer()
        switch mode {
        case .countDown:
            timeRemaining = initialTime
        case .countUp:
            elapsedTime = 0
        }
    }
}
