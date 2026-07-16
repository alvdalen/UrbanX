//
//  LightTheme.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Светлая палитра. Используется только через `UXColor`, не напрямую во views.
enum LightTheme {

    // MARK: - Text

    /// Основной текст интерфейса.
    static let primary = Color.primary

    /// Вторичный текст: подписи, вспомогательные строки.
    static let secondary = Color.secondary

    /// Вторичный текст в promo-блоках и карточках статистики.
    static let secondaryText = Color.secondary

    // MARK: - Surfaces & Backgrounds

    /// Фон карточек и вложенных блоков.
    static let cardColor = Color(.secondarySystemGroupedBackground)

    /// Полупрозрачный оверлей поверх звёздного фона главного экрана.
    static let homeScreenFill = Color(.systemBackground)

    /// Обводка карточек и promo-блоков.
    static let border = Color.clear

    // MARK: - Program Card

    /// Название программы в заголовке карточки.
    static let programTitle = Color.primary

    /// Иконка-шеврон рядом с названием программы.
    static let programChevron = Color(.systemGray)

    // MARK: - Workout Progress

    /// Фон дорожки линейного прогресса.
    static let progressTrack = Color(.systemGray5)

    /// Заливка активного сегмента прогресса.
    static let progressFill = Color.primary

    /// Обводка заливки прогресса.
    static let progressFillStroke = Color.clear

    /// Вторичная заливка полоски прогресса в карточках статистики.
    static let progressFillSecondary = Color.primary

    /// Акцентная обводка активного шага.
    static let progressEmphasis = Color.primary

    /// Приглушённая обводка неактивных шагов.
    static let progressMuted = Color(.systemGray5)

    // MARK: - Progress Circles

    /// Фон завершённого шага.
    static let circleDone = Color.primary

    /// Галочка внутри завершённого шага.
    static let circleDoneMark = Color(.secondarySystemGroupedBackground)

    /// Кольцо вокруг завершённого шага.
    static let circleDoneRing = Color.clear

    /// Точка текущего активного шага.
    static let circleActiveDot = Color.primary

    /// Фон текущего активного шага.
    static let circleActiveBackground = Color(.secondarySystemGroupedBackground)

    /// Фон предстоящего шага.
    static let upcomingCircle = Color(.secondarySystemGroupedBackground)

    // MARK: - Buttons

    /// Текст на кнопке «Старт».
    static let buttonForeground = Color(.secondarySystemGroupedBackground)

    /// Фон кнопки «Старт».
    static let buttonBackground = Color.primary

    /// Обводка кнопки «Старт».
    static let buttonBorder = Color.primary

    // MARK: - Chips

    /// Текст выбранного чипа программы.
    static let chipForegroundSelected = Color(.secondarySystemGroupedBackground)

    /// Текст невыбранного чипа программы.
    static let chipForegroundResting = Color.primary

    /// Фон выбранного чипа программы.
    static let chipBackgroundSelected = Color.primary

    /// Фон невыбранного чипа программы.
    static let chipBackgroundResting = Color(.secondarySystemGroupedBackground)

    /// Обводка выбранного чипа программы.
    static let chipBorderSelected = Color.clear

    /// Обводка невыбранного чипа программы.
    static let chipBorderResting = Color.clear

    // MARK: - Next Level

    /// Фон полоски «До следующего уровня».
    static let promoBackground = Brand.bronz.opacity(0.03)

    /// Обводка полоски «До следующего уровня».
    static let promoBorder = Brand.bronz.opacity(0.3)

    /// Основной текст в блоке следующего уровня.
    static let nextLevelText = secondaryText

    /// Текст ранга («GERKULES») в блоке следующего уровня.
    static let rankLevelText = Brand.bronz

    // MARK: - Statistics

    /// Иконка в заголовке карточки статистики.
    static let statisticIcon = Brand.bronz

    /// Подпись секции и вспомогательный текст в карточках статистики.
    static let statisticText = Brand.bronz

    // MARK: - Level Badge

    /// Изображение венка вокруг номера уровня.
    static let levelWreath = Brand.bronz

    /// Римский номер уровня внутри венка.
    static let levelNumberText = Color.secondary

    // MARK: - Navigation & Indicators

    /// Неактивная точка червеобразного индикатора страниц.
    static let indicatorDot = Color(.systemGray3)

    /// Активная точка индикатора страниц.
    static let pageIndicatorActive = Color.primary

    /// Акцентный цвет элементов tab bar.
    static let tabBar = Brand.bronz

    // MARK: - Effects

    /// Тень карточек и поверхностей.
    static let shadow = UXShadowStyle(color: .black.opacity(0.2), radius: 6, x: 0, y: 0)

    /// Свечение карточки программы.
    static let cardGlow = Color.clear

    /// Свечение карточек статистики.
    static let statsGlow = Color.clear

    /// Свечение блока следующего уровня.
    static let nextLevelGlow = Color.clear

    /// Свечение выбранного чипа программы.
    static let selectedChipGlow = Color.clear
}

// MARK: - Brand Palette

/// Базовые фирменные цвета. Используются только внутри тем, не во views.
enum Brand {
    /// Бронзовый акцент бренда.
    static let bronz = Color(red: 158 / 255, green: 151 / 255, blue: 125 / 255)

    /// Основной мятный акцент.
    static let accent = Color.mint

    /// Вторичный индиго-акцент.
    static let secondAccent = Color.indigo

    /// Третичный жёлтый акцент.
    static let threeAccent = Color.yellow

    /// Фон дорожки прогресса в тёмной теме.
    static let progressTrackDark = Color(red: 19 / 255, green: 47 / 255, blue: 40 / 255)

    /// Фон кружков предстоящих шагов в тёмной теме.
    static let circleUpcomingDark = Color(red: 9 / 255, green: 26 / 255, blue: 22 / 255)

    /// Цвет неактивных точек индикатора в тёмной теме.
    static let dotDark = Color(red: 19 / 255, green: 47 / 255, blue: 40 / 255)
}
