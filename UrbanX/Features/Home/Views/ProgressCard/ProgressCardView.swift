//
//  ProgressCardView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 20.06.2026.
//

import SwiftUI

/// Верхняя карточка на странице программы в карусели: название программы,
/// дорожка прогресса с кружками и кнопка «Старт».
struct ProgressCardView: View {
    // MARK: - Internal Properties
    /// Название программы крупным шрифтом (`Program.cardTitle`).
    let title: String

    /// Номер последнего пройденного шага (1…`stepCount`) — передаётся в `WorkoutProgressBar` как `lastCircle`.
    let currentStep: Int

    /// Идентификатор программы — сбрасывает состояние `WorkoutProgressBar` при смене страницы.
    let programID: UUID

    /// Выбрана ли в карусели страница программы с этими карточками.
    let isSelected: Bool

    /// Проигрывалась ли анимация заполнения для этой страницы в текущем запуске приложения.
    let hasAnimatedBefore: Bool

    /// Можно ли запускать анимацию.
    let canAnimate: Bool

    /// Вызывается по завершении анимации прогресса на карточке программы.
    let onAnimationPlayed: () -> Void

    let onCardTapped: () -> Void

    // MARK: - Body
    var body: some View {
        cardContent
            .contentShape(Rectangle())
            .onTapGesture(perform: onCardTapped)
            .uxSurface(
                cornerRadius: LocalConstants.cornerRadius,
                padding: LocalConstants.cardPadding,
                fill: UXColor.cardColor,
                stroke: UXColor.border,
                lineWidth: LocalConstants.borderWidth,
                shadow: true,
                glow: true,
                glowColor: UXColor.cardGlow,
                glowLayers: UXGlow.cardLayers
            )
    }


    // MARK: - Содержимое карточки

    /// Карточка с фоном, обводкой и тенью: блок прогресса и кнопка «Старт».
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: LocalConstants.sectionSpacing) {
            progressSection
            startButton
        }
    }

    // MARK: - Блок прогресса

    /// Название программы и дорожка пошагового прогресса с кружками.
    private var progressSection: some View {
        VStack(alignment: .leading) {
            cardHeader
            workoutProgressBar
        }
    }

    // MARK: - Заголовок карточки

    /// Название программы и шеврон.
    private var cardHeader: some View {
        HStack(spacing: LocalConstants.cardHeaderSpacing) {
            programTitle
            chevron
        }
    }
    
    /// Иконка-шеврон справа от названия программы.
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .uxIconFont(.medium, large: LocalConstants.iconFontLargeScale)
            .foregroundStyle(UXColor.programChevron)
            .offset(y: LocalConstants.chevronOffsetY)
    }

    /// Название программы крупным шрифтом.
    private var programTitle: some View {
        Text(title)
            .uxFont(
                .title,
                compact: LocalConstants.fontCompactScale,
                large: LocalConstants.fontLargeScale
            )
            .foregroundStyle(UXColor.programTitleColor)
    }

    /// Дорожка прогресса с кружками шагов.
    private var workoutProgressBar: some View {
        WorkoutProgressBar(
            lastCircle: currentStep,
            isSelected: isSelected,
            canAnimate: canAnimate,
            hasAnimatedBefore: hasAnimatedBefore,
            onAnimationPlayed: onAnimationPlayed
        )
        .id(programID)
        .padding(.horizontal, LocalConstants.progressHorizontalPadding)
    }
    
    // MARK: - Кнопка «Старт»

    /// Кнопка запуска тренировки под блоком прогресса.
    private var startButton: some View {
        Button {
//            store.send(.startTapped)
        } label: {
            startButtonLabel
        }
    }
    
    /// Текст и оформление кнопки «Старт».
    private var startButtonLabel: some View {
        Text(Strings.Home.Start.button)
            .uxFont(.label, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.buttonForeground)
            .frame(maxWidth: .infinity)
            .uxFrame(height: LocalConstants.buttonHeight, large: LocalConstants.buttonHeightLargeScale)
            .uxSurface(
                cornerRadius: LocalConstants.buttonCornerRadius,
                padding: LocalConstants.startButtonPadding,
                paddingEdges: [.horizontal],
                fill: UXColor.buttonBackground,
                stroke: UXColor.buttonBorder,
                lineWidth: LocalConstants.borderWidth
            )
    }
}

// MARK: - Constants
private extension ProgressCardView {
    enum LocalConstants {
        /// Радиус углов белого/тёмного фона карточки.
        static let cornerRadius: CGFloat = 27

        /// Отступ содержимого карточки от края её фона (уровень 1).
        static let cardPadding: CGFloat = 16

        /// Горизонтальный отступ текста кнопки «Старт» внутри её фона.
        static let startButtonPadding: CGFloat = 8

        /// Дополнительный отступ дорожки прогресса от левого и правого края фона карточки.
        static let progressHorizontalPadding: CGFloat = 12

        /// Между блоком заголовка с прогрессом и кнопкой «Старт».
        static let sectionSpacing: CGFloat = 18

        /// Между названием программы и иконкой-шевроном в заголовке карточки.
        static let cardHeaderSpacing: CGFloat = 12

        /// Вертикальный сдвиг шеврона для визуального выравнивания с текстом.
        static let chevronOffsetY: CGFloat = 1

        /// Высота кнопки «Старт».
        static let buttonHeight: CGFloat = 44

        /// Множитель высоты кнопки «Старт» на больших экранах (`uxFrame`).
        static let buttonHeightLargeScale: CGFloat = 1.15

        /// Скругление фона кнопки «Старт».
        static let buttonCornerRadius: CGFloat = 11

        /// Толщина обводки вокруг фона карточки и кнопки «Старт».
        static let borderWidth: CGFloat = 1

        /// Множитель размера иконки-шеврона на больших экранах (`uxIconFont`).
        static let iconFontLargeScale: CGFloat = 1.1

        /// Множитель размера шрифта на компактных экранах (`uxFont`).
        static let fontCompactScale: CGFloat = 0.9

        /// Множитель размера шрифта на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.1
    }
}
