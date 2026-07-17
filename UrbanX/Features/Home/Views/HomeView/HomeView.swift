//
//  HomeView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 18.06.2026.
//

import SwiftUI
import ComposableArchitecture

/// Главный экран: ряд чипов программ, карусель карточек
/// и закреплённый снизу индикатор страниц.
struct HomeView: View {
    // MARK: - Internal Properties
    /// Store главного экрана: программы, карусель, чипы, haptics.
    @Bindable var store: StoreOf<HomeFeature>
    
    // MARK: - Body
    var body: some View {
        navigationShell
    }
    

    // MARK: - Оболочка навигации

    /// Оболочка экрана: навигация, вертикальный скролл и haptic feedback.
    private var navigationShell: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
                .navigationTitle(Strings.Home.Navigation.title)
                .navigationBarTitleDisplayMode(.large)
        } destination: { store in
            switch store.case {
            case let .levelList(store):
                LevelListView(store: store)
            }
        }
        .onChange(of: store.pageChangeHapticTick) {
            HapticFeedback.playPageChange()
        }
        .onChange(of: store.pinHapticTick) {
            HapticFeedback.playPin()
        }
    }

    // MARK: - Компоновка экрана

    /// Звёздный фон, скролл контента и фиксированный индикатор страниц снизу.
    private var content: some View {
        ZStack {
            backgroundLayer
            scrollContent
        }
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            pageIndicator
                .uxVisible(compact: false)
        }
    }

    /// Вертикальный скролл без системного фона — поверх `HomeScreenBackground`.
    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            homeScreen
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Фон

    /// Фон экрана: звёзды в тёмной теме, обычный системный фон — в светлой.
    private var backgroundLayer: some View {
        HomeScreenBackground()
    }
    
    // MARK: - Содержимое главного экрана

    /// Ряд чипов и карусель программ.
    private var homeScreen: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ProgramChipsSection(store: store)
            ProgramCarouselSection(store: store)
        }
    }

    // MARK: - Индикатор страниц

    /// Закреплённый снизу индикатор — не скроллится вместе с каруселью.
    private var pageIndicator: some View {
        WormPageIndicator(
            count: store.programs.count,
            selectedIndex: store.selectedChipIndex
        )
        .frame(maxWidth: .infinity)
        .padding(.top, LocalConstants.indicatorTopInset)
        .padding(.bottom, LocalConstants.indicatorBottomInset)
    }
}

// MARK: - Constants
private extension HomeView {
    enum LocalConstants {
        /// Отступ индикатора сверху от контента.
        static let indicatorTopInset: CGFloat = 8

        /// Отступ индикатора снизу над tab bar.
        static let indicatorBottomInset: CGFloat = 20
    }
}
