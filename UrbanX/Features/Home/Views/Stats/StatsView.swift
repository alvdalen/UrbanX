//
//  StatsView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 27.06.2026.
//

import SwiftUI

/// Две карточки внизу страницы программы: слева «Личный рекорд»,
/// справа «Прогресс июня» с линейной полоской прогресса.
struct StatsView: View {
    // MARK: - Internal Properties
    /// Выбрана ли в карусели страница программы с этими карточками.
    let isSelected: Bool

    /// Целевая доля заполнения полоски прогресса (0…1) в правой карточке.
    let progress: Double

    /// Идентификатор программы — сбрасывает состояние `ProgressBar` при смене страницы.
    let programID: UUID

    /// Текст процента прогресса в правой карточке (например «72%»).
    let percentText: String

    /// Проигрывалась ли анимация заполнения для этой страницы в текущем запуске приложения.
    let hasAnimatedBefore: Bool

    /// Можно ли запускать анимацию.
    let canAnimate: Bool

    // MARK: - Body
    var body: some View {
        HStack(spacing: LocalConstants.columnsSpacing) {
            personalRecordCard
            monthProgressCard
        }
    }


    // MARK: - Карточка «Личный рекорд»

    /// Левая карточка «Личный рекорд».
    private var personalRecordCard: some View {
        statsCard {
            personalRecordContent
        }
    }

    /// Внутренняя компоновка левой карточки: шапка, отступ и нижний блок.
    private var personalRecordContent: some View {
        VStack(alignment: .leading, spacing: .zero) {
            personalRecordHeader
            cardHeaderSpacer
            personalRecordFooter
        }
        .offset(y: LocalConstants.contentOffsetY)
    }

    /// Шапка левой карточки: подпись «Личный рекорд», значение и иконка rosette.
    private var personalRecordHeader: some View {
        cardHeader(
            eyebrow: Strings.Stats.PersonalRecord.eyebrow,
            value: "18",
            iconName: "rosette"
        )
    }

    /// Нижний блок левой карточки: название упражнения и подпись «Лучший результат».
    private var personalRecordFooter: some View {
        VStack(alignment: .leading, spacing: LocalConstants.tightSpacing) {
            personalRecordTitle
            personalRecordSubtitle
        }
    }

    /// Название упражнения в левой карточке.
    private var personalRecordTitle: some View {
        Text(Strings.Stats.PersonalRecord.exercise)
            .uxFont(.captionStrong, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.primary)
    }

    /// Подпись «Лучший результат» под названием упражнения.
    private var personalRecordSubtitle: some View {
        Text(Strings.Stats.PersonalRecord.bestResult)
            .uxFont(.caption, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.secondary)
    }

    // MARK: - Карточка «Прогресс июня»

    /// Правая карточка «Прогресс июня» с линейной полоской прогресса.
    private var monthProgressCard: some View {
        statsCard {
            monthProgressContent
        }
    }

    /// Внутренняя компоновка правой карточки: шапка, отступ и нижний блок.
    private var monthProgressContent: some View {
        VStack(alignment: .leading, spacing: .zero) {
            monthProgressHeader
            cardHeaderSpacer
            monthProgressFooter
        }
        .offset(y: LocalConstants.contentOffsetY)
    }

    /// Шапка правой карточки: подпись «Прогресс июня», процент и иконка flame.
    private var monthProgressHeader: some View {
        cardHeader(
            eyebrow: Strings.Stats.MonthProgress.eyebrow,
            value: percentText,
            iconName: "flame"
        )
    }

    /// Нижний блок правой карточки: счётчик тренировок и полоска прогресса.
    private var monthProgressFooter: some View {
        VStack(alignment: .leading, spacing: LocalConstants.footerSpacing) {
            monthProgressText
            monthProgressBar
        }
    }

    /// Счётчик тренировок за месяц в правой карточке.
    private var monthProgressText: some View {
        Text(Strings.Stats.MonthProgress.workouts(18, 25))
            .uxFont(.caption, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.secondary)
    }

    /// Линейная полоска прогресса под счётчиком тренировок.
    private var monthProgressBar: some View {
        ProgressBar(
            progress: progress,
            isSelected: isSelected,
            hasAnimatedBefore: hasAnimatedBefore,
            canAnimate: canAnimate
        )
        .id(programID)
    }

    // MARK: - Общие элементы карточек

    /// Вертикальный зазор между шапкой карточки и нижним блоком.
    private var cardHeaderSpacer: some View {
        Spacer()
            .uxFrame(height: LocalConstants.cardHeaderSpacing)
    }

