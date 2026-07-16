//
//  WorkoutProgressBar.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 21.06.2026.
//

import SwiftUI

/// Дорожка с кружками шагов в карточке прогресса программы.
struct WorkoutProgressBar: View {
    // MARK: - Internal Properties
    /// Номер последнего пройденного шага (1…`stepCount`) — определяет целевую долю заполнения дорожки.
    let lastCircle: Int

    /// Выбрана ли в карусели страница с этой дорожкой.
    let isSelected: Bool

    /// Можно ли запускать анимацию (например, после готовности карусели).
    let canAnimate: Bool

    /// Проигрывалась ли анимация заполнения для этой страницы в текущем запуске приложения.
    let hasAnimatedBefore: Bool

    /// Вызывается по завершении анимации заполнения дорожки.
    let onAnimationPlayed: () -> Void

    // MARK: - Private Properties
    /// Текущая доля заполнения дорожки (0…1) во время анимации.
    @State private var progress: CGFloat = .zero

    /// Защита от повторного запуска анимации, пока предыдущая не завершилась.
    @State private var isAnimating = false

    /// Доля заполнения на экране: сразу `target`, если анимация уже была, иначе `progress`.
    ///
    /// Уже анимированные страницы рисуем по `lastCircle`, а не по `@State` —
    /// иначе при смене карточки на том же индексе карусели мелькает чужой прогресс.
    private var displayedProgress: CGFloat {
        hasAnimatedBefore ? target : progress
    }

    /// Целевая доля заполнения дорожки (0…1) по `lastCircle`.
    private var target: CGFloat {
        Self.targetProgress(for: lastCircle)
    }

    // MARK: - Body
    var body: some View {
        progressBarWithLifecycle
    }


    // MARK: - Дорожка с жизненным циклом

    /// Дорожка с подписками на выбор страницы, готовность анимации и первое появление.
    private var progressBarWithLifecycle: some View {
        progressBar
            .onChange(of: isSelected) { _, isNowSelected in
                if isNowSelected {
                    scheduleAnimationAfterDisplay()
                }
            }
            .onChange(of: canAnimate) { _, isReady in
                if isReady, isSelected {
                    scheduleAnimationAfterDisplay()
                }
            }
            .onAppear {
                if hasAnimatedBefore {
                    applyFinalProgressIfNeeded()
                } else if isSelected, canAnimate {
                    scheduleAnimationAfterDisplay()
                }
            }
    }

    // MARK: - Визуальные слои дорожки

    /// Дорожка прогресса фиксированной высоты с полоской и кружками шагов.
    private var progressBar: some View {
        progressBarContent
            .frame(height: LocalConstants.barHeight)
    }

    /// Серая дорожка, заливка и кружки; обводка — overlay, не влияет на layout.
    private var progressBarContent: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                trackCapsule
                fillCapsule(width: geo.size.width * displayedProgress)
                stepCircles
            }
            .overlay {
                filledOutline()
            }
        }
    }

    /// Серая фоновая полоска дорожки под кружками.
    private var trackCapsule: some View {
        Capsule()
            .fill(UXColor.progressTrack)
            .frame(height: LocalConstants.trackHeight)
    }

    /// Цветная заливка прогресса поверх дорожки.
    ///
    /// - Parameter width: ширина заливки в pt.
    private func fillCapsule(width: CGFloat) -> some View {
        Capsule()
            .fill(UXColor.progressFill)
            .frame(width: width)
            .frame(height: LocalConstants.trackHeight)
    }

    /// Жёлтый контур заполненного силуэта (только тёмная тема).
    @ViewBuilder
    private func filledOutline() -> some View {
        UXTheme.Reader { mode in
            if mode == .dark {
                let strokeColor = UXColor.progressFillStroke.resolved(for: mode.colorScheme)
                let bleed = ProgressFillOutline.overlayBleed(lineWidth: LocalConstants.fillStrokeWidth)
                ProgressFillOutline(
                    progress: displayedProgress,
                    currentCircle: lastCircle,
                    lineWidth: LocalConstants.fillStrokeWidth,
                    trackHeight: LocalConstants.trackHeight,
                    color: strokeColor,
                    glowColor: strokeColor
                )
                .padding(-bleed)
            }
        }
    }

    /// Кружки шагов, синхронизированные с долей заполнения дорожки.
    private var stepCircles: some View {
        ActiveCircles(
            progress: displayedProgress,
            currentCircle: lastCircle
        )
    }
}

