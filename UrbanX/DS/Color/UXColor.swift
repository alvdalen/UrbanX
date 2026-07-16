//
//  UXColor.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Семантические цвета интерфейса. Единственная точка доступа к палитре из views.
enum UXColor {

    // MARK: - Text

    /// Основной текст интерфейса.
    static let primary = UXAdaptiveColor(light: LightTheme.primary, dark: DarkTheme.primary)

    /// Вторичный текст: подписи, вспомогательные строки.
    static let secondary = UXAdaptiveColor(light: LightTheme.secondary, dark: DarkTheme.secondary)

    /// Вторичный текст в promo-блоках и карточках статистики.
    static let secondaryTextColor = UXAdaptiveColor(light: LightTheme.secondaryText, dark: DarkTheme.secondaryText)

    // MARK: - Surfaces & Backgrounds

    /// Фон карточек и вложенных блоков.
    static let cardColor = UXAdaptiveColor(light: LightTheme.cardColor, dark: DarkTheme.cardColor)

    /// Полупрозрачный оверлей поверх звёздного фона главного экрана.
    static let homeScreenFill = UXAdaptiveColor(light: LightTheme.homeScreenFill, dark: DarkTheme.homeScreenFill)

    /// Обводка карточек и promo-блоков.
    static let border = UXAdaptiveColor(light: LightTheme.border, dark: DarkTheme.border)

    // MARK: - Program Card

    /// Название программы в заголовке карточки.
    static let programTitleColor = UXAdaptiveColor(light: LightTheme.programTitle, dark: DarkTheme.programTitle)

    /// Иконка-шеврон рядом с названием программы.
    static let programChevron = UXAdaptiveColor(light: LightTheme.programChevron, dark: DarkTheme.programChevron)

    // MARK: - Workout Progress

    /// Фон дорожки линейного прогресса.
    static let progressTrack = UXAdaptiveColor(light: LightTheme.progressTrack, dark: DarkTheme.progressTrack)

    /// Заливка активного сегмента прогресса.
    static let progressFill = UXAdaptiveColor(light: LightTheme.progressFill, dark: DarkTheme.progressFill)

    /// Обводка заливки прогресса.
    static let progressFillStroke = UXAdaptiveColor(light: LightTheme.progressFillStroke, dark: DarkTheme.progressFillStroke)

    /// Вторичная заливка полоски прогресса в карточках статистики.
    static let progressFillSecondary = UXAdaptiveColor(light: LightTheme.progressFillSecondary, dark: DarkTheme.progressFillSecondary)

    /// Акцентная обводка активного шага.
    static let progressEmphasis = UXAdaptiveColor(light: LightTheme.progressEmphasis, dark: DarkTheme.progressEmphasis)

    /// Приглушённая обводка неактивных шагов.
    static let progressMuted = UXAdaptiveColor(light: LightTheme.progressMuted, dark: DarkTheme.progressMuted)

    // MARK: - Progress Circles

    /// Фон завершённого шага.
    static let circleDone = UXAdaptiveColor(light: LightTheme.circleDone, dark: DarkTheme.circleDone)

    /// Галочка внутри завершённого шага.
    static let circleDoneMark = UXAdaptiveColor(light: LightTheme.circleDoneMark, dark: DarkTheme.circleDoneMark)

    /// Кольцо вокруг завершённого шага.
    static let circleDoneRing = UXAdaptiveColor(light: LightTheme.circleDoneRing, dark: DarkTheme.circleDoneRing)

    /// Точка текущего активного шага.
    static let circleActiveDot = UXAdaptiveColor(light: LightTheme.circleActiveDot, dark: DarkTheme.circleActiveDot)

    /// Фон текущего активного шага.
    static let circleActiveBackground = UXAdaptiveColor(light: LightTheme.circleActiveBackground, dark: DarkTheme.circleActiveBackground)

    /// Фон предстоящего шага.
    static let upcomingCircleColor = UXAdaptiveColor(light: LightTheme.upcomingCircle, dark: DarkTheme.upcomingCircle)

    // MARK: - Buttons

    /// Текст на кнопке «Старт».
    static let buttonForeground = UXAdaptiveColor(light: LightTheme.buttonForeground, dark: DarkTheme.buttonForeground)

    /// Фон кнопки «Старт».
    static let buttonBackground = UXAdaptiveColor(light: LightTheme.buttonBackground, dark: DarkTheme.buttonBackground)

    /// Обводка кнопки «Старт».
    static let buttonBorder = UXAdaptiveColor(light: LightTheme.buttonBorder, dark: DarkTheme.buttonBorder)

    // MARK: - Chips

    /// Точка разделитель.
    static let chipDotSeparator = UXAdaptiveColor(light: LightTheme.primary, dark: DarkTheme.chipDot)
    
    /// Текст выбранного чипа программы.
    static let chipForegroundSelected = UXAdaptiveColor(light: LightTheme.chipForegroundSelected, dark: DarkTheme.chipForegroundSelected)

    /// Текст невыбранного чипа программы.
    static let chipForegroundResting = UXAdaptiveColor(light: LightTheme.chipForegroundResting, dark: DarkTheme.chipForegroundResting)

