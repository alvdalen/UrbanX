//
//  HomeConstants.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 20.06.2026.
//

import Foundation

/// Общие константы главного экрана.
enum HomeConstants {

    /// Длительность анимации перестановки чипа при закреплении/откреплении.
    static let pinAnimationDuration: TimeInterval = 0.3

    /// Задержка перед снятием запаса ширины под иконку pin после открепления.
    static var pinReorderDuration: Duration { .seconds(0) }

    /// Масштаб страницы карусели на месте.
    static let carouselPageIdentityScale: CGFloat = 1

    /// Масштаб страницы карусели при свайпе (до полного размера).
    static let carouselPageMinScale: CGFloat = 0.9

    /// Длительность прокрутки карусели по тапу на чип.
    static let carouselScrollAnimationDuration: TimeInterval = 0.45
}
