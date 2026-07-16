//
//  WormPageIndicator.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 28.06.2026.
//

import SwiftUI

/// Индикатор текущей страницы карусели — ряд серых точек под карточками.
///
/// Активная страница выделена вытянутой скруглённой формой, которая
/// плавно переезжает между точками при смене индекса. Точка назначения начинает
/// исчезать до старта движения, создавая эффект предвосхищения.
///
/// ```swift
/// @State private var currentPage = 0
///
/// WormPageIndicator(count: 5, selectedIndex: currentPage)
/// ```
struct WormPageIndicator: View {
    // MARK: - Internal Properties
    /// Общее количество страниц. При значении `0` компонент не отображается.
    let count: Int

    /// Индекс активной страницы. Автоматически ограничивается диапазоном `0..<count`.
    let selectedIndex: Int

    // MARK: - Private Properties
    /// `selectedIndex`, ограниченный диапазоном `0..<count`.
    /// Защищает от выхода за границы при некорректных входных данных.
    private var clampedIndex: Int {
        min(max(selectedIndex, 0), count - 1)
    }

    /// Позиция переднего конца активной метки по X от левого края.
    /// При движении вправо уходит к цели первым — метка вытягивается вперёд.
    /// При движении влево догоняет вторым — метка сжимается слева.
    @State private var head: CGFloat = .zero

    /// Позиция заднего конца активной метки по X от левого края.
    /// При движении влево уходит к цели первым — метка вытягивается влево.
    /// При движении вправо догоняет вторым — метка сжимается справа.
    @State private var tail: CGFloat = .zero

    // MARK: - Body
    var body: some View {
        if count > 0 {
            indicatorWithLifecycle
        }
    }


    // MARK: - Корневой индикатор

    /// Индикатор с фиксированной шириной ряда, начальной позицией метки и анимацией при смене страницы.
    private var indicatorWithLifecycle: some View {
        indicatorContent
            .frame(width: indicatorWidth, alignment: .leading)
            .onAppear {
                handleAppear()
            }
            .onChange(of: clampedIndex) { _, newValue in
                handleIndexChange(newValue)
            }
    }

    // MARK: - Содержимое индикатора

    /// Ряд точек и активная метка поверх них.
    private var indicatorContent: some View {
        ZStack(alignment: .leading) {
            dotsRow
            activeWorm
        }
    }

    // MARK: - Ряд точек

    /// Горизонтальный ряд серых точек индикатора.
    private var dotsRow: some View {
        HStack(spacing: LocalConstants.dotSpacing) {
            ForEach(0..<count, id: \.self) { index in
                indicatorDot(at: index)
            }
        }
    }

    /// Одна точка индикатора с областью нажатия `dotSize`.
    private func indicatorDot(at index: Int) -> some View {
        IndicatorDot(
            isActive: index == clampedIndex,
            size: LocalConstants.inactiveDotSize,
            disappearDuration: LocalConstants.dotDisappearDuration,
            appearDuration: LocalConstants.dotAppearDuration
        )
        .frame(width: LocalConstants.dotSize, height: LocalConstants.dotSize)
    }

    // MARK: - Активная метка

    /// Вытянутая активная метка поверх точек.
    private var activeWorm: some View {
        Worm(
            head: head,
            tail: tail,
            diameter: LocalConstants.dotSize
        )
        .fill(UXColor.pageIndicatorActive)
        .frame(height: LocalConstants.dotSize)
    }
}

// MARK: - Private Methods
private extension WormPageIndicator {
    /// Шаг между центрами точек — фиксированный pt, без frame scale.
    var dotStep: CGFloat {
        LocalConstants.dotSize + LocalConstants.dotSpacing
    }

    /// Ширина ряда точек: расстояние между центрами крайних точек плюс диаметр.
    var indicatorWidth: CGFloat {
        CGFloat(count - 1) * dotStep + LocalConstants.dotSize
    }

    /// Устанавливает начальную позицию активной метки при первом появлении индикатора.
    func handleAppear() {
        let position = indicatorPosition(for: clampedIndex)
        head = position
        tail = position
    }

