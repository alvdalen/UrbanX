//
//  ProgramChipView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 20.06.2026.
//

import SwiftUI

/// Горизонтальный чип с названием программы в ряду на главном экране.
struct ProgramChipView: View {
    // MARK: - Internal Properties
    /// Короткое название программы внутри чипа.
    let title: String

    /// Выбран ли чип — влияет на цвета, обводку и свечение.
    let isSelected: Bool

    /// Закреплён ли чип — показывает иконку pin слева от названия.
    let isPinned: Bool

    // MARK: - Body
    var body: some View {
        chipContent
    }


    // MARK: - Содержимое чипа

    /// Capsule-фон, обводка, тень и опциональное свечение выбранного чипа.
    private var chipContent: some View {
        chipLabel
            .foregroundStyle(UXColor.chipForeground(isSelected: isSelected))
            .padding(.horizontal, LocalConstants.horizontalPadding)
            .padding(.vertical, LocalConstants.verticalPadding)
            .background {
                Capsule()
                    .fill(UXColor.chipBackground(isSelected: isSelected))
                    .animation(nil, value: isSelected)
                    .background { selectedChipGlow }
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        UXColor.chipBorder(isSelected: isSelected),
                        lineWidth: LocalConstants.borderWidth
                    )
                    .animation(nil, value: isSelected)
            }
            .uxShadow()
    }

    // MARK: - Свечение выбранного чипа

    /// В тёмной теме — fade opacity при смене выбора; в светлой не рисуется.
    private var selectedChipGlow: some View {
        UXTheme.Reader { mode in
            if mode == .dark {
                GeometryReader { geometry in
                    let bleed = UXGlow.maxExtent(for: UXGlow.selectedChipLayers)
                    SurfaceOutlineGlow(
                        cornerRadius: geometry.size.height / 2,
                        color: UXColor.selectedChipGlow,
                        layers: UXGlow.selectedChipLayers
                    )
                    .padding(-bleed)
                }
                .opacity(isSelected ? 1 : 0)
                .animation(glowOpacityAnimation, value: isSelected)
                .allowsHitTesting(false)
            }
        }
    }

    /// Погасание быстрее появления.
    private var glowOpacityAnimation: Animation {
        isSelected
            ? .easeOut(duration: LocalConstants.glowAppearDuration)
            : .easeIn(duration: LocalConstants.glowExtinguishDuration)
    }

    // MARK: - Подпись чипа

    /// Иконка pin и название программы в одной строке.
    private var chipLabel: some View {
        HStack(spacing: LocalConstants.contentSpacing) {
            if isPinned {
                pinIcon
            }
            titleText
        }
        .animation(nil, value: isSelected)
    }

    /// Иконка закрепления слева от названия программы.
    private var pinIcon: some View {
        Image(systemName: "pin.fill")
            .font(.system(size: LocalConstants.iconSize))
    }

    /// Название программы в чипе.
    private var titleText: some View {
        Text(title)
            .uxFont(.chipSize, large: LocalConstants.fontLargeScale)
    }
}

// MARK: - Constants
private extension ProgramChipView {
    enum LocalConstants {
        /// Горизонтальный отступ текста чипа от краёв capsule-фона.
        static let horizontalPadding: CGFloat = 20

        /// Вертикальный отступ текста чипа от краёв capsule-фона.
        static let verticalPadding: CGFloat = 12

        /// Между иконкой pin и названием программы внутри чипа.
        static let contentSpacing: CGFloat = 6

        /// Толщина обводки вокруг фона чипа программы.
        static let borderWidth: CGFloat = 1

        /// Размер иконки pin в закреплённом чипе.
        static let iconSize: CGFloat = 10

        /// Множитель размера шрифта названия программы на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.1

        /// Длительность появления свечения.
        static let glowAppearDuration: TimeInterval = 0.35

        /// Длительность погасания свечения — мгновенно.
        static let glowExtinguishDuration: TimeInterval = 0
    }
}
