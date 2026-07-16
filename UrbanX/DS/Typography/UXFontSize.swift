//
//  UXFontSize.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import CoreGraphics

// MARK: - UXFontSize
/// Etalon pt для текстовых стилей (iPhone 17 Pro).
enum UXFontSize {
    /// Бронзовая подпись секции, uppercase.
    static let eyebrow: CGFloat = 11
    
    /// Раздел статистики.
    static let statistic: CGFloat = 11

    /// Крупное значение в карточках.
    static let title: CGFloat = 21
    
    /// Крупное значение в карточках статистики.
    static let statisticsCount: CGFloat = 21

    /// Вторичный текст среднего размера.
    static let bodySmall: CGFloat = 11

    /// Подписи и вторичный текст.
    static let caption: CGFloat = 11
    
    static let chipSize: CGFloat = 14

    /// Кнопка «Старт» и другой фиксированный акцентный текст.
    static let label: CGFloat = 16

    /// Номер уровня в венке (Times New Roman, uppercase).
    static let display: CGFloat = 12

    /// Галочка в завершённом шаге прогресса (фиксированный pt).
    static let iconSmall: CGFloat = 9

    /// SF Symbol в adaptive-блоках (через `.uxIconFont`).
    static let iconMedium: CGFloat = 15
    
    static let iconLarge: CGFloat = 19
}

// MARK: - UXIconSize
/// Пресет SF Symbol для `.uxIconFont`. Etalon pt — в `UXFontSize`.
enum UXIconSize {
    /// 16 pt etalon — иконка-шеврон в заголовке карточки программы и т.п.
    case medium
    
    case large
}
