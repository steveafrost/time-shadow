import SwiftUI

@main
struct TimeShadowApp: App {
    @StateObject private var storeKit = StoreKitManager.shared
    @StateObject private var proUnlock = ProUnlockManager.shared
    @StateObject private var analytics = AnalyticsService.shared
    @StateObject private var appSettings = AppSettings.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var timerEngine = TimerEngine.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeKit)
                .environmentObject(proUnlock)
                .environmentObject(analytics)
                .environmentObject(appSettings)
                .environmentObject(notificationService)
                .environmentObject(timerEngine)
                .preferredColorScheme(.dark)
                .task {
                    await storeKit.loadProducts()
                    await storeKit.checkProEntitlement()
                }
        }
    }
}
