//
//  AppView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import SwiftUI
import ComposableArchitecture

/// Корневой экран приложения: вкладки «Главная», «Карта» и «Профиль».
struct AppView: View {
    // MARK: - Internal Properties
    /// Корневой store приложения; главный экран — вложенный `HomeFeature`.
    @Bindable var store: StoreOf<AppFeature>

    // MARK: - Body
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView {
                Tab(Strings.Tab.home, systemImage: "house") {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                }
                
                Tab(Strings.Tab.map, systemImage: "map") {

                }
                
                Tab(Strings.Tab.profile, systemImage: "person") {

                }
            }
            .tint(UXColor.tabBarTint)
            .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            TabView {
                Tab(Strings.Tab.home, systemImage: "house") {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                }
                
                Tab(Strings.Tab.map, systemImage: "map") {
                    
                }
                
                Tab(Strings.Tab.profile, systemImage: "person") {
                    
                }
            }
        }
    }
}
