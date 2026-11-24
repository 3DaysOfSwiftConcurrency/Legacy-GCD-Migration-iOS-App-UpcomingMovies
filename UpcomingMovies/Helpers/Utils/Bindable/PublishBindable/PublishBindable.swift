//
//  PublishBindable.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/10/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

final class PublishBindable<T>: PublishBindableProtocol {

    typealias Listener = ((T) -> Void)
    private var listener: Listener?

    private var delivery: BindingDelivery = .immediate

    func bind(_ listener: @escaping Listener, on delivery: BindingDelivery = .immediate) {
        self.listener = listener
        self.delivery = delivery
    }

    func send(_ value: T) {
        delivery.send { self.listener?(value) }
    }

}

extension PublishBindable where T == Void {

    func send() {
        send(())
    }

}
