//
//  CarouselPageScrollTransition.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 21.06.2026.
//

import SwiftUI

extension View {
    // MARK: - Internal Methods

    /// Интерактивный `scrollTransition` для страницы карусели: масштаб уменьшается при горизонтальном свайпе.
    ///
    /// - Returns: view с `.scrollTransition(.interactive, axis: .horizontal)` и масштабированием по фазе прокрутки.
    func carouselPageScrollTransition() -> some View {
        scrollTransition(.interactive, axis: .horizontal) { content, phase in
            content.scaleEffect(CarouselPageScrollTransition.scale(for: phase))
        }
    }
}

// MARK: - Private Methods
private enum CarouselPageScrollTransition {
    /// Масштаб страницы карусели для фазы горизонтального `scrollTransition`.
    ///
    /// На месте (`phase.isIdentity`) — `carouselPageIdentityScale`.
    /// При свайпе линейно интерполирует к `carouselPageMinScale` по модулю `phase.value`.
    ///
    /// - Parameter phase: фаза интерактивного перехода страницы в карусели.
    ///
    /// - Returns: множитель `scaleEffect` для содержимого страницы.
    static func scale(for phase: ScrollTransitionPhase) -> CGFloat {
        guard !phase.isIdentity else {
            return HomeConstants.carouselPageIdentityScale
        }

        let progress = min(max(abs(phase.value), 0), 1)
        return interpolatedScale(progress: progress)
    }

    /// Линейная интерполяция между `carouselPageIdentityScale` и `carouselPageMinScale`.
    ///
    /// - Parameter progress: доля смещения страницы от 0 до 1.
    ///
    /// - Returns: множитель масштаба между полным размером и минимальным при свайпе.
    static func interpolatedScale(progress: CGFloat) -> CGFloat {
        let minScale = HomeConstants.carouselPageMinScale
        let identityScale = HomeConstants.carouselPageIdentityScale
        return identityScale + (minScale - identityScale) * progress
    }
}
