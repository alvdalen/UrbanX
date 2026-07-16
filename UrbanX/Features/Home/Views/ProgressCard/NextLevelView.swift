//
//  NextLevelView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 24.06.2026.
//

import SwiftUI

/// Promo-полоска «До следующего уровня — N тренировок» на странице программы,
/// под карточкой прогресса с дорожкой кружков.
///
/// Свечение (тёмная тема): на обёртке `.uxSurface` этого view —
/// `glow: true`, `glowColor: UXColor.nextLevelGlow`, `glowLayers: UXGlow.nextLevelLayers`.
struct NextLevelView: View {
    // MARK: - Body
    var body: some View {
        nextLevelRow
            .uxSurface(
                cornerRadius: LocalConstants.cornerRadius,
                padding: LocalConstants.surfacePadding,
                paddingEdges: [.horizontal],
                fill: UXColor.promoBackground,
                stroke: UXColor.promoBorder,
                lineWidth: LocalConstants.borderWidth,
                glow: true,
                glowColor: UXColor.nextLevelGlow,
                glowLayers: UXGlow.nextLevelLayers
            )
    }


    // MARK: - Строка promo-блока

    /// Горизонтальная строка: иконка, вертикальная черта и блок текста.
    private var nextLevelRow: some View {
        HStack(spacing: LocalConstants.rowSpacing) {
            venokView
            verticalDivider
            textBlock
        }
        .uxFrame(height: LocalConstants.rowHeight, large: LocalConstants.rowHeightLargeScale)
    }
    
    /// Вертикальная черта между венком уровня и текстовым блоком.
    private var verticalDivider: some View {
        Divider()
            .padding(.vertical, LocalConstants.dividerVerticalPadding)
    }

    // MARK: - Венок уровня

    /// Бейдж текущего уровня программы слева в promo-блоке.
    private var venokView: some View {
        LevelView(level: "XI")
    }

    // MARK: - Текстовый блок

    /// Основная и вторичная строки о прогрессе до следующего уровня.
    private var textBlock: some View {
        VStack(alignment: .leading, spacing: LocalConstants.textSpacing) {
            Text(Strings.NextLevel.rank)
                .uxFont(
                    .eyebrow,
                    compact: LocalConstants.fontCompactScale,
                    large: LocalConstants.fontLargeScale
                )
                .foregroundStyle(UXColor.rankTextColor)
            
            primaryText
            secondaryText
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Заголовок «До следующего уровня — N тренировки».
    private var primaryText: some View {
        Text(Strings.NextLevel.title)
            .uxFont(
                .captionStrong,
                compact: LocalConstants.fontCompactScale,
                large: LocalConstants.fontLargeScale
            )
            .foregroundStyle(UXColor.nextLevelTextColor)
    }

    /// Схема повторений под заголовком (превью-данные).
    private var secondaryText: some View {
        Text(Strings.NextLevel.subtitle)
            .uxFont(
                .caption,
                compact: LocalConstants.fontCompactScale,
                large: LocalConstants.fontLargeScale
            )
            .foregroundStyle(UXColor.repsTextColor)
    }
}

// MARK: - Constants
private extension NextLevelView {
    enum LocalConstants {
        /// Скругление фона promo-блока «До следующего уровня».
        static let cornerRadius: CGFloat = 20

        /// Горизонтальный отступ содержимого от края promo-фона.
        static let surfacePadding: CGFloat = 12

        /// Между венком, вертикальной чертой и блоком текста в одной строке.
        static let rowSpacing: CGFloat = 10

        /// Между основной строкой «До следующего уровня…» и подписью под ней.
        static let textSpacing: CGFloat = 4

        /// Отступ вертикальной черты от верхнего и нижнего края promo-блока.
        static let dividerVerticalPadding: CGFloat = 9

        /// Высота всей полоски «До следующего уровня» (иконка + текст в одной строке).
        static let rowHeight: CGFloat = 57

        /// Множитель высоты promo-блока на больших экранах (`uxFrame`).
        static let rowHeightLargeScale: CGFloat = 1.15

        /// Толщина обводки promo-блока.
        static let borderWidth: CGFloat = 1

        /// Множитель размера шрифта на компактных экранах (`uxFont`).
        static let fontCompactScale: CGFloat = 0.9

        /// Множитель размера шрифта на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.1
    }
}
