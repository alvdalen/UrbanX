//
//  HapticFeedback.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 05.07.2026.
//

import UIKit

/// Подготовленные генераторы haptic — без cold-start `.sensoryFeedback` при первом запуске.
enum HapticFeedback {
    private static let pageChangeGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let pinGenerator = UIImpactFeedbackGenerator(style: .rigid)

    /// Прогревает Taptic Engine; вызывать при старте приложения.
    static func warmUp() {
        pageChangeGenerator.prepare()
        pinGenerator.prepare()
    }

    /// Haptic смены страницы карусели.
    static func playPageChange() {
        pageChangeGenerator.impactOccurred(intensity: 1.0)
    }

    /// Haptic закрепления / открепления чипа.
    static func playPin() {
        pinGenerator.impactOccurred(intensity: 1.0)
    }
}
