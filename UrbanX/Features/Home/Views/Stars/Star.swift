//
//  Star.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 12.07.2026.
//

import Foundation

/// Одна звезда на фоне главного экрана: нормализованные координаты, размер и прозрачность.
struct Star: Identifiable {
    /// Уникальный идентификатор звезды в массиве `StarFieldBackground`.
    let id = UUID()

    /// Горизонтальная позиция от 0 до 1 относительно ширины canvas.
    let x: CGFloat

    /// Вертикальная позиция от 0 до 1 относительно высоты canvas.
    let y: CGFloat

    /// Диаметр звезды в pt при отрисовке на canvas.
    let size: CGFloat

    /// Базовая прозрачность звезды (0…1) до мерцания.
    let opacity: Double

    /// Фазовый сдвиг мерцания (радианы) — чтобы звёзды не синхронизировались.
    let twinklePhase: Double

    /// Скорость мерцания (рад/с): больше — быстрее мигает.
    let twinkleSpeed: Double

    /// Глубина мерцания (0…1): доля базовой opacity, на которую звезда тускнеет.
    let twinkleDepth: Double
}
