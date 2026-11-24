//
//  MovieReviewsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/17/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class MovieReviewsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MovieReviewsViewModelProtocol.self) { (_, movieId: Int, movieTitle: String) in
            MainActor.assumeIsolated {
                MovieReviewsViewModel(movieId: movieId,
                                      movieTitle: movieTitle,
                                      movieReviewsFeature: AppModel.shared.movieReviewsFeature)
            }
        }
    }

}
