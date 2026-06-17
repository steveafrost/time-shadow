import WidgetKit
import SwiftUI

// MARK: - WidgetBundle
//
// NOTE: This widget requires a separate Widget Extension target in Xcode.
// The @main attribute is intentionally removed because this file lives in
// the main app target. To re-enable the widget:
//   1. In Xcode: File → New → Target → Widget Extension
//   2. Set the bundle identifier to com.steveafrost.TimeShadow.Widget
//   3. Move TimerWidget.swift and WidgetBundle.swift into that target
//   4. Uncomment @main below and remove from main target's Sources build phase

//@main
struct TimeShadowWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
    }
}