    /// Бронзовая подпись секции и крупное значение в шапке карточки.
    ///
    /// - Parameters:
    ///   - eyebrow: подпись секции мелким бронзовым шрифтом.
    ///   - value: основное число или текст под подписью.
    ///   - iconName: имя SF Symbol в правом верхнем углу шапки.
    private func cardHeader(
        eyebrow: String,
        value: String,
        iconName: String
    ) -> some View {
        VStack(alignment: .leading, spacing: LocalConstants.cardHeaderSpacing) {
            cardHeaderTopRow(eyebrow: eyebrow, iconName: iconName)
            cardHeaderValue(value)
        }
    }

    // MARK: - Шапка карточки

    /// Верхняя строка шапки: бронзовая подпись слева и иконка справа.
    ///
    /// - Parameters:
    ///   - eyebrow: подпись секции мелким бронзовым шрифтом.
    ///   - iconName: имя SF Symbol в правом верхнем углу.
    private func cardHeaderTopRow(
        eyebrow: String,
        iconName: String
    ) -> some View {
        HStack {
            cardHeaderEyebrow(eyebrow)
            Spacer()
            cardHeaderIcon(iconName)
        }
    }

    /// Бронзовая подпись секции в шапке карточки.
    ///
    /// - Parameter text: локализованная подпись секции.
    private func cardHeaderEyebrow(_ text: String) -> some View {
        Text(text)
            .uxFont(
                .eyebrow,
                compact: LocalConstants.fontCompactScale,
                large: LocalConstants.fontLargeScale
            )
            .foregroundStyle(UXColor.statisticTextColor)
    }

    /// Декоративная иконка в правом верхнем углу шапки карточки.
    ///
    /// - Parameter systemName: имя SF Symbol.
    private func cardHeaderIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .uxIconFont(.large)
            .foregroundStyle(UXColor.statisticIconColor)
            .offset(y: LocalConstants.iconOffsetY)
    }

    /// Крупное значение под бронзовой подписью в шапке карточки.
    ///
    /// - Parameter value: число или текст прогресса.
    private func cardHeaderValue(_ value: String) -> some View {
        Text(value)
            .uxFont(
                .statisticsCount,
                compact: LocalConstants.fontCompactScale,
                large: LocalConstants.fontLargeScale
            )
            .offset(y: LocalConstants.valueOffsetY)
    }

    /// Общая обёртка карточки статистики: размер, фон, обводка и тень.
    ///
    /// - Parameter content: содержимое карточки — шапка и нижний блок.
    ///
    /// - Returns: карточка с фиксированной высотой и `.uxSurface`.
    private func statsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .uxFrame(height: LocalConstants.cardHeight, large: LocalConstants.cardHeightLargeScale)
            .uxSurface(
                cornerRadius: LocalConstants.cornerRadius,
                padding: LocalConstants.cardPadding,
                fill: UXColor.cardColor,
                stroke: UXColor.border,
                lineWidth: LocalConstants.borderWidth,
                shadow: true,
                glow: true,
                glowColor: UXColor.statsGlow,
                glowLayers: UXGlow.statsLayers
            )
    }
}

// MARK: - Constants
private extension StatsView {
    enum LocalConstants {
        /// Радиус углов фона карточки статистики.
        static let cornerRadius: CGFloat = 27

        /// Отступ содержимого карточки от края фона.
        static let cardPadding: CGFloat = 16

        /// Между бронзовой подписью секции («Личный рекорд» / «Прогресс июня») и числом под ней.
        static let cardHeaderSpacing: CGFloat = 6

        /// Между «Подтягиваний» и «Лучший результат» в левой карточке «Личный рекорд».
        static let tightSpacing: CGFloat = 4

        /// Между строкой «18 из 25 тренировок» и линейной полоской прогресса в правой карточке.
        static let footerSpacing: CGFloat = 12

        /// Между левой карточкой «Личный рекорд» и правой «Прогресс июня».
        static let columnsSpacing: CGFloat = 16

        /// Толщина обводки вокруг фона карточки статистики.
        static let borderWidth: CGFloat = 1

        /// Высота одной карточки статистики (левая и правая одинаковые).
        static let cardHeight: CGFloat = 80

        /// Множитель высоты карточки статистики на больших экранах (`uxFrame`).
        static let cardHeightLargeScale: CGFloat = 1.1

        /// Вертикальный сдвиг содержимого карточки для визуального баланса.
        static let contentOffsetY: CGFloat = -3

        /// Вертикальный сдвиг иконки в шапке карточки.
        static let iconOffsetY: CGFloat = 3

        /// Вертикальный сдвиг крупного числа в шапке карточки.
        static let valueOffsetY: CGFloat = -3

        /// Множитель размера шрифта на компактных экранах (`uxFont`).
        static let fontCompactScale: CGFloat = 0.9

        /// Множитель размера шрифта на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.1
    }
}