// MARK: - Private Methods
private extension WorkoutProgressBar {
    /// Целевая доля заполнения (0…1) для номера последнего шага `lastCircle`.
    ///
    /// - Parameter lastCircle: номер шага (1…`stepCount`), ограничивается допустимым диапазоном.
    ///
    /// - Returns: горизонтальная доля дорожки, до которой доходит заливка.
    static func targetProgress(for lastCircle: Int) -> CGFloat {
        let clamped = min(max(lastCircle, 1), LocalConstants.stepCount)
        return CGFloat(clamped - 1) / CGFloat(LocalConstants.lastStepIndex)
    }

    /// Мгновенно выставляет `progress` в `target` без анимации, если значения расходятся.
    func applyFinalProgressIfNeeded() {
        guard progress != target else { return }
        setProgressWithoutAnimation(target)
    }

    /// Планирует запуск или мгновенное применение прогресса при появлении или выборе карточки.
    func scheduleAnimationAfterDisplay() {
        guard isSelected, canAnimate else { return }

        if hasAnimatedBefore {
            applyFinalProgressIfNeeded()
            return
        }

        guard !isAnimating else { return }

        animateProgress()
    }

    /// Сбрасывает заливку в ноль и линейно анимирует её до `target`.
    func animateProgress() {
        let target = self.target
        let duration = animationDuration(for: target)

        isAnimating = true
        setProgressWithoutAnimation(.zero)

        guard isSelected, canAnimate else {
            isAnimating = false
            return
        }

        runProgressFillAnimation(to: target, duration: duration)
    }

    /// Длительность анимации пропорциональна целевой доле заполнения.
    ///
    /// - Parameter target: целевая доля дорожки (0…1).
    ///
    /// - Returns: длительность линейной анимации в секундах.
    func animationDuration(for target: CGFloat) -> TimeInterval {
        max(
            TimeInterval(target) * LocalConstants.fullAnimationDuration,
            LocalConstants.minimumAnimationDuration
        )
    }

    /// Линейно анимирует заливку до `target`, снимает `isAnimating` и вызывает `onAnimationPlayed`.
    ///
    /// - Parameters:
    ///   - target: целевая доля заполнения дорожки (0…1).
    ///   - duration: длительность анимации в секундах.
    func runProgressFillAnimation(to target: CGFloat, duration: TimeInterval) {
        withAnimation(.linear(duration: duration)) {
            progress = target
        } completion: {
            isAnimating = false
            onAnimationPlayed()
        }
    }

    /// Обновляет `progress` без системной анимации SwiftUI.
    ///
    /// - Parameter value: новая доля заполнения дорожки (0…1).
    func setProgressWithoutAnimation(_ value: CGFloat) {
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            progress = value
        }
    }
}

// MARK: - Constants
private extension WorkoutProgressBar {
    enum LocalConstants {
        /// Сколько кругов-шагов на дорожке (должно совпадать с `ActiveCircles.stepCount`).
        static let stepCount: Int = 6

        /// Высота серой полоски дорожки под кружками.
        static let trackHeight: CGFloat = 6

        /// Толщина жёлтой обводки заполненной части дорожки (только тёмная тема).
        static let fillStrokeWidth: CGFloat = 0.2

        /// Общая высота зоны дорожки вместе с кружками над/под полоской.
        static let barHeight: CGFloat = 30

        /// Сколько секунд длится полная анимация заполнения дорожки от 0% до 100%.
        static let fullAnimationDuration: TimeInterval = 1.7

        /// Минимальная длительность анимации, если прогресс уже больше нуля при старте.
        static let minimumAnimationDuration: TimeInterval = 0.01

        /// Номер последнего шага на дорожке (шаги считаются с нуля: 0…5 при `stepCount = 6`).
        static var lastStepIndex: Int { stepCount - 1 }
    }
}
