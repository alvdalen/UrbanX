//
//  IndicatorDot.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 28.06.2026.
//

import SwiftUI

/// Одна точка индикатора с независимой анимацией прозрачности.
///
/// Вынесена в отдельный `View`, чтобы хранить собственный `@State` на каждую точку —
/// иначе точка не может начать исчезать раньше, чем активная метка тронется с места.
struct IndicatorDot: View {
    // MARK: - Internal Properties
    /// Является ли точка целью движения активной метки индикатора.
    /// При `true` запускает анимацию исчезновения, при `false` — появления.
    let isActive: Bool
    
    /// Диаметр неактивной серой точки индикатора карусели.
    let size: CGFloat
    
    /// Сколько секунд точка-назначение исчезает перед началом движения активной метки.
    let disappearDuration: Double
    
    /// Сколько секунд неактивная точка появляется обратно после ухода активной метки.
    let appearDuration: Double
    
    // MARK: - Private Properties
    /// Текущая прозрачность точки (0…1); меняется только через `withAnimation`.
    @State private var opacity: Double = LocalConstants.visibleOpacity
    
    // MARK: - Body
    var body: some View {
        dotWithLifecycle
    }
    

    // MARK: - Точка с жизненным циклом

    /// Круг точки с начальной прозрачностью и анимацией при смене `isActive`.
    ///
    /// При первом появлении точка под активной меткой сразу невидима (`opacity = 0`),
    /// остальные полностью видимы (`opacity = 1`).
    /// При `isActive == true` точка исчезает — метка едет к этой позиции;
    /// при `false` — появляется обратно.
    private var dotWithLifecycle: some View {
        dot
            .onAppear {
                updateOpacity(animated: false)
            }
            .onChange(of: isActive) { _, _ in
                updateOpacity(animated: true)
            }
    }

    // MARK: - Визуальное представление точки

    /// Визуальное представление точки индикатора.
    private var dot: some View {
        Circle()
            .fill(UXColor.indicatorDot)
            .frame(width: size, height: size)
            .opacity(opacity)
    }
}

private extension IndicatorDot {
    /// Устанавливает прозрачность точки с анимацией или мгновенно при появлении.
    ///
    /// - Parameter animated: `false` — без `withAnimation`, для `onAppear`.
    func updateOpacity(animated: Bool) {
        let value = isActive ? LocalConstants.hiddenOpacity : LocalConstants.visibleOpacity

        guard animated else {
            opacity = value
            return
        }

        animateOpacity(to: value)
    }

    /// Анимирует переход прозрачности точки к целевому значению.
    ///
    /// - Parameter value: целевая прозрачность (0…1).
    func animateOpacity(to value: Double) {
        withAnimation(opacityAnimation) {
            opacity = value
        }
    }

    /// Длительность исчезновения или появления точки в зависимости от `isActive`.
    var opacityAnimation: Animation {
        .easeOut(
            duration: isActive
                ? disappearDuration
                : appearDuration
        )
    }
}

// MARK: - Constants
private extension IndicatorDot {
    enum LocalConstants {
        /// Прозрачность неактивной точки индикатора.
        static let visibleOpacity: Double = 1

        /// Прозрачность точки-назначения, пока к ней едет активная метка.
        static let hiddenOpacity: Double = 0
    }
}
