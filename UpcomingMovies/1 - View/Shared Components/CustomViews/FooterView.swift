//
//  FooterView.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/8/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import UIKit

class FooterView: UIView {

    static let recommendedFrame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = FontHelper.subheadLight
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Internal

    var message: String? {
        didSet {
            messageLabel.text = message
        }
    }

    // MARK: - Initializers

    init(message: String) {
        super.init(frame: FooterView.recommendedFrame)
        setupUI()
        messageLabel.text = message
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    static func retryFooter(for error: Error, retry: @escaping () -> Void) -> UIView {
        let button = UIButton(type: .system)
        button.frame = recommendedFrame
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.setTitle(error.localizedDescription + "\n" + LocalizedStrings.errorPlaceHolderViewRetryButtonTitle(), for: .normal)
        button.addAction(UIAction { _ in retry() }, for: .touchUpInside)
        return button
    }

    // MARK: - Private

    private func setupUI() {
        addSubview(messageLabel)
        messageLabel.fillSuperview(padding: .init(top: 0, left: Constants.horizontalMargin,
                                                  bottom: 0, right: Constants.horizontalMargin))
    }

    // MARK: - Constants

    struct Constants {
        static let horizontalMargin: CGFloat = 8.0
    }

}
