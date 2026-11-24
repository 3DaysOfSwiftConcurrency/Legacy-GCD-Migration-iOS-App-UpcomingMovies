//
//  SearchMoviesAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/16/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import Swinject
import UpcomingMoviesDomain

final class SearchMoviesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SearchOptionsViewModelProtocol.self) { _ in
            MainActor.assumeIsolated {
                SearchOptionsViewModel(searchMoviesFeature: AppModel.shared.searchMoviesFeature)
            }
        }
        container.register(SearchMoviesResultViewModelProtocol.self) { _ in
            MainActor.assumeIsolated {
                SearchMoviesResultViewModel(searchMoviesFeature: AppModel.shared.searchMoviesFeature)
            }
        }
    }

}
