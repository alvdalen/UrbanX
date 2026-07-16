//
//  UrbanXApp.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI
import ComposableArchitecture

@main
struct UrbanXApp: App {

    /// Прогревает haptic-генераторы и настраивает шрифты navigation bar до первого кадра.
    init() {
        HapticFeedback.warmUp()
        configureNavigationBar()
    }

    /// Корневой store приложения с превью-программами на главном экране.
    let store = Store(
        initialState: AppFeature.State(
            home: HomeFeature.State(programs: Program.previewPrograms)
        )
    ) {
        AppFeature()
    }

    // MARK: - Body

    /// Корневое окно приложения с `AppView` и вкладками.
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }

    // MARK: - Private Methods

    /// Настраивает внешний вид `UINavigationBar` для large title и inline title.
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 30, weight: .heavy),
            .foregroundColor: UIColor.label
        ]

        appearance.titleTextAttributes = [
            .font: UIFont.rounded(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

extension UIFont {
    /// Системный шрифт с rounded design — для inline-заголовка navigation bar.
    ///
    /// - Parameters:
    ///   - size: размер шрифта в pt.
    ///   - weight: жирность шрифта.
    ///
    /// - Returns: `UIFont` с `.rounded` design или системный fallback.
    static func rounded(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        let descriptor = font.fontDescriptor.withDesign(.rounded)!
        return UIFont(descriptor: descriptor, size: size)
    }
}
