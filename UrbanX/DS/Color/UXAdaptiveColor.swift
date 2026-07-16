//
//  UXAdaptiveColor.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Пара светлой и тёмной версии `ShapeStyle`, разрешается по `colorScheme`.
struct UXAdaptiveColor: ShapeStyle {
    /// Стиль для светлой темы.
    let light: AnyShapeStyle

    /// Стиль для тёмной темы.
    let dark: AnyShapeStyle

    /// Цвет светлой темы для Canvas и ручного resolve.
    let lightColor: Color

    /// Цвет тёмной темы для Canvas и ручного resolve.
    let darkColor: Color

    /// Создаёт адаптивный цвет из отдельных стилей светлой и тёмной темы.
    ///
    /// - Parameters:
    ///   - light: стиль для `.light`.
    ///   - dark: стиль для `.dark`.
    init<L: ShapeStyle, D: ShapeStyle>(light: L, dark: D) {
        self.light = AnyShapeStyle(light)
        self.dark = AnyShapeStyle(dark)
        self.lightColor = (light as? Color) ?? .clear
        self.darkColor = (dark as? Color) ?? .clear
    }

    /// Создаёт адаптивный цвет с одинаковым значением в обеих темах.
    ///
    /// - Parameter color: цвет для светлой и тёмной темы.
    init(_ color: Color) {
        self.init(light: color, dark: color)
    }

    /// Возвращает `Color` для заданной темы — для Canvas и ручной отрисовки.
    ///
    /// - Parameter colorScheme: активная цветовая схема интерфейса.
    ///
    /// - Returns: цвет светлой или тёмной темы.
    func resolved(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkColor : lightColor
    }

    /// Разрешает `ShapeStyle` по environment — для `.foregroundStyle` и заливок.
    ///
    /// - Parameter environment: environment values view.
    ///
    /// - Returns: стиль светлой или тёмной темы.
    func resolve(in environment: EnvironmentValues) -> AnyShapeStyle {
        environment.colorScheme == .dark ? dark : light
    }
}
