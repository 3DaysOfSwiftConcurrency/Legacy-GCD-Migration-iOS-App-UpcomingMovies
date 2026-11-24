//
//  CustomListsAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class CustomListsAssembly: Assembly {

    func assemble(container: Container) {
        container.register(CustomListsViewModelProtocol.self) { _ in
            MainActor.assumeIsolated {
                CustomListsViewModel(customListsFeature: AppModel.shared.customListsFeature)
            }
        }
    }

}
