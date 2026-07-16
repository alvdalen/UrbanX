//
//  SeededGenerator.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 12.07.2026.
//

import SwiftUI

/// Детерминированный генератор псевдослучайных чисел для стабильного расположения звёзд.
struct SeededGenerator: RandomNumberGenerator {
    /// Внутреннее состояние LCG-генератора.
    private var state: UInt64

    /// Создаёт генератор с фиксированным seed.
    ///
    /// - Parameter seed: начальное значение состояния генератора.
    init(seed: UInt64) { state = seed }

    /// Возвращает следующее псевдослучайное 64-битное число.
    ///
    /// - Returns: следующее значение последовательности LCG.
    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}
