//
//  SimpleTutorialView.swift
//  Appear
//
//  Created by Magnus Tviberg on 01/05/2019.
//

import UIKit

public class SimpleTutorialView: UIView {
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = UIStackView.Alignment.center
        view.distribution = UIStackView.Distribution.fillProportionally
        view.spacing = 32
        view.axis = NSLayoutConstraint.Axis.vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.text = "Hold the camere towards a trigger image or object"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Once the trigger is detected the augmented content will appear"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTitle(_ string: String) {
        self.titleLabel.text = string
    }
    
    public func setDescription(_ string: String) {
        self.descriptionLabel.text = string
    }
    
    public func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
    
    private func setupView() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32)
            ])
    }
    
}
