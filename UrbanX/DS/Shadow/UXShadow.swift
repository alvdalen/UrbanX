//
//  UXShadow.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//
import SwiftUI

/// Параметры тематической тени: цвет, радиус размытия и смещение.
struct UXShadowStyle: Equatable {
    /// Цвет тени.
    let color: Color

    /// Радиус размытия тени.
    let radius: CGFloat

    /// Горизонтальное смещение тени.
    let x: CGFloat

    /// Вертикальное смещение тени.
    let y: CGFloat
}

extension View {
    /// Применяет тематическую тень из `LightTheme` / `DarkTheme` через `UXTheme.Reader`.
    ///
    /// - Parameter enabled: `false` — view без изменений.
    ///
    /// - Returns: view с `.shadow` или без него.
    @ViewBuilder
    func uxShadow(enabled: Bool = true) -> some View {
        if enabled {
            UXTheme.Reader { mode in
                let style = mode.pick(LightTheme.shadow, dark: DarkTheme.shadow)
                shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
            }
        } else {
            self
        }
    }
}
