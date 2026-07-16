//
//  SurfaceOutlineGlow.swift
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Контурное свечение вокруг скруглённого прямоугольника — несколько колец с плавным спадом.
struct SurfaceOutlineGlow: View {
    /// Радиус скругления контура, вокруг которого строится свечение.
    let cornerRadius: CGFloat

    /// Адаптивный цвет свечения — разрешается по теме в `body`.
    let color: UXAdaptiveColor

    /// Пресет колец `(spread, opacity, blur)` из `UXGlow`.
    let layers: [UXGlow.Layer]

    /// Максимальный вынос свечения за контур — для отрицательного `padding` оверлея.
    ///
    /// - Parameter layers: пресет колец свечения.
    ///
    /// - Returns: наибольшее значение `spread + blur` среди слоёв.
    static func overlayBleed(for layers: [UXGlow.Layer]) -> CGFloat {
        UXGlow.maxExtent(for: layers)
    }

    var body: some View {
        UXTheme.Reader { mode in
            SurfaceOutlineGlowCanvas(
                cornerRadius: cornerRadius,
                color: color.resolved(for: mode.colorScheme),
                layers: layers
            )
        }
    }
}

/// Canvas-реализация контурного свечения. Во view не вызывать напрямую.
private struct SurfaceOutlineGlowCanvas: View {
    /// Радиус скругления контура.
    let cornerRadius: CGFloat

    /// Разрешённый цвет свечения для текущей темы.
    let color: Color

    /// Пресет колец свечения.
    let layers: [UXGlow.Layer]

    var body: some View {
        ZStack {
            ForEach(layers.indices, id: \.self) { index in
                let layer = layers[index]
                glowRing(spread: layer.spread, opacity: layer.opacity, blur: layer.blur)
            }
        }
        .compositingGroup()
        .allowsHitTesting(false)
    }

    /// Одно кольцо свечения: заливка с вырезом контура и размытие.
    ///
    /// - Parameters:
    ///   - spread: разброс кольца от контура в pt.
    ///   - opacity: прозрачность кольца.
    ///   - blur: радиус размытия кольца.
    private func glowRing(spread: CGFloat, opacity: CGFloat, blur: CGFloat) -> some View {
        Canvas { context, size in
            let bleed = UXGlow.maxExtent(for: layers)
            let cardRect = CGRect(
                x: bleed,
                y: bleed,
                width: size.width - bleed * 2,
                height: size.height - bleed * 2
            )
            guard cardRect.width > 0, cardRect.height > 0 else { return }

            context.fill(
                Path(
                    roundedRect: cardRect.insetBy(dx: -spread, dy: -spread),
                    cornerRadius: cornerRadius + spread
                ),
                with: .color(color.opacity(opacity))
            )

            context.blendMode = .destinationOut
            context.fill(
                Path(roundedRect: cardRect, cornerRadius: cornerRadius),
                with: .color(.black)
            )
        }
        .blur(radius: blur)
    }
}
