import SwiftUI

@main
struct TimeShadowApp: App {
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var proUnlock = ProUnlockManager.shared
    @StateObject private var analytics = AnalyticsService.shared
    @StateObject private var timerEngine = TimerEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKit)
                .environmentObject(proUnlock)
                .environmentObject(analytics)
                .environmentObject(timerEngine)
                .preferredColorScheme(.dark)
                .task {
                    await storeKit.loadProducts()
                    await storeKit.checkProEntitlement()
                }
        }
    }
}
