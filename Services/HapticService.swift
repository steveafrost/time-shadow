import UIKit
import CoreHaptics

// MARK: - HapticService

/// Manages haptic feedback:
/// - Free: simple tap on finish
/// - Pro: escalating "sunrise" alarm using CHHapticEngine curve
class HapticService {
    static let shared = HapticService()

    private var engine: CHHapticEngine?
    private var engineNeedsStart = true

    private init() {
        createEngine()
    }

    // MARK: - Finish Haptic (Free)

    /// A simple, gentle tap pattern for timer completion (free tier).
    func playFinishHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.6)

        // A second tap after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.impactOccurred(intensity: 0.8)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            generator.impactOccurred(intensity: 0.5)
        }
    }

    // MARK: - Sunrise Alarm (Pro)

    /// An escalating, pleasant haptic alarm that grows over `duration` seconds.
    /// Requires a device with Core Haptics support.
    func playSunriseHaptic(duration: TimeInterval = 8.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            playFinishHaptic() // fallback
            return
        }

        ensureEngineStarted { [weak self] success in
            guard success, let self else { return }
            do {
                let pattern = try self.sunrisePattern(duration: duration)
                let player = try self.engine?.makePlayer(with: pattern)
                try player?.start(atTime: CHHapticTimeImmediate)
            } catch {
                self.playFinishHaptic() // fallback
            }
        }
    }

    /// Stop any ongoing haptic (e.g. user dismisses completion early).
    func stopHaptic() {
        engine?.stop(completionHandler: nil)
        engineNeedsStart = true
    }

    // MARK: - Private

    private func createEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            engine?.stoppedHandler = { [weak self] _ in
                self?.engineNeedsStart = true
            }
            engine?.resetHandler = { [weak self] in
                self?.engineNeedsStart = true
                self?.createEngine()
            }
        } catch {
            engine = nil
        }
    }

    private func ensureEngineStarted(completion: @escaping (Bool) -> Void) {
        guard let engine else {
            completion(false)
            return
        }
        if engineNeedsStart {
            engine.start { error in
                if error != nil {
                    completion(false)
                } else {
                    self.engineNeedsStart = false
                    completion(true)
                }
            }
        } else {
            completion(true)
        }
    }

    /// Build an escalating haptic pattern: gentle taps that grow stronger.
    private func sunrisePattern(duration: TimeInterval) throws -> CHHapticPattern {
        let totalTime = max(duration, 2.0)
        let segments = 16
        let segDuration = totalTime / Double(segments)

        var events: [CHHapticEvent] = []

        for i in 0..<segments {
            let time = Double(i) * segDuration
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.2 + 0.7 * Double(i) / Double(segments)))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.1 + 0.5 * Double(i) / Double(segments)))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: time)
            events.append(event)
        }

        // Continuous low hum that fades in
        let contIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
        let contSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        let continuous = CHHapticEvent(eventType: .hapticContinuous,
                                       parameters: [contIntensity, contSharpness],
                                       relativeTime: 0,
                                       duration: totalTime)
        events.append(continuous)

        return try CHHapticPattern(events: events, parameters: [])
    }
}
