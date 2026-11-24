//
//  SavedMoviesAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/13/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class SavedMoviesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SavedMoviesViewModelProtocol.self) { (_, displayTitle: String?) in
            return MainActor.assumeIsolated {
                let collection: SavedMoviesCollection = displayTitle == ProfileOption.watchlist.title ? .watchlist : .favorites
                let viewModel = SavedMoviesViewModel(savedMoviesFeature: AppModel.shared.savedMoviesFeature, collection: collection)
                viewModel.displayTitle = displayTitle

                return viewModel
            }
        }
    }

}
