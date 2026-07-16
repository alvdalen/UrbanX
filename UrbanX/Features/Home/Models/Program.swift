//
//  Program.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import Foundation

/// Модель тренировочной программы на главном экране: чип, карточка прогресса и статистика.
struct Program: Identifiable, Equatable {
    /// Уникальный идентификатор программы.
    let id = UUID()

    /// Короткое название для чипа в горизонтальном ряду.
    let chip: String

    /// Полное название в заголовке карточки прогресса.
    let cardTitle: String

    /// Номер последнего пройденного шага (1…`stepCount`) на дорожке прогресса.
    let currentStep: Int

    /// Целевая доля заполнения месячной полоски прогресса (0…1).
    let progress: Double

    /// Текст процента прогресса в правой карточке статистики (например «72%»).
    let percentText: String
}
