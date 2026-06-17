import Foundation
import StoreKit

// MARK: - StoreKitManager

/// Manages the one-time $3.99 Pro purchase via StoreKit 2.
/// Provides observable `isPro` state.
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var isPro: Bool = false
    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String?

    private let proProductID = "com.steveafrost.TimeShadow.pro"

    private var updates: Task<Void, Never>?

    private init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [proProductID])
            await MainActor.run {
                self.products = products
            }
        } catch {
            print("[StoreKitManager] Failed to load products: \(error)")
        }
    }

    // MARK: - Check Entitlement

    func checkProEntitlement() async {
        // Check the app transaction first (for previously purchased consumables/non-consumables)
        if let appTransaction = try? await AppTransaction.shared {
            if case .verified = appTransaction {
                // Non-consumable purchases are checked via transaction updates
            }
        }

        // Iterate current entitlements
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == proProductID {
                    await MainActor.run {
                        self.isPro = true
                        ProUnlockManager.shared.update(from: true)
                    }
                    return
                }
            }
        }
    }

    // MARK: - Purchase

    func purchasePro() async {
        guard let product = products.first(where: { $0.id == proProductID }) else {
            await MainActor.run { self.purchaseError = "Product not loaded." }
            return
        }

        await MainActor.run {
            isPurchasing = true
            purchaseError = nil
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await MainActor.run {
                        self.isPro = true
                        ProUnlockManager.shared.update(from: true)
                    }
                } else {
                    await MainActor.run {
                        self.purchaseError = "Purchase verification failed."
                    }
                }
            case .userCancelled:
                await MainActor.run {
                    self.purchaseError = nil // Not an error
                }
            case .pending:
                await MainActor.run {
                    self.purchaseError = "Purchase is pending approval."
                }
            @unknown default:
                break
            }
        } catch {
            await MainActor.run {
                self.purchaseError = error.localizedDescription
            }
        }

        await MainActor.run {
            isPurchasing = false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        // App Store automatically restores non-consumables on reinstall,
        // but we provide a manual button for safety.
        await checkProEntitlement()
    }

    // MARK: - Transaction Updates

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == self?.proProductID {
                        await MainActor.run {
                            self?.isPro = true
                            ProUnlockManager.shared.update(from: true)
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
