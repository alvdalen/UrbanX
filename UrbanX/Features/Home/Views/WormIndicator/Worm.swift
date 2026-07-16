//
//  Worm.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 28.06.2026.
//

import SwiftUI

/// Форма активной метки индикатора — скруглённый прямоугольник между `head` и `tail`.
///
/// Реализует `Animatable` через `animatableData`, чтобы SwiftUI интерполировал `head` и `tail`
/// независимо в разных `withAnimation` — иначе эффект растяжения метки пропал бы.
struct Worm: Shape {
    // MARK: - Internal Properties
    /// Позиция переднего конца активной метки по X от левого края.
    /// При движении вправо уходит к цели первым — метка вытягивается вперёд.
    /// При движении влево догоняет вторым — метка сжимается слева.
    var head: CGFloat

    /// Позиция заднего конца активной метки по X от левого края.
    /// При движении вправо догоняет вторым — метка сжимается справа.
    /// При движении влево уходит к цели первым — метка вытягивается влево.
    var tail: CGFloat

    /// Диаметр вытянутой активной метки и размер области нажатия каждой точки.
    var diameter: CGFloat

    /// Связка `head` и `tail` с протоколом `Animatable` для независимой покадровой интерполяции концов метки.
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(head, tail) }
        set { head = newValue.first; tail = newValue.second }
    }
    
    // MARK: - Internal Methods
    /// Строит путь вытянутой формы между текущими позициями `tail` и `head`.
    ///
    /// `x = min(head, tail)` — левый край при движении в обе стороны.
    /// `width = abs(head - tail) + diameter` — расстояние между концами плюс `diameter`,
    /// чтобы при `head == tail` форма не сжималась меньше одной точки.
    /// `cornerRadius = diameter / 2` — полностью скруглённые концы.
    ///
    /// - Parameter rect: фрейм view не используется; координаты считаются из `head`, `tail` и `diameter`.
    ///
    /// - Returns: путь скруглённой активной метки.
    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: CGRect(
                x: min(head, tail),
                y: 0,
                width: abs(head - tail) + diameter,
                height: diameter
            ),
            cornerRadius: diameter / 2
        )
    }
}
