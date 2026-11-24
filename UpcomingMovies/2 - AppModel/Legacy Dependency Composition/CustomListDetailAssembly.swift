//
//  CustomListDetailAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/15/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import Swinject
import UpcomingMoviesDomain

final class CustomListDetailAssembly: Assembly {

    func assemble(container: Container) {
        container.register(CustomListDetailViewModelProtocol.self) { (_, list: ListProtocol) in
            MainActor.assumeIsolated {
                CustomListDetailViewModel(list, customListDetailFeature: AppModel.shared.customListDetailFeature)
            }
        }
    }

}