    /// Запускает анимацию перемещения активной метки при смене `clampedIndex`.
    ///
    /// - Parameter index: новый индекс активной страницы.
    func handleIndexChange(_ index: Int) {
        animate(to: indicatorPosition(for: index))
    }

    /// Позиция центра точки по X от левого края ряда.
    ///
    /// - Parameter index: индекс точки (0…`count - 1`).
    ///
    /// - Returns: координата X в pt.
    func indicatorPosition(for index: Int) -> CGFloat {
        CGFloat(index) * dotStep
    }

    /// Анимирует перемещение активной метки к целевой позиции.
    ///
    /// Два независимых `withAnimation`: сначала передний конец, затем задний с дополнительной задержкой.
    /// Направление определяется сравнением `target` с текущим `head`.
    ///
    /// - Parameter target: целевая позиция по X; вычисляется как `clampedIndex * step`.
    func animate(to target: CGFloat) {
        let delay = LocalConstants.animationDuration * LocalConstants.wormStartDelay
        let isForward = target > head

        animateLeadingEnd(to: target, isForward: isForward, delay: delay)
        animateTrailingEnd(to: target, isForward: isForward, delay: delay)
    }

    /// Рывок переднего конца активной метки к `target`.
    ///
    /// - Parameters:
    ///   - target: целевая позиция по X.
    ///   - isForward: `true` при движении вправо — анимируется `head`, иначе `tail`.
    ///   - delay: задержка старта относительно исчезновения точки назначения.
    func animateLeadingEnd(to target: CGFloat, isForward: Bool, delay: TimeInterval) {
        withAnimation(
            .easeOut(
                duration: LocalConstants.animationDuration * LocalConstants.wormHeadDuration
            ).delay(delay)
        ) {
            if isForward { head = target } else { tail = target }
        }
    }

    /// Подтягивание заднего конца активной метки к `target` с дополнительной задержкой.
    ///
    /// - Parameters:
    ///   - target: целевая позиция по X.
    ///   - isForward: `true` при движении вправо — догоняет `tail`, иначе `head`.
    ///   - delay: базовая задержка переднего конца; задний стартует позже на `wormTailExtraDelay`.
    func animateTrailingEnd(to target: CGFloat, isForward: Bool, delay: TimeInterval) {
        withAnimation(
            .easeOut(
                duration: LocalConstants.animationDuration * LocalConstants.wormTailDuration
            ).delay(delay + LocalConstants.animationDuration * LocalConstants.wormTailExtraDelay)
        ) {
            if isForward { tail = target } else { head = target }
        }
    }
}

// MARK: - Constants
private extension WormPageIndicator {
    enum LocalConstants {
        /// Расстояние между центрами соседних серых точек индикатора карусели.
        static let dotSpacing: CGFloat = 13

        /// Диаметр вытянутой активной метки и размер области нажатия каждой точки.
        ///
        /// Область нажатия намеренно равна `dotSize`, а не `inactiveDotSize` —
        /// чтобы все точки занимали одинаковую ширину в ряду.
        static let dotSize: CGFloat = 6.5

        /// Диаметр неактивной серой точки индикатора карусели.
        static let inactiveDotSize: CGFloat = 6.5

        /// Базовая длительность анимации в секундах; остальные тайминги — множители от неё.
        static let animationDuration: Double = 0.2

        /// Задержка перед стартом движения активной метки: `animationDuration * wormStartDelay`.
        static let wormStartDelay: Double = 0.4

        /// Длительность рывка переднего конца активной метки: `animationDuration * wormHeadDuration`.
        static let wormHeadDuration: Double = 0.7

        /// Сколько секунд точка-назначение исчезает перед началом движения активной метки.
        static let dotDisappearDuration: Double = 0.2

        /// Дополнительная задержка заднего конца после переднего:
        /// `animationDuration * (wormStartDelay + wormTailExtraDelay)`.
        static let wormTailExtraDelay: Double = 0.5

        /// Длительность подтягивания заднего конца активной метки: `animationDuration * wormTailDuration`.
        static let wormTailDuration: Double = 2.0

        /// Сколько секунд неактивная точка появляется обратно после ухода активной метки.
        static let dotAppearDuration: Double = 0.15
    }
}
