//
//  DarkTheme.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Тёмная палитра. Используется только через `UXColor`, не напрямую во views.
enum DarkTheme {

    // MARK: - Gradients

    private static let buttonMintToBlack = LinearGradient(
        colors: [
            Color(red: 12 / 255, green: 28 / 255, blue: 24 / 255),
            Color(red: 4 / 255, green: 5 / 255, blue: 5 / 255)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Text

    /// Основной текст интерфейса.
    static let primary = Color.primary

    /// Вторичный текст: подписи, вспомогательные строки.
    static let secondary = Color.secondary

    /// Вторичный текст в promo-блоках и карточках статистики.
    static let secondaryText = secondary

    // MARK: - Surfaces & Backgrounds

    /// Фон карточек и вложенных блоков.
    static let cardColor = Brand.accent.opacity(0.055)

    /// Полупрозрачный оверлей поверх звёздного фона главного экрана.
    static let homeScreenFill = Color.clear

    /// Обводка карточек и promo-блоков.
    static let border = Brand.accent.opacity(0.3)

    // MARK: - Program Card

    /// Название программы в заголовке карточки.
    static let programTitle = Color.white

    /// Иконка-шеврон рядом с названием программы.
    static let programChevron = Color(.systemGray)

    // MARK: - Workout Progress

    /// Фон дорожки линейного прогресса.
    static let progressTrack = Brand.progressTrackDark

    /// Заливка активного сегмента прогресса.
    static let progressFill = Brand.circleUpcomingDark

    /// Обводка заливки прогресса.
    static let progressFillStroke = Brand.threeAccent

    /// Вторичная заливка полоски прогресса в карточках статистики.
    static let progressFillSecondary = Brand.accent

    /// Акцентная обводка активного шага.
    static let progressEmphasis = Color.clear

    /// Приглушённая обводка неактивных шагов.
    static let progressMuted = Brand.progressTrackDark

    // MARK: - Progress Circles

    /// Фон завершённого шага.
    static let circleDone = Brand.circleUpcomingDark

    /// Галочка внутри завершённого шага.
    static let circleDoneMark = Brand.threeAccent

    /// Кольцо вокруг завершённого шага.
    static let circleDoneRing = Color.clear

    /// Точка текущего активного шага.
    static let circleActiveDot = Brand.threeAccent

    /// Фон текущего активного шага.
    static let circleActiveBackground = Brand.circleUpcomingDark

    /// Фон предстоящего шага.
    static let upcomingCircle = Brand.circleUpcomingDark

    // MARK: - Buttons

    /// Текст на кнопке «Старт».
    static let buttonForeground = Brand.accent

    /// Фон кнопки «Старт».
    static let buttonBackground = buttonMintToBlack

    /// Обводка кнопки «Старт».
    static let buttonBorder = Brand.accent.opacity(0.3)

    // MARK: - Chips

    /// Точка разделитель.
    static let chipDot = Brand.accent
    
    /// Текст выбранного чипа программы.
    static let chipForegroundSelected = Brand.accent

    /// Текст невыбранного чипа программы.
    static let chipForegroundResting = Color.secondary

    /// Фон выбранного чипа программы.
    static let chipBackgroundSelected = Brand.accent.opacity(0.055)

    /// Фон невыбранного чипа программы.
    static let chipBackgroundResting = Brand.accent.opacity(0.015)

    /// Обводка выбранного чипа программы.
    static let chipBorderSelected = Brand.accent.opacity(0.3)

    /// Обводка невыбранного чипа программы.
    static let chipBorderResting = Color.secondary.opacity(0.3)

    // MARK: - Next Level

    /// Фон полоски «До следующего уровня».
    static let promoBackground = Brand.secondAccent.opacity(0.055)

    /// Обводка полоски «До следующего уровня».
    static let promoBorder = Brand.secondAccent.opacity(0.3)

    /// Основной текст в блоке следующего уровня.
    static let nextLevelText = primary

    /// Текст ранга («GERKULES») в блоке следующего уровня.
    static let rankLevelText = Brand.secondAccent

    // MARK: - Statistics

    /// Иконка в заголовке карточки статистики.
    static let statisticIcon = Brand.threeAccent

    /// Подпись секции и вспомогательный текст в карточках статистики.
    static let statisticText = Brand.accent

    // MARK: - Level Badge

    /// Изображение венка вокруг номера уровня.
    static let levelWreath = Brand.threeAccent

    /// Римский номер уровня внутри венка.
    static let levelNumberText = primary

    // MARK: - Navigation & Indicators

    /// Неактивная точка червеобразного индикатора страниц.
    static let indicatorDot = Brand.dotDark

    /// Активная точка индикатора страниц.
    static let pageIndicatorActive = Brand.accent

    /// Акцентный цвет элементов tab bar.
    static let tabBar = Brand.accent

    // MARK: - Effects

    /// Тень карточек и поверхностей.
    static let shadow = UXShadowStyle(color: .clear, radius: 6, x: 0, y: 0)

    /// Свечение карточки программы.
    static let cardGlow = Brand.accent

    /// Свечение карточек статистики.
    static let statsGlow = Brand.accent

    /// Свечение блока следующего уровня.
    static let nextLevelGlow = Brand.secondAccent

    /// Свечение выбранного чипа программы.
    static let selectedChipGlow = Brand.accent
}
