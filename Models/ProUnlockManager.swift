import Foundation
import Combine

// MARK: - ProUnlockManager

/// Lightweight in-memory manager for Pro unlock state.
/// The source of truth is StoreKitManager.isPro — this mirrors it for
/// easy observation across the app without importing StoreKit everywhere.
class ProUnlockManager: ObservableObject {
    static let shared = ProUnlockManager()

    @Published var isPro: Bool = false

    private init() {}

    func update(from isProPurchased: Bool) {
        guard isProPurchased != isPro else { return }
        DispatchQueue.main.async { [weak self] in
            self?.isPro = isProPurchased
        }
    }
}
