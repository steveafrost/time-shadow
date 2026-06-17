import Foundation
import Combine
import UIKit

// MARK: - TimerEngine

/// ObservableObject that drives the countdown timer.
/// Publishes `progress` from 0.0 to 1.0 for the shadow renderer.
/// Handles pause / resume / cancel.
@MainActor
final class TimerEngine: ObservableObject {
    // MARK: - Shared singleton (for App Intents access)
    static let shared = TimerEngine()
    // MARK: - Published state
    @Published var progress: Double = 0.0        // 0.0 → 1.0
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var isComplete = false
    @Published var elapsed: TimeInterval = 0.0   // wall-clock seconds since start
    @Published var remaining: TimeInterval = 0.0

    // MARK: - Configuration
    private(set) var totalDuration: TimeInterval = 0.0
    private(set) var startDate: Date?

    // MARK: - Private
    private var timer: DispatchSourceTimer?
    private var pausedDuration: TimeInterval = 0.0
    private var pauseStart: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // MARK: - Callbacks
    var onComplete: (() -> Void)?
    var onTick: ((Double, TimeInterval, TimeInterval) -> Void)? // progress, elapsed, remaining

    deinit {
        timer?.setEventHandler {}
        timer?.cancel()
        let task = backgroundTask
        if task != .invalid {
            Task { @MainActor in
                UIApplication.shared.endBackgroundTask(task)
            }
        }
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
        pausedDuration = 0.0
        pauseStart = nil
        beginBackgroundTask()
        startTimer()
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        pauseStart = Date()
    }

    func resume() {
        guard isRunning, isPaused, let pauseStart else { return }
        pausedDuration += Date().timeIntervalSince(pauseStart)
        self.pauseStart = nil
        isPaused = false
        tick(now: Date())
    }

    func cancel() {
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
        isRunning = false
        isPaused = false
        isComplete = false
        progress = 0.0
        elapsed = 0.0
        remaining = 0.0
        startDate = nil
        pausedDuration = 0.0
        pauseStart = nil
        endBackgroundTask()
    }

    /// Elapsed time excluding paused periods.
    var activeElapsed: TimeInterval {
        activeElapsed(at: Date())
    }

    // MARK: - Private Timer

    private func startTimer() {
        let queue = DispatchQueue(label: "com.timeshadow.timer", qos: .userInteractive)
        let timerSource = DispatchSource.makeTimerSource(queue: queue)
        timerSource.schedule(deadline: .now(), repeating: 0.05) // 50 ms ≈ 60 fps
        timerSource.setEventHandler { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick(now: Date())
            }
        }
        timer = timerSource
        timerSource.resume()
    }

    private func tick(now: Date) {
        guard isRunning else { return }

        let wallElapsed = startDate.map { now.timeIntervalSince($0) } ?? 0
        let active = activeElapsed(at: now)
        let newProgress = min(active / totalDuration, 1.0)
        let newRemaining = max(totalDuration - active, 0.0)

        elapsed = wallElapsed
        remaining = newRemaining
        progress = newProgress
        onTick?(newProgress, active, newRemaining)

        if newProgress >= 1.0 {
            complete()
        }
    }

    private func activeElapsed(at now: Date) -> TimeInterval {
        guard let startDate else { return elapsed }
        var totalPaused = pausedDuration
        if isPaused, let pauseStart {
            totalPaused += now.timeIntervalSince(pauseStart)
        }
        return max(now.timeIntervalSince(startDate) - totalPaused, 0)
    }

    private func complete() {
        isComplete = true
        isRunning = false
        isPaused = false
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
        endBackgroundTask()
        onComplete?()
    }

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            Task { @MainActor in
                self?.endBackgroundTask()
            }
        }
    }

    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}
