//
//  UXFontStyle.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Семантические текстовые стили с adaptive-scale.
enum UXFontStyle {
    /// Бронзовая подпись секции, bold + uppercase.
    case eyebrow
    
    /// Раздел статистики.
    case statistic

    /// Крупное значение в карточках, bold.
    case title
    
    /// Крупное значение в карточках статистики.
    case statisticsCount

    /// Вторичный текст среднего размера.
    case bodySmall

    /// Подписи и вторичный текст.
    case caption

    /// Подписи bold (название упражнения и т.п.).
    case captionStrong

    /// Текст кнопки «Старт» — bold, 17 pt etalon.
    case label

    /// Номер уровня в венке, Times New Roman + uppercase.
    case display

    /// Текст чипа программы в горизонтальном ряду.
    case chipSize
}

extension View {
    /// Adaptive-шрифт по семантическому стилю.
    ///
    /// - Parameters:
    ///   - style: пресет из `UXFontStyle` (etalon pt в `UXFontSize`).
    ///   - compact: множитель на iPhone SE; `nil` — etalon (1.0).
    ///   - large: множитель на iPhone Pro Max; `nil` — etalon (1.0).
    func uxFont(
        _ style: UXFontStyle,
        compact: CGFloat? = nil,
        large: CGFloat? = nil
    ) -> some View {
        let multipliers = UXMetrics.resolvedMultipliers(compact: compact, large: large)
        return modifier(UXFontModifier(
            style: style,
            compactMultiplier: multipliers.compact,
            largeMultiplier: multipliers.large
        ))
    }
}

// MARK: - Modifier

/// Реализация `.uxFont`. Во view не вызывать напрямую.
private struct UXFontModifier: ViewModifier {
    /// Семантический стиль шрифта.
    let style: UXFontStyle

    /// Множитель для iPhone SE.
    let compactMultiplier: CGFloat

    /// Множитель для iPhone Pro Max.
    let largeMultiplier: CGFloat

    /// Обновляется при повороте экрана, чтобы пересчитать размер шрифта.
    @State private var scale: UXAdaptiveScale

    init(style: UXFontStyle, compactMultiplier: CGFloat, largeMultiplier: CGFloat) {
        self.style = style
        self.compactMultiplier = compactMultiplier
        self.largeMultiplier = largeMultiplier
        _scale = State(initialValue: UXMetrics.adaptiveScale(
            for: UXMetrics.screenSize,
            compactMultiplier: compactMultiplier,
            largeMultiplier: largeMultiplier
        ))
    }

    /// Применяет вычисленный шрифт и пересчитывает scale при смене ориентации.
    func body(content: Content) -> some View {
        styled(content)
            .uxOnScaleChange {
                scale = UXMetrics.adaptiveScale(
                    for: UXMetrics.screenSize,
                    compactMultiplier: compactMultiplier,
                    largeMultiplier: largeMultiplier
                )
            }
    }

    /// Применяет семантический стиль шрифта к содержимому модификатора.
    ///
    /// - Parameter content: view, к которому применяется `.font`.
    ///
    /// - Returns: содержимое с нужным шрифтом и, где нужно, `.textCase`.
    @ViewBuilder
    private func styled(_ content: Content) -> some View {
        switch style {
        case .eyebrow:
            content
                .font(.system(
                    size: scale.scaled(UXFontSize.eyebrow, axis: .horizontal),
                    weight: .bold, design: .rounded
                ))
                .textCase(.uppercase)

        case .title:
            content.font(.system(
                size: scale.scaled(UXFontSize.title, axis: .horizontal),
                weight: .heavy
            ))

        case .bodySmall:
            content.font(.system(
                size: scale.scaled(UXFontSize.bodySmall, axis: .horizontal), design: .rounded
            ))

        case .caption:
            content.font(.system(
                size: scale.scaled(UXFontSize.caption, axis: .horizontal), design: .rounded
            ))

        case .captionStrong:
            content.font(.system(
                size: scale.scaled(UXFontSize.caption, axis: .horizontal),
                weight: .semibold, design: .rounded
            ))

        case .label:
            content.font(.system(
                size: scale.scaled(UXFontSize.label, axis: .horizontal),
                weight: .bold/*, design: .rounded*/
            ))

        case .display:
            content
                .font(.system(size: scale.scaled(UXFontSize.display, axis: .horizontal), design: .serif
                ))
                .textCase(.uppercase)
        case .chipSize:
            content.font(.system(size: scale.scaled(UXFontSize.chipSize, axis: .horizontal), design: .rounded))
            
        case .statistic:
            content
                .font(.system(
                    size: scale.scaled(UXFontSize.statistic, axis: .horizontal),
                    weight: .bold, design: .rounded
                ))
                .textCase(.uppercase)
            
        case .statisticsCount:
            content.font(.system(
                size: scale.scaled(UXFontSize.statisticsCount, axis: .horizontal),
                weight: .bold
            ))
        }
    }
}
