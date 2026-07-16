//
//  UXGlow.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Пресеты контурного свечения: набор колец `(spread, opacity, blur)` для `SurfaceOutlineGlow`.
enum UXGlow {
    /// Один слой свечения: разброс от контура, прозрачность и радиус размытия.
    typealias Layer = (spread: CGFloat, opacity: CGFloat, blur: CGFloat)

    /// Свечение карточки программы и кнопки «Старт».
    static let cardLayers: [Layer] = [
        (2, 0.05, 6),
        (3, 0.10, 4),
        (1.5, 0.22, 2),
        (0.6, 0.40, 1),
    ]

    /// Свечение карточек статистики.
    static let statsLayers: [Layer] = [
        (6, 0.05, 6),
        (3, 0.10, 4),
        (1.5, 0.22, 2),
        (0.6, 0.40, 1),
    ]

    /// Свечение promo-блока «До следующего уровня».
    static let nextLevelLayers: [Layer] = [
        (6, 0.08, 6),
        (3, 0.18, 4),
        (2, 0.35, 2.5),
        (0.6, 0.40, 1),
    ]

    /// Свечение выбранного чипа программы.
    static let selectedChipLayers: [Layer] = [
        (2, 0.05, 6),
        (3, 0.10, 4),
        (1.5, 0.22, 2),
        (0.6, 0.40, 1),
    ]

    /// Свечение заливки дорожки пошагового прогресса.
    static let progressLayers: [Layer] = [
        (8, 0.06, 8),
        (4, 0.14, 5),
        (2, 0.30, 2.5),
        (0.8, 0.62, 1),
    ]

    /// Максимальный вынос свечения за контур — для расчёта `padding` оверлея.
    ///
    /// - Parameter layers: пресет колец свечения.
    ///
    /// - Returns: наибольшее значение `spread + blur` среди слоёв.
    static func maxExtent(for layers: [Layer]) -> CGFloat {
        layers.map { $0.spread + $0.blur }.max() ?? 0
    }
}
