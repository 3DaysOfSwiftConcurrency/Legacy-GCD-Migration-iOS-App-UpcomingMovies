//
//  PublishBindableProtocol.swift
//  UpcomingMovies
//
//  Created by Alonso on 23/11/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

protocol PublishBindableProtocol {

    associatedtype Model

    func bind(_ listener: @escaping ((Model) -> Void), on delivery: BindingDelivery)
    func send(_ value: Model)

}

extension PublishBindableProtocol {

    func eraseToAnyBindable() -> AnyPublishBindable<Model> {
        AnyPublishBindable(self)
    }

}

/// Unscheduled listeners run inline. All UI listeners share a FIFO so that
/// events from different bindings reach the screen in submission order.
enum BindingDelivery {
    case immediate, main

    func send(_ update: @escaping () -> Void) {
        switch self {
        case .immediate: update()
        case .main: MainBindingDelivery.shared.enqueue(update)
        }
    }
}

private final class MainBindingDelivery {
    static let shared = MainBindingDelivery()

    private let updates: AsyncStream<() -> Void>.Continuation
    private let consumer: Task<Void, Never>

    private init() {
        let (stream, continuation) = AsyncStream<() -> Void>.makeStream()
        updates = continuation
        consumer = Task { @MainActor in
            for await update in stream { update() }
        }
    }

    func enqueue(_ update: @escaping () -> Void) {
        updates.yield(update)
    }
}
