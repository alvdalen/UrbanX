//
//  LevelView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 20.06.2026.
//

import SwiftUI

/// Венок с римским номером уровня программы.
struct LevelView: View {
    // MARK: - Internal Properties
    /// Римский номер или текст текущего уровня программы.
    let level: String

    // MARK: - Body
    var body: some View {
        levelRow
    }


    // MARK: - Строка уровня

    /// Горизонтальная обёртка бейджа уровня.
    private var levelRow: some View {
        HStack(spacing: LocalConstants.rowSpacing) {
            levelBadge
                .offset(y: LocalConstants.rowOffsetY)
        }
    }

    // MARK: - Бейдж уровня

    /// Венок с номером уровня по центру строки.
    private var levelBadge: some View {
        ZStack {
            wreathImage
            levelText
        }
    }

    /// Изображение венка бронзового цвета вокруг номера уровня.
    private var wreathImage: some View {
        Image(uiImage: UIImage(named: "venok3")!
            .withRenderingMode(.alwaysTemplate))
            .resizable()
            .scaledToFit()
            .foregroundStyle(UXColor.levelWreath)
            .uxFrame(
                width: LocalConstants.wreathSize,
                height: LocalConstants.wreathSize,
                large: LocalConstants.wreathLargeScale
            )
    }

    /// Номер уровня поверх венка.
    private var levelText: some View {
        Text(level)
            .uxFont(.display, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.levelNumberText)
            .offset(y: LocalConstants.levelTextOffsetY)
    }
}

// MARK: - Constants
private extension LevelView {
    enum LocalConstants {
        /// Горизонтальный зазор в строке бейджа уровня.
        static let rowSpacing: CGFloat = 10

        /// Ширина и высота изображения венка вокруг номера уровня.
        static let wreathSize: CGFloat = 43

        /// Вертикальный сдвиг цифры уровня внутри венка для визуального центрирования.
        static let levelTextOffsetY: CGFloat = -2

        /// Вертикальный сдвиг строки с венком для визуального выравнивания.
        static let rowOffsetY: CGFloat = 1

        /// Множитель размера венка на больших экранах (`uxFrame`).
        static let wreathLargeScale: CGFloat = 1.1

        /// Множитель размера римского номера уровня на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.2
    }
}