    /// Фон выбранного чипа программы.
    static let chipBackgroundSelected = UXAdaptiveColor(light: LightTheme.chipBackgroundSelected, dark: DarkTheme.chipBackgroundSelected)

    /// Фон невыбранного чипа программы.
    static let chipBackgroundResting = UXAdaptiveColor(light: LightTheme.chipBackgroundResting, dark: DarkTheme.chipBackgroundResting)

    /// Обводка выбранного чипа программы.
    static let chipBorderSelected = UXAdaptiveColor(light: LightTheme.chipBorderSelected, dark: DarkTheme.chipBorderSelected)

    /// Обводка невыбранного чипа программы.
    static let chipBorderResting = UXAdaptiveColor(light: LightTheme.chipBorderResting, dark: DarkTheme.chipBorderResting)

    /// Обводка чипа программы в зависимости от состояния выбора.
    ///
    /// - Parameter isSelected: выбран ли чип в ряду программ.
    ///
    /// - Returns: цвет обводки выбранного или невыбранного чипа.
    static func chipBorder(isSelected: Bool) -> UXAdaptiveColor {
        isSelected ? chipBorderSelected : chipBorderResting
    }

    /// Текст чипа программы в зависимости от состояния выбора.
    ///
    /// - Parameter isSelected: выбран ли чип в ряду программ.
    ///
    /// - Returns: цвет текста выбранного или невыбранного чипа.
    static func chipForeground(isSelected: Bool) -> UXAdaptiveColor {
        isSelected ? chipForegroundSelected : chipForegroundResting
    }

    /// Фон чипа программы в зависимости от состояния выбора.
    ///
    /// - Parameter isSelected: выбран ли чип в ряду программ.
    ///
    /// - Returns: цвет фона выбранного или невыбранного чипа.
    static func chipBackground(isSelected: Bool) -> UXAdaptiveColor {
        isSelected ? chipBackgroundSelected : chipBackgroundResting
    }

    // MARK: - Next Level

    /// Фон полоски «До следующего уровня».
    static let promoBackground = UXAdaptiveColor(light: LightTheme.promoBackground, dark: DarkTheme.promoBackground)

    /// Обводка полоски «До следующего уровня».
    static let promoBorder = UXAdaptiveColor(light: LightTheme.promoBorder, dark: DarkTheme.promoBorder)

    /// Основной текст в блоке следующего уровня.
    static let nextLevelTextColor = UXAdaptiveColor(light: LightTheme.nextLevelText, dark: DarkTheme.nextLevelText)
    
    /// Текст с количеством подходов.
    static let repsTextColor = UXAdaptiveColor(light: LightTheme.secondaryText, dark: DarkTheme.secondaryText)

    /// Текст ранга («GERKULES») в блоке следующего уровня.
    static let rankTextColor = UXAdaptiveColor(light: LightTheme.rankLevelText, dark: DarkTheme.rankLevelText)

    // MARK: - Statistics

    /// Иконка в заголовке карточки статистики.
    static let statisticIconColor = UXAdaptiveColor(light: LightTheme.statisticIcon, dark: DarkTheme.statisticIcon)

    /// Подпись секции и вспомогательный текст в карточках статистики.
    static let statisticTextColor = UXAdaptiveColor(light: LightTheme.statisticText, dark: DarkTheme.statisticText)

    // MARK: - Level Badge

    /// Изображение венка вокруг номера уровня.
    static let levelWreath = UXAdaptiveColor(light: LightTheme.levelWreath, dark: DarkTheme.levelWreath)

    /// Римский номер уровня внутри венка.
    static let levelNumberText = UXAdaptiveColor(light: LightTheme.levelNumberText, dark: DarkTheme.levelNumberText)

    // MARK: - Navigation & Indicators

    /// Неактивная точка червеобразного индикатора страниц.
    static let indicatorDot = UXAdaptiveColor(light: LightTheme.indicatorDot, dark: DarkTheme.indicatorDot)

    /// Активная точка индикатора страниц.
    static let pageIndicatorActive = UXAdaptiveColor(light: LightTheme.pageIndicatorActive, dark: DarkTheme.pageIndicatorActive)

    /// Акцентный цвет элементов tab bar.
    static let tabBarTint = UXAdaptiveColor(light: LightTheme.tabBar, dark: DarkTheme.tabBar)

    // MARK: - Glow

    /// Свечение карточки программы.
    static let cardGlow = UXAdaptiveColor(light: LightTheme.cardGlow, dark: DarkTheme.cardGlow)

    /// Свечение карточек статистики.
    static let statsGlow = UXAdaptiveColor(light: LightTheme.statsGlow, dark: DarkTheme.statsGlow)

    /// Свечение блока следующего уровня.
    static let nextLevelGlow = UXAdaptiveColor(light: LightTheme.nextLevelGlow, dark: DarkTheme.nextLevelGlow)

    /// Свечение выбранного чипа программы.
    static let selectedChipGlow = UXAdaptiveColor(light: LightTheme.selectedChipGlow, dark: DarkTheme.selectedChipGlow)
}
