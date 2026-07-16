//
//  ActiveCircles.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 21.06.2026.
//

import SwiftUI

/// Ряд кругов (шагов) поверх дорожки пошагового прогресса в `WorkoutProgressBar`.
struct ActiveCircles: View, Animatable {
    // MARK: - Internal Properties
    /// Текущая доля заполнения дорожки (0…1).
    var progress: CGFloat

    /// Номер текущего шага (1…`stepCount`), для которого показывается активный круг.
    let currentCircle: Int

    /// Связка `progress` с протоколом `Animatable` для плавной анимации кружков.
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            progressCircles(in: geo)
        }
    }


    // MARK: - Ряд кругов шагов

    /// Ряд кругов шагов, равномерно распределённых по ширине дорожки.
    ///
    /// - Parameter geo: геометрия контейнера дорожки для расчёта позиций кругов.
    private func progressCircles(in geo: GeometryProxy) -> some View {
        ForEach(0..<LocalConstants.stepCount, id: \.self) { index in
            progressCircle(at: index, in: geo)
        }
    }

    /// Один круг шага: состояние, размер, пульсация соседей и позиция на дорожке.
    ///
    /// - Parameters:
    ///   - index: индекс шага на дорожке (0…`lastStepIndex`).
    ///   - geo: геометрия контейнера для перевода доли длины дорожки в координату `x`.
    private func progressCircle(at index: Int, in geo: GeometryProxy) -> some View {
        let position = circlePosition(at: index)
        let scale = circleScale(at: index, position: position)

        return ProgressCircle(
            state: circleState(at: index, position: position)
        )
        .frame(width: LocalConstants.circleSize, height: LocalConstants.circleSize)
        .scaleEffect(index + 1 == currentCircle ? LocalConstants.activeCircleScale : scale)
        .position(
            x: geo.size.width * position,
            y: geo.size.height / 2
        )
    }
}

// MARK: - Private Methods
private extension ActiveCircles {
    /// Доля длины дорожки (0…1), на которой стоит круг с индексом `index`.
    ///
    /// - Parameter index: индекс шага (0…`lastStepIndex`).
    ///
    /// - Returns: горизонтальная позиция круга как доля ширины дорожки.
    func circlePosition(at index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(LocalConstants.lastStepIndex)
    }

    /// Масштаб круга от пульсации вокруг текущего шага на дорожке.
    ///
    /// - Parameters:
    ///   - index: индекс шага (0…`lastStepIndex`).
    ///   - position: доля длины дорожки (0…1), где стоит этот круг.
    ///
    /// - Returns: множитель масштаба от 1 до 1 + `pulseScaleBoost` в зависимости от близости к `progress`.
    func circleScale(at index: Int, position: CGFloat) -> CGFloat {
        let distance = abs(progress - position)
        let pulse = max(0, 1 - distance / LocalConstants.pulseWidth)
        return LocalConstants.activeCircleScale + pulse * LocalConstants.pulseScaleBoost
    }

    /// Состояние шага для круга на позиции `position`: пройден, текущий или предстоящий.
    ///
    /// - Parameters:
    ///   - index: индекс шага (0…`lastStepIndex`).
    ///   - position: доля длины дорожки (0…1), где стоит этот круг.
    ///
    /// - Returns: значение для отрисовки в `ProgressCircle`.
    func circleState(at index: Int, position: CGFloat) -> CircleState {
        if progress >= position {
            return index + 1 == currentCircle ? .current : .completed
        }
        return .upcoming
    }
}

// MARK: - Constants
private extension ActiveCircles {
    enum LocalConstants {
        /// Сколько кругов на дорожке (должно совпадать с `WorkoutProgressBar.stepCount`).
        static let stepCount: Int = 6

        /// Диаметр одного круга шага на дорожке прогресса.
        static let circleSize: CGFloat = 20

        /// Ширина зоны пульсации вокруг текущего шага — доля длины дорожки от 0 до 1.
        static let pulseWidth: CGFloat = 0.06

        /// Насколько увеличиваются соседние круги при пульсации текущего шага (масштаб).
        static let pulseScaleBoost: CGFloat = 0.25

        /// Номер последнего круга на дорожке (шаги считаются с нуля).
        static var lastStepIndex: Int { stepCount - 1 }

        /// Масштаб текущего (активного) круга без пульсации соседей.
        static let activeCircleScale: CGFloat = 1
    }
}
