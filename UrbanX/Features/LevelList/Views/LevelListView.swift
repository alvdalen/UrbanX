//
//  LevelListView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.07.2026.
//

import ComposableArchitecture
import SwiftUI

/// Список уровней тренировки — заготовка под ячейки уровней.
struct LevelListView: View {
    // MARK: - Internal Properties
    @Bindable var store: StoreOf<LevelListFeature>

    // MARK: - Body
    var body: some View {
        content
            .navigationTitle(Strings.LevelList.Navigation.title)
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            screenContent
        }
    }

    /// Основной контент списка уровней.
    private var screenContent: some View {
        EmptyView()
    }
}
