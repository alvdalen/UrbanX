//
//  ProgramCarouselSection.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 18.06.2026.
//

import SwiftUI
import ComposableArchitecture

/// Карусель страниц программ.
struct ProgramCarouselSection: View {
    // MARK: - Internal Properties
    /// Store главного экрана — порядок страниц, скролл, анимации прогресса.
    @Bindable var store: StoreOf<HomeFeature>

    // MARK: - Private Properties
    /// Двусторонняя привязка позиции paging-карусели к `store.scrollPosition`.
    private var carouselScrollPosition: Binding<Int?> {
        Binding(
            get: { store.scrollPosition },
            set: { _ = store.send(.scrollPositionChanged($0)) }
        )
    }

    // MARK: - Body
    var body: some View {
        carouselSection
    }


    // MARK: - Секция карусели

    /// Горизонтальная paging-карусель программ.
    private var carouselSection: some View {
        cardsCarousel
    }

    // MARK: - Горизонтальная карусель

    /// Горизонтальная paging-карусель с обработкой intent и фаз скролла.
    private var cardsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            carouselPages
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: carouselScrollPosition)
        .onChange(of: store.scrollIntent) { _, intent in
            handleScrollIntent(intent)
        }
        .onScrollPhaseChange { oldPhase, newPhase, _ in
            handleScrollPhaseChange(from: oldPhase, to: newPhase)
        }
    }

    // MARK: - Страницы карусели

    /// Ряд страниц программ для `scrollTargetLayout`.
    private var carouselPages: some View {
        HStack(spacing: .zero) {
            ForEach(Array(store.pageOrder.enumerated()), id: \.offset) { index, programID in
                programPage(at: index, programID: programID)
            }
        }
        .animation(nil, value: store.pageOrder)
        .scrollTargetLayout()
    }

    // MARK: - Страница программы

    /// Одна страница программы в карусели.
    ///
    /// - Parameters:
    ///   - index: индекс страницы в `store.pageOrder`.
    ///   - programID: идентификатор программы на этой странице.
    @ViewBuilder
    private func programPage(at index: Int, programID: UUID) -> some View {
        if let program = program(for: programID) {
            ProgramPageView(
                program: program,
                isSelected: index == store.selectedPage,
                canAnimate: store.canAnimateProgress,
                hasAnimatedBefore: store.animatedProgramIDs.contains(program.id),
                onProgressAnimationCompleted: {
                    store.send(.progressAnimationCompleted(program.id))
                }
            )
            .containerRelativeFrame(.horizontal)
            .carouselPageScrollTransition()
            .id(programID)
        }
    }
}

// MARK: - Private Methods
private extension ProgramCarouselSection {
    /// Обрабатывает смену фазы горизонтального скролла карусели.
    func handleScrollPhaseChange(
        from oldPhase: ScrollPhase,
        to newPhase: ScrollPhase
    ) {
        store.send(
            .carouselScrollPhaseChanged(
                from: carouselScrollPhase(oldPhase),
                to: carouselScrollPhase(newPhase)
            )
        )

        guard newPhase == .idle else { return }
        store.send(.carouselScrolledToIdle)
    }

    /// Находит программу по идентификатору в `store.programs`.
    ///
    /// - Parameter id: идентификатор программы.
    ///
    /// - Returns: модель программы или `nil`, если не найдена.
    func program(for id: UUID) -> Program? {
        store.programs.first(where: { $0.id == id })
    }

    /// Обрабатывает программный скролл карусели: плавный или мгновенный переход на страницу.
    ///
    /// - Parameter intent: намерение скролла из store или `nil`.
    func handleScrollIntent(_ intent: HomeFeature.ScrollIntent?) {
        guard let intent else { return }

        switch intent {
        case let .animated(page):
            withAnimation(.smooth(duration: HomeConstants.carouselScrollAnimationDuration)) {
                carouselScrollPosition.wrappedValue = page
            }
            _ = store.send(.clearScrollIntent)

        case let .immediate(page):
            withoutAnimation {
                _ = store.send(.applyImmediateScroll(page))
            }
        }
    }

    /// Преобразует системную фазу скролла в модель `HomeFeature.CarouselScrollPhase`.
    ///
    /// - Parameter phase: фаза `ScrollView` из `onScrollPhaseChange`.
    ///
    /// - Returns: соответствующая фаза карусели для reducer.
    func carouselScrollPhase(_ phase: ScrollPhase) -> HomeFeature.CarouselScrollPhase {
        switch phase {
        case .idle:
            return .idle
        case .tracking:
            return .tracking
        case .interacting:
            return .interacting
        case .decelerating:
            return .decelerating
        case .animating:
            return .animating
        @unknown default:
            return .idle
        }
    }

    /// Выполняет обновления без системной анимации SwiftUI.
    ///
    /// - Parameter updates: блок изменений состояния (например, мгновенный скролл карусели).
    func withoutAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, updates)
    }
}
