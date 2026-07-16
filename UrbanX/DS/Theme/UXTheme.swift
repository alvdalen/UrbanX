//
//  UXTheme.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Режим темы интерфейса — обёртка над `ColorScheme` без прямого `@Environment` во views.
enum UXThemeMode: Equatable {
    case light
    case dark

    /// Создаёт режим темы из системной цветовой схемы.
    ///
    /// - Parameter colorScheme: активная `ColorScheme` из environment.
    init(colorScheme: ColorScheme) {
        self = colorScheme == .dark ? .dark : .light
    }

    /// Соответствующая системная цветовая схема.
    var colorScheme: ColorScheme {
        self == .dark ? .dark : .light
    }

    /// Выбирает значение по текущему режиму темы.
    ///
    /// - Parameters:
    ///   - light: значение для светлой темы.
    ///   - dark: значение для тёмной темы.
    ///
    /// - Returns: `light` или `dark` в зависимости от режима.
    func pick<T>(_ light: T, dark: T) -> T {
        self == .dark ? dark : light
    }
}

/// Namespace для темы: `Reader` — единственная точка чтения `colorScheme` во view-слое.
enum UXTheme {
    /// Единственное место с `@Environment(\.colorScheme)` — для Canvas и shadow.
    struct Reader<Content: View>: View {
        @Environment(\.colorScheme) private var colorScheme

        /// Содержимое, получающее текущий `UXThemeMode` из environment.
        @ViewBuilder let content: (UXThemeMode) -> Content

        var body: some View {
            content(UXThemeMode(colorScheme: colorScheme))
        }
    }
}
