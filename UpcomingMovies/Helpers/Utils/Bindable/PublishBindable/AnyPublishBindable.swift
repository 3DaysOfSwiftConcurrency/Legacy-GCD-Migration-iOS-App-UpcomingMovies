//
//  AnyPublishBindable.swift
//  UpcomingMovies
//
//  Created by Alonso on 23/11/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

final class AnyPublishBindable<T>: PublishBindableProtocol {

    typealias Model = T
    typealias Listener = ((T) -> Void)

    private let sendClosure: ((T) -> Void)
    private let bindClosure: ((@escaping Listener, BindingDelivery) -> Void)

    init<B: PublishBindableProtocol>(_ bindable: B) where B.Model == T {
        self.sendClosure = bindable.send
        self.bindClosure = bindable.bind
    }

    func bind(_ listener: @escaping Listener, on delivery: BindingDelivery = .immediate) {
        bindClosure(listener, delivery)
    }

    func send(_ value: T) {
        sendClosure(value)
    }

}

extension AnyPublishBindable where T == Void {

    func send() {
        sendClosure(())
    }

}
