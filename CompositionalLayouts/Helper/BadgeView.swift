//
//  BadgeView.swift
//  CompositionalLayouts
//
//  Created by Will McGinty on 10/15/21.
//

import Foundation
import UIKit

class BadgeView: UICollectionReusableView {

    static let elementKind = "badge-element-kind"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .white

        return label
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureBorder()
    }

    var text: String? {
        didSet { label.text = text }
    }

    override var frame: CGRect {
        didSet { configureBorder() }
    }

    override var bounds: CGRect {
        didSet { configureBorder() }
    }
}

// MARK: - Helper
private extension BadgeView {

    func configureBorder() {
        let radius = bounds.width * 0.5
        layer.cornerRadius = radius
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
    }

    func configureView() {
        addSubview(label)
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: centerXAnchor), label.centerYAnchor.constraint(equalTo: centerYAnchor) ])
        backgroundColor = .red
    }
}
