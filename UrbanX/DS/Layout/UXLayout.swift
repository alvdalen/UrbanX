//
//  UXLayout.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

// MARK: - View
extension View {
    /// Задаёт ширину и/или высоту view. Размеры с макета Pro, масштаб по осям отдельно.
    ///
    /// Передай только `height`, только `width` или оба — как обычный `.frame`.
    ///
    /// - Parameters:
    ///   - width: ширина с макета Pro в pt; `nil` — не задаёт ширину.
    ///   - height: высота с макета Pro в pt; `nil` — не задаёт высоту.
    ///   - compact: множитель для iPhone SE; не указано — как на макете.
    ///   - large: множитель для iPhone Pro Max; не указано — как на макете.
    ///   - alignment: выравнивание содержимого внутри frame.
    func uxFrame(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        compact: CGFloat? = nil,
        large: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> some View {
        let multipliers = UXMetrics.resolvedMultipliers(compact: compact, large: large)
        return modifier(UXAdaptiveFrameModifier(
            baseWidth: width,
            baseHeight: height,
            compactMultiplier: multipliers.compact,
            largeMultiplier: multipliers.large,
            alignment: alignment
        ))
    }

    /// Размер SF Symbol. Базовый pt — в `UXFontSize`, пресет — в `UXIconSize`.
    ///
    /// - Parameters:
    ///   - size: `.medium` и другие пресеты из `UXIconSize`.
    ///   - weight: жирность иконки.
    ///   - compact: множитель для iPhone SE; не указано — как на макете.
    ///   - large: множитель для iPhone Pro Max; не указано — как на макете.
    func uxIconFont(
        _ size: UXIconSize,
        weight: Font.Weight = .regular,
        compact: CGFloat? = nil,
        large: CGFloat? = nil
    ) -> some View {
        let multipliers = UXMetrics.resolvedMultipliers(compact: compact, large: large)
        return modifier(UXIconFontModifier(
            size: size,
            weight: weight,
            compactMultiplier: multipliers.compact,
            largeMultiplier: multipliers.large
        ))
    }

    /// Показывает или скрывает view по классу экрана (compact / etalon / large).
    ///
    /// - Parameters:
    ///   - compact: показывать на мелких экранах (ниже эталона); по умолчанию `true`.
    ///   - etalon: показывать на эталоне (iPhone 17 Pro); по умолчанию `true`.
    ///   - large: показывать на крупных экранах (выше эталона); по умолчанию `true`.
    ///
    /// - Returns: view или `EmptyView`, если для текущего класса экрана выбрано `false`.
    func uxVisible(
        compact: Bool = true,
        etalon: Bool = true,
        large: Bool = true
    ) -> some View {
        modifier(UXVisibilityModifier(
            compact: compact,
            etalon: etalon,
            large: large
        ))
    }
}

// MARK: - Frame modifiers (scale)
/// Считает множитель scale для текущего iPhone по парам SE / Pro / Max.
private func uxLayoutAdaptiveScale(
    compactMultiplier: CGFloat,
    largeMultiplier: CGFloat
) -> UXAdaptiveScale {
    UXMetrics.adaptiveScale(
        for: UXMetrics.screenSize,
        compactMultiplier: compactMultiplier,
        largeMultiplier: largeMultiplier
    )
}

/// Реализация `.uxFrame`. Во view не вызывать.
private struct UXAdaptiveFrameModifier: ViewModifier {
    /// Ширина с макета Pro в pt; `nil` — ширину не задаём.
    let baseWidth: CGFloat?

    /// Высота с макета Pro в pt; `nil` — высоту не задаём.
    let baseHeight: CGFloat?

    /// Множитель для iPhone SE.
    let compactMultiplier: CGFloat

    /// Множитель для iPhone Pro Max.
    let largeMultiplier: CGFloat

    /// Выравнивание содержимого внутри frame.
    let alignment: Alignment

    /// Обновляется при повороте экрана, чтобы пересчитать размер.
    @State private var scale: UXAdaptiveScale = UXAdaptiveScale(horizontal: 1, vertical: 1)

    /// Применяет масштабированный frame и пересчитывает scale при смене ориентации.
    func body(content: Content) -> some View {
        let activeScale = uxLayoutAdaptiveScale(
            compactMultiplier: compactMultiplier,
            largeMultiplier: largeMultiplier
        )

        content
            .frame(
                width: baseWidth.map { activeScale.scaled($0, axis: .horizontal) },
                height: baseHeight.map { activeScale.scaled($0, axis: .vertical) },
                alignment: alignment
            )
            .uxOnScaleChange {
                scale = uxLayoutAdaptiveScale(
                    compactMultiplier: compactMultiplier,
                    largeMultiplier: largeMultiplier
                )
            }
    }
}

// MARK: - Icon font (scale)
/// Реализация `.uxIconFont`. Во view не вызывать.
private struct UXIconFontModifier: ViewModifier {
    /// Пресет размера иконки.
    let size: UXIconSize

    /// Жирность иконки.
    let weight: Font.Weight

    /// Множитель для iPhone SE.
    let compactMultiplier: CGFloat

    /// Множитель для iPhone Pro Max.
    let largeMultiplier: CGFloat

    /// Обновляется при повороте экрана, чтобы пересчитать размер шрифта.
    @State private var scale: UXAdaptiveScale = UXAdaptiveScale(horizontal: 1, vertical: 1)

    /// Размер иконки с макета Pro в pt.
    private var baseSize: CGFloat {
        switch size {
        case .medium: UXFontSize.iconMedium
        case .large: UXFontSize.iconLarge
        }
    }

    /// Применяет масштабированный шрифт иконки и пересчитывает scale при смене ориентации.
    func body(content: Content) -> some View {
        let activeScale = uxLayoutAdaptiveScale(
            compactMultiplier: compactMultiplier,
            largeMultiplier: largeMultiplier
        )

        content
            .font(.system(
                size: activeScale.scaled(baseSize, axis: .horizontal),
                weight: weight
            ))
            .uxOnScaleChange {
                scale = uxLayoutAdaptiveScale(
                    compactMultiplier: compactMultiplier,
                    largeMultiplier: largeMultiplier
                )
            }
    }
}

// MARK: - Visibility (size class)

/// Реализация `.uxVisible`. Во view не вызывать напрямую.
private struct UXVisibilityModifier: ViewModifier {
    /// Показывать на мелких экранах.
    let compact: Bool

    /// Показывать на эталоне.
    let etalon: Bool

    /// Показывать на крупных экранах.
    let large: Bool

    /// Текущий класс экрана; обновляется при смене ориентации.
    @State private var sizeClass: UXScreenSizeClass = UXMetrics.screenSizeClass

    func body(content: Content) -> some View {
        Group {
            if isVisible(for: sizeClass) {
                content
            }
        }
        .uxOnScaleChange {
            sizeClass = UXMetrics.sizeClass(for: UXMetrics.screenSize)
        }
    }

    /// Видимость для заданного класса экрана.
    private func isVisible(for sizeClass: UXScreenSizeClass) -> Bool {
        switch sizeClass {
        case .compact: compact
        case .etalon: etalon
        case .large: large
        }
    }
}
