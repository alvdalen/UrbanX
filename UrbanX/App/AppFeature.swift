//
//  AppFeature.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
    }
}

extension AppFeature {
    /// Состояние корневого reducer: вложенное состояние главного экрана.
    @ObservableState
    struct State: Equatable {
        /// Состояние главного экрана с программами и каруселью.
        var home: HomeFeature.State

        /// Создаёт начальное состояние приложения с заданным состоянием главного экрана.
        ///
        /// - Parameter home: начальное состояние `HomeFeature`.
        init(home: HomeFeature.State) {
            self.home = home
        }
    }

    /// Действия корневого reducer: маршрутизируются во вложенные feature.
    @CasePathable
    enum Action: Equatable {
        /// Действие главного экрана.
        ///
        /// - Parameter action: событие из `HomeFeature.Action`.
        case home(HomeFeature.Action)
    }
}
