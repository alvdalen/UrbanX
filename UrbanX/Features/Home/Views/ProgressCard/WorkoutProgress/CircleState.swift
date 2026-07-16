//
//  CircleState.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 21.06.2026.
//

/// Состояние круга шага на дорожке пошагового прогресса в `ProgressCircle` и `ActiveCircles`.
enum CircleState {
    /// Шаг уже пройден — заливка с галочкой и кольцом завершения.
    case completed

    /// Текущий активный шаг — обводка акцентного цвета и точка внутри.
    case current

    /// Будущий шаг — нейтральный круг с приглушённой обводкой.
    case upcoming
}
