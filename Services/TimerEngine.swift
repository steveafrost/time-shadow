import Foundation
import Combine
import UIKit

// MARK: - TimerEngine

/// ObservableObject that drives the countdown timer.
/// Publishes `progress` from 0.0 to 1.0 for the shadow renderer.
/// Handles pause / resume / cancel.
@MainActor
class TimerEngine: ObservableObject {
    // MARK: - Published state
    @Published var progress: Double = 0.0        // 0.0 → 1.0
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var isComplete = false
    @Published var elapsed: TimeInterval = 0.0   // seconds elapsed (including resumed time)
    @Published var remaining: TimeInterval = 0.0

    // MARK: - Configuration
    private(set) var totalDuration: TimeInterval = 0.0
    private(set) var startDate: Date?

    // MARK: - Private
    private var timer: DispatchSourceTimer?
    private var pauseElapsed: TimeInterval = 0.0   // elapsed before last pause
    private var pauseStart: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // MARK: - Callbacks
    var onComplete: (() -> Void)?
    var onTick: ((Double, TimeInterval, TimeInterval) -> Void)? // progress, elapsed, remaining

    deinit {
        timer?.cancel()
        endBackgroundTask()
    }

    // MARK: - Public API

    func start(duration: TimeInterval) {
        cancel()
        totalDuration = max(duration, 1.0)
        progress = 0.0
        elapsed = 0.0
        remaining = totalDuration
        isRunning = true
        isPaused = false
        isComplete = false
        startDate = Date()
        pauseElapsed = 0.0
        pauseStart = nil
        beginBackgroundTask()
        startTimer()
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        pauseStart = Date()
        timer?.suspend()
    }

    func resume() {
        guard isRunning, isPaused, let ps = pauseStart else { return }
        isPaused = false
        let pausedDuration = Date().timeIntervalSince(ps)
        pauseElapsed += pausedDuration
        pauseStart = nil
        timer?.resume()
    }

    func cancel() {
        timer?.cancel()
        timer = nil
        isRunning = false
        isPaused = false
        isComplete = false
        progress = 0.0
        elapsed = 0.0
        remaining = 0.0
        startDate = nil
        pauseElapsed = 0.0
        pauseStart = nil
        endBackgroundTask()
    }

    /// Elapsed time excluding paused periods.
    var activeElapsed: TimeInterval {
        // Always subtract total paused duration to get true active time
        let totalPaused = pauseElapsed + (isPaused && pauseStart != nil ? Date().timeIntervalSince(pauseStart!) : 0)
        return elapsed - totalPaused
    }

    // MARK: - Private Timer

    private func startTimer() {
        let queue = DispatchQueue(label: "com.timeshadow.timer", qos: .userInteractive)
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: 0.05) // 50 ms ≈ 60 fps
        t.setEventHandler { [weak self] in
            guard let self else { return }
            let now = Date()
            let wallElapsed: TimeInterval
            if let sd = self.startDate {
                wallElapsed = now.timeIntervalSince(sd)
            } else {
                wallElapsed = 0
            }
            let active = wallElapsed - self.pauseElapsed
            let p = min(active / self.totalDuration, 1.0)
            let rem = max(self.totalDuration - active, 0.0)

            Task { @MainActor in
                self.elapsed = wallElapsed
                self.remaining = rem
                self.progress = p
                self.onTick?(p, active, rem)

                if p >= 1.0 {
                    self.isComplete = true
                    self.isRunning = false
                    self.timer?.cancel()
                    self.timer = nil
                    self.endBackgroundTask()
                    self.onComplete?()
                }
            }
        }
        timer = t
        t.resume()
    }

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
