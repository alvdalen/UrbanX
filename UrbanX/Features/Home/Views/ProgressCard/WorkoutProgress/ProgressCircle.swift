//
//  ProgressCircle.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 21.06.2026.
//

import SwiftUI

/// Один круг на дорожке пошагового прогресса: завершённый, текущий или будущий шаг.
struct ProgressCircle: View {
    // MARK: - Internal Properties
    /// Состояние шага: завершён, текущий или будущий.
    let state: CircleState

    // MARK: - Private Properties
    /// Включена ли анимация появления галочки или точки внутри круга.
    @State private var animated = false

    // MARK: - Body
    var body: some View {
        circleWithLifecycle
    }


    // MARK: - Круг с жизненным циклом

    /// Круг с подписками на смену `state` и начальное появление на экране.
    private var circleWithLifecycle: some View {
        circleContent
            .onChange(of: state) { _, newState in
                guard newState == .completed || newState == .current else { return }
                playAppearanceAnimation()
            }
            .onAppear {
                animated = state != .upcoming
            }
    }

    // MARK: - Состояния круга

    /// Внешний вид круга в зависимости от `state`.
    @ViewBuilder
    private var circleContent: some View {
        switch state {
        case .completed:
            completedCircle
        case .current:
            currentCircle
        case .upcoming:
            upcomingCircle
        } 
    }

    // MARK: - Завершённый шаг

    /// Завершённый шаг: зелёная заливка, анимированная галочка и кольцо.
    private var completedCircle: some View {
        Circle()
            .fill(UXColor.circleDone)
            .overlay {
                checkmark
            }
            .overlay {
                circleBorder
            }
    }

    /// Галочка внутри завершённого шага с анимацией появления.
    private var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.system(size: UXFontSize.iconSmall, weight: .bold))
            .foregroundStyle(UXColor.circleDoneMark)
            .scaleEffect(animated ? LocalConstants.visibleScale : LocalConstants.checkmarkHiddenScale)
            .opacity(animated ? LocalConstants.visibleOpacity : LocalConstants.hiddenOpacity)
    }

    /// Кольцо обводки вокруг завершённого шага.
    private var circleBorder: some View {
        Circle()
            .stroke(
                UXColor.circleDoneRing,
                lineWidth: LocalConstants.circleStrokeWidth
            )
    }

    // MARK: - Текущий шаг

    /// Текущий шаг: акцентная обводка и анимированная точка внутри.
    private var currentCircle: some View {
        ZStack {
            Circle()
                .fill(UXColor.circleActiveBackground)

            currentCircleBorder
            currentCircleDot
        }
    }

    /// Акцентная обводка текущего активного шага.
    private var currentCircleBorder: some View {
        Circle()
            .stroke(
                UXColor.progressEmphasis,
                lineWidth: LocalConstants.circleStrokeWidth
            )
    }

    /// Точка внутри текущего активного шага с анимацией появления.
    private var currentCircleDot: some View {
        Circle()
            .fill(UXColor.circleActiveDot)
            .frame(
                width: LocalConstants.activeDotSize,
                height: LocalConstants.activeDotSize
            )
            .scaleEffect(animated ? LocalConstants.visibleScale : LocalConstants.hiddenScale)
            .opacity(animated ? LocalConstants.visibleOpacity : LocalConstants.hiddenOpacity)
    }
    
    // MARK: - Будущий шаг

    /// Будущий шаг: нейтральный круг с приглушённой обводкой.
    private var upcomingCircle: some View {
        Circle()
            .fill(UXColor.upcomingCircleColor)
            .overlay {
                upcomingCircleBorder
            }
    }

    /// Приглушённая обводка будущего шага.
    private var upcomingCircleBorder: some View {
        Circle()
            .stroke(
                UXColor.progressMuted,
                lineWidth: LocalConstants.circleStrokeWidth
            )
    }
}

// MARK: - Private Methods
private extension ProgressCircle {
    /// Пружинная анимация появления галочки или точки после перехода в `.completed` / `.current`.
    func playAppearanceAnimation() {
        animated = false
        withAnimation(
            .spring(
                response: LocalConstants.springResponse,
                dampingFraction: LocalConstants.springDamping
            )
        ) {
            animated = true
        }
    }
}

// MARK: - Constants
private extension ProgressCircle {
    enum LocalConstants {
        /// Толщина кольца обводки вокруг круга шага.
        static let circleStrokeWidth: CGFloat = 2

        /// Диаметр точки внутри круга текущего (активного) шага.
        static let activeDotSize: CGFloat = 4

        /// Масштаб галочки до начала анимации появления на завершённом шаге.
        static let checkmarkHiddenScale: CGFloat = 0.2

        /// Скорость пружинной анимации появления галочки или точки (`spring(response:)`).
        static let springResponse: TimeInterval = 0.25

        /// Затухание пружинной анимации появления галочки или точки (`spring(dampingFraction:)`).
        static let springDamping: CGFloat = 0.65

        /// Масштаб галочки и точки после завершения анимации появления.
        static let visibleScale: CGFloat = 1

        /// Масштаб точки до начала анимации появления на текущем шаге.
        static let hiddenScale: CGFloat = 0

        /// Прозрачность галочки и точки после завершения анимации появления.
        static let visibleOpacity: Double = 1

        /// Прозрачность галочки и точки до начала анимации появления.
        static let hiddenOpacity: Double = 0
    }
}
