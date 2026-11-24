//
//  MovieCreditsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/17/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Foundation
import Swinject
import UpcomingMoviesDomain

final class MovieCreditsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MovieCreditsSectionManagerProtocol.self) { _ in
            MovieCreditsSectionManager()
        }

        container.register(MovieCreditsViewModelProtocol.self) { (resolver, movieId: Int, movieTitle: String) in
            guard let factory = resolver.resolve(MovieCreditsSectionManagerProtocol.self) else {
                fatalError("MovieCreditsFactoryProtocol dependency could not be resolved")
            }
            return MainActor.assumeIsolated {
                MovieCreditsViewModel(movieId: movieId, movieTitle: movieTitle,
                                      movieCreditsFeature: AppModel.shared.movieCreditsFeature, factory: factory)
            }
        }
    }

}
