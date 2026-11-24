//
//  DataSourceAssembly.swift
//  UpcomingMovies
//
//  Created by Alonso on 9/12/20.
//  Copyright © 2020 Alonso. All rights reserved.
//

import UpcomingMoviesData
import CoreDataInfrastructure
import NetworkInfrastructure
import Swinject

final class DataSourceAssembly: Assembly {

    func assemble(container: Container) {
        container.register(LocalDataSource.self) { _ in
            LocalDataSource(appGroupExtensions: AppGroup.allCasesIdentifiers)
        }.inObjectScope(.container)
        .implements(LocalDataSourceProtocol.self)
        container.register(RemoteDataSourceProtocol.self) { _ in
            RemoteDataSource()
        }.inObjectScope(.container)
    }

}
