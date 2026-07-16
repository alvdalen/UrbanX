//
//  UXSurfaceModifier.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//
import SwiftUI

extension View {
    /// Фон со скруглением, внутренним отступом, обводкой, тенью и контурным свечением.
    ///
    /// - Parameters:
    ///   - cornerRadius: радиус скругления фона.
    ///   - padding: внутренний отступ содержимого от края фона.
    ///   - paddingEdges: стороны, на которых применяется `padding`.
    ///   - fill: заливка фона.
    ///   - stroke: цвет обводки; по умолчанию прозрачный.
    ///   - lineWidth: толщина обводки; `0` — обводка не рисуется.
    ///   - shadow: включить тематическую тень `uxShadow`.
    ///   - glow: включить контурное свечение вокруг фона.
    ///   - glowColor: цвет свечения; по умолчанию `UXColor.cardGlow`.
    ///   - glowLayers: пресет колец свечения; по умолчанию `UXGlow.cardLayers`.
    ///
    /// - Returns: view с фоном за содержимым через `ViewModifier`.
    func uxSurface<F: ShapeStyle, S: ShapeStyle>(
        cornerRadius: CGFloat = 0,
        padding: CGFloat = .zero,
        paddingEdges: Edge.Set = .all,
        fill: F,
        stroke: S = Color.clear,
        lineWidth: CGFloat = .zero,
        shadow: Bool = false,
        glow: Bool = false,
        glowColor: UXAdaptiveColor = UXColor.cardGlow,
        glowLayers: [UXGlow.Layer]? = nil
    ) -> some View {
        modifier(
            UXSurfaceModifier(
                cornerRadius: cornerRadius,
                padding: padding,
                paddingEdges: paddingEdges,
                fill: AnyShapeStyle(fill),
                stroke: AnyShapeStyle(stroke),
                lineWidth: lineWidth,
                shadow: shadow,
                glow: glow,
                glowColor: glowColor,
                glowLayers: glowLayers
            )
        )
    }
}

/// Реализация `.uxSurface`. Во view не вызывать напрямую.
private struct UXSurfaceModifier: ViewModifier {
    /// Радиус скругления фона.
    let cornerRadius: CGFloat

    /// Внутренний отступ содержимого от края фона.
    let padding: CGFloat

    /// Стороны, на которых применяется `padding`.
    let paddingEdges: Edge.Set

    /// Заливка фона.
    let fill: AnyShapeStyle

    /// Цвет обводки.
    let stroke: AnyShapeStyle

    /// Толщина обводки.
    let lineWidth: CGFloat

    /// Включена ли тематическая тень.
    let shadow: Bool

    /// Включено ли контурное свечение.
    let glow: Bool

    /// Цвет контурного свечения.
    let glowColor: UXAdaptiveColor

    /// Пресет колец свечения; `nil` — `UXGlow.cardLayers`.
    let glowLayers: [UXGlow.Layer]?

    /// `EdgeInsets` по выбранным сторонам из `paddingEdges`.
    private var paddingInsets: EdgeInsets {
        EdgeInsets(
            top: paddingEdges.contains(.top) ? padding : 0,
            leading: paddingEdges.contains(.leading) ? padding : 0,
            bottom: paddingEdges.contains(.bottom) ? padding : 0,
            trailing: paddingEdges.contains(.trailing) ? padding : 0
        )
    }

    /// Добавляет отступы и скруглённый фон за содержимым.
    func body(content: Content) -> some View {
        content
            .padding(paddingInsets)
            .background { surfaceBackground }
    }

    /// Скруглённый фон с обводкой, тенью и опциональным свечением.
    private var surfaceBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fill)
            .overlay { surfaceStroke }
            .background { surfaceGlow }
            .uxShadow(enabled: shadow)
    }

    /// Обводка фона; скрыта при `lineWidth == 0`.
    @ViewBuilder
    private var surfaceStroke: some View {
        if lineWidth > .zero {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(stroke, lineWidth: lineWidth)
        }
    }

    /// Контурное свечение за фоном; скрыто при `glow == false`.
    @ViewBuilder
    private var surfaceGlow: some View {
        if glow {
            let layers = glowLayers ?? UXGlow.cardLayers
            let bleed = SurfaceOutlineGlow.overlayBleed(for: layers)
            SurfaceOutlineGlow(
                cornerRadius: cornerRadius,
                color: glowColor,
                layers: layers
            )
            .padding(-bleed)
        }
    }
}
