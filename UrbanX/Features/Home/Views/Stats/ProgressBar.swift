//
//  ProgressBar.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 29.06.2026.
//

import SwiftUI

/// Горизонтальная полоска заполнения в правой карточке «Прогресс июня»,
/// под строкой «18 из 25 тренировок» в `StatsView`.
struct ProgressBar: View {
    // MARK: - Internal Properties
    /// Целевая доля заполнения полоски (0…1) по данным программы.
    let progress: Double

    /// Выбрана ли в карусели страница с этой полоской — анимация стартует только для активной карточки.
    let isSelected: Bool

    /// Проигрывалась ли анимация заполнения для этой страницы в текущем запуске приложения.
    let hasAnimatedBefore: Bool

    /// Можно ли запускать анимацию (например, после готовности карусели).
    let canAnimate: Bool

    // MARK: - Private Properties
    /// Текущее значение заполнения во время анимации.
    @State private var currentProgress: Double = 0

    /// Защита от повторного запуска анимации, пока предыдущая не завершилась.
    @State private var isAnimating = false

    /// Доля заполнения, которую рисуем на экране: сразу `progress`, если анимация уже была, иначе `currentProgress`.
    private var displayedProgress: Double {
        hasAnimatedBefore ? progress : currentProgress
    }

    // MARK: - Body
    var body: some View {
        progressBarWithLifecycle
    }


    // MARK: - Полоска с жизненным циклом

    /// Полоска с подписками на выбор страницы, готовность анимации и первое появление.
    private var progressBarWithLifecycle: some View {
        progressBar
            .onChange(of: isSelected) { _, isNowSelected in
                handleSelectionChange(isNowSelected)
            }
            .onChange(of: canAnimate) { _, isReady in
                handleAnimationReadinessChange(isReady)
            }
            .onAppear {
                handleAppear()
            }
    }

    // MARK: - Визуальные слои полоски

    /// Полоска прогресса фиксированной высоты.
    private var progressBar: some View {
        progressBarContent
            .uxFrame(height: LocalConstants.barHeight, large: LocalConstants.barHeightLargeScale)
    }

    /// Дорожка и заливка; ширина заливки считается от доступной ширины контейнера.
    private var progressBarContent: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                trackCapsule
                fillCapsule(width: proxy.size.width * displayedProgress)
            }
        }
    }

    /// Серая фоновая дорожка под цветной заливкой.
    private var trackCapsule: some View {
        Capsule()
            .fill(UXColor.progressTrack)
    }

    /// Цветная заливка поверх дорожки.
    ///
    /// - Parameter width: ширина заливки в поинтах.
    private func fillCapsule(width: CGFloat) -> some View {
        Capsule()
            .fill(UXColor.progressFillSecondary)
            .frame(width: width)
    }
}

// MARK: - Private Methods
private extension ProgressBar {
    /// Реагирует на выбор страницы карусели: планирует анимацию, если карточка стала активной.
    ///
    /// - Parameter isSelected: выбрана ли страница с этой полоской.
    func handleSelectionChange(_ isSelected: Bool) {
        guard isSelected else { return }
        scheduleAnimationAfterDisplay()
    }

    /// Реагирует на готовность анимации карусели: запускает заполнение для выбранной карточки.
    ///
    /// - Parameter isReady: можно ли запускать анимацию прогресса.
    func handleAnimationReadinessChange(_ isReady: Bool) {
        guard isReady, isSelected else { return }
        scheduleAnimationAfterDisplay()
    }

    /// При появлении сразу выставляет финальный прогресс или планирует анимацию.
    func handleAppear() {
        if hasAnimatedBefore {
            applyFinalProgressIfNeeded()
        } else if isSelected, canAnimate {
            scheduleAnimationAfterDisplay()
        }
    }

    /// Мгновенно выставляет `currentProgress` в `progress` без анимации, если значения расходятся.
    func applyFinalProgressIfNeeded() {
        guard currentProgress != progress else { return }
        setCurrentProgressWithoutAnimation(progress)
    }

    /// Планирует запуск или мгновенное применение прогресса при появлении или выборе карточки.
    func scheduleAnimationAfterDisplay() {
        guard isSelected, canAnimate else { return }

        if hasAnimatedBefore {
            applyFinalProgressIfNeeded()
            return
        }

        guard !isAnimating else { return }

        animateProgressBar()
    }

    /// Сбрасывает заливку в ноль и линейно анимирует её до `progress`.
    func animateProgressBar() {
        isAnimating = true
        setCurrentProgressWithoutAnimation(.zero)

        guard isSelected, canAnimate else {
            isAnimating = false
            return
        }

        runProgressFillAnimation()
    }

    /// Линейно анимирует заливку до целевого `progress` и снимает флаг `isAnimating` по завершении.
    func runProgressFillAnimation() {
        withAnimation(.linear(duration: LocalConstants.animationDuration)) {
            currentProgress = progress
        } completion: {
            isAnimating = false
        }
    }

    /// Обновляет `currentProgress` без системной анимации SwiftUI.
    ///
    /// - Parameter value: новая доля заполнения (0…1).
    func setCurrentProgressWithoutAnimation(_ value: Double) {
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            currentProgress = value
        }
    }
}

// MARK: - Constants
private extension ProgressBar {
    enum LocalConstants {
        /// Высота серой дорожки и цветной заливки линейного прогресса.
        static let barHeight: CGFloat = 8

        /// Множитель высоты полоски прогресса на больших экранах (`uxFrame`).
        static let barHeightLargeScale: CGFloat = 1.1

        /// Сколько секунд длится анимация заполнения полоски при появлении карточки.
        static let animationDuration: TimeInterval = 0.8
    }
}
