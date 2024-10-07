//
//  UISetUpManager_NewPin.swift
//  MyGpsMap
//
//  Created by 川渕悟郎 on 2024/10/06.
//

import UIKit

class UISetUpManager_NewPin {
    static func setupTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = NewPinManager.titleLabelText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        return titleLabel
    }
    
    static func setupCloseButton(target: Any?, action: Selector) -> UIButton {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(target, action: action, for: .touchUpInside)
        return closeButton
    }
    
    static func setupPlusButton(target: Any?, action: Selector) -> UIButton {
        let plusButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        plusButton.setImage(largeImage, for: .normal)
        plusButton.addTarget(target, action: action, for: .touchUpInside)
        return plusButton
    }
    
    static func setupTextField(placeholder: String, autocapitalizationType: UITextAutocapitalizationType = .none) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = autocapitalizationType
        return textField
    }
    
    static func setupAddImageButton(target: Any?, action: Selector) -> UIButton {
        let addImageButton = UIButton(type: .system)
        addImageButton.setTitle("画像を追加", for: .normal)
        addImageButton.addTarget(target, action: action, for: .touchUpInside)
        return addImageButton
    }
    
    static func setupImageScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    static func setupImageStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }
    static func setupDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }
    
    static func setupConstraints(for view: UIView, titleLabel: UILabel, closeButton: UIButton, plusButton: UIButton, titleTextField: UITextField, descriptionTextField: UITextField, addImageButton: UIButton, datePicker: UIDatePicker, imageScrollView: UIScrollView, imageStackView: UIStackView) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            plusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 60),
            
            addImageButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 16),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            datePicker.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 16),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageScrollView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            imageScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: 100),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor, constant: 16),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor, constant: -16),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor)
        ])
    }
}
