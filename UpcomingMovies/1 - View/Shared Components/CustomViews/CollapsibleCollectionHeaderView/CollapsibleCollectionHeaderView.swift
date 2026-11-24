//
//  CollapsibleHeaderView.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/14/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

protocol CollapsibleHeaderViewDelegate: AnyObject {

    func collapsibleHeaderView(sectionHeaderView: CollapsibleCollectionHeaderView, sectionToggled section: Int)

}

class CollapsibleCollectionHeaderView: UICollectionReusableView {

    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var arrowImageView: UIImageView!

    weak var delegate: CollapsibleHeaderViewDelegate?

    private var section: Int?
    private var arrowRotation: CGFloat?

    func configure(with model: CollapsibleHeaderViewModelProtocol) {
        section = model.section
        arrowRotation = model.arrowRotationValue()
        accessibilityLabel = model.title
        titleLabel.text = model.title
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        backgroundColor = ColorPalette.defaultGrayBackgroundColor
        isAccessibilityElement = true

        setupTapGesture()
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tapGestureAction))
        addGestureRecognizer(tapGesture)
    }

    func updateArrowImageView(animated: Bool) {
        guard let arrowRotation else { return }
        arrowImageView.rotate(arrowRotation, duration: animated ? 0.3 : 0.0)
    }

    // MARK: - Selector

    @objc func tapGestureAction() {
        guard let section else { return }
        delegate?.collapsibleHeaderView(sectionHeaderView: self, sectionToggled: section)
    }

}
