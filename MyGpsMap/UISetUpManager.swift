import UIKit
import MapKit

class UISetupManager {
    func setupCompassButton(in view: UIView, mapView: MKMapView) -> MKCompassButton {
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        view.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants_Design.compassButtonTopOffset),
            compassButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants_Design.compassButtonTrailingOffset)
        ])
        return compassButton
    }

    func setupUserTrackingButton(in view: UIView, target: Any, action: Selector) -> UIButton {
        let userTrackingButton = UIButton(type: .system)
        userTrackingButton.setImage(UIImage(systemName: Constants_Design.userTrackingButtonNone), for: .normal)
        userTrackingButton.backgroundColor = .white
        userTrackingButton.tintColor = .systemBlue
        userTrackingButton.layer.cornerRadius = Constants_Design.buttonCornerRadius
        userTrackingButton.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(userTrackingButton)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userTrackingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants_Design.userTrackingButtonTopOffset),
            userTrackingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants_Design.userTrackingButtonTrailingOffset),
            userTrackingButton.widthAnchor.constraint(equalToConstant: Constants_Design.buttonWidth),
            userTrackingButton.heightAnchor.constraint(equalToConstant: Constants_Design.buttonHeight)
        ])
        return userTrackingButton
    }

    func setupSpotifyButton(in view: UIView, target: Any, action: Selector) -> UIButton {
        let spotifyButton = UIButton(type: .system)
        spotifyButton.setImage(UIImage(systemName: Constants_Design.spotifyButtonImageName), for: .normal)
        spotifyButton.backgroundColor = .white
        spotifyButton.tintColor = .systemGreen
        spotifyButton.layer.cornerRadius = Constants_Design.buttonCornerRadius
        spotifyButton.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(spotifyButton)
        spotifyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spotifyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants_Design.spotifyButtonTopOffset),
            spotifyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants_Design.spotifyButtonTrailingOffset),
            spotifyButton.widthAnchor.constraint(equalToConstant: Constants_Design.buttonWidth),
            spotifyButton.heightAnchor.constraint(equalToConstant: Constants_Design.buttonHeight)
        ])
        return spotifyButton
    }

    func setupProfileButton(in view: UIView, target: Any, action: Selector) -> UIButton {
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: Constants_Design.profileButtonImageName), for: .normal)
        profileButton.backgroundColor = .white
        profileButton.tintColor = .systemBlue
        profileButton.layer.cornerRadius = Constants_Design.buttonCornerRadius
        profileButton.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants_Design.profileButtonbottomOffset),
            profileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants_Design.profileButtonTrailingOffset),
            profileButton.widthAnchor.constraint(equalToConstant: Constants_Design.buttonWidth),
            profileButton.heightAnchor.constraint(equalToConstant: Constants_Design.buttonHeight)
        ])
        return profileButton
    }

    func setupRadikoButton(in view: UIView, target: Any, action: Selector) -> UIButton {
        let radikoButton = UIButton(type: .system)
        radikoButton.setImage(UIImage(systemName: Constants_Design.radikoButtonImageName), for: .normal)
        radikoButton.backgroundColor = .white
        radikoButton.tintColor = .systemRed
        radikoButton.layer.cornerRadius = Constants_Design.buttonCornerRadius
        radikoButton.addTarget(target, action: action, for: .touchUpInside)
        view.addSubview(radikoButton)
        radikoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radikoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants_Design.radikoButtonTopOffset),
            radikoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants_Design.radikoButtonLeadingOffset),
            radikoButton.widthAnchor.constraint(equalToConstant: Constants_Design.buttonWidth),
            radikoButton.heightAnchor.constraint(equalToConstant: Constants_Design.buttonHeight)
        ])
        return radikoButton
    }

    func setupDestinationTextField(in view: UIView, delegate: UITextFieldDelegate) -> UITextField {
        let destinationTextField = UITextField()
        destinationTextField.placeholder = Constants_Design.destinationTextFieldPlaceholder
        destinationTextField.borderStyle = Constants_Design.destinationTextFieldBorderStyle
        destinationTextField.backgroundColor = Constants_Design.destinationTextFieldBackGroundColor
        destinationTextField.delegate = delegate
        view.addSubview(destinationTextField)
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            destinationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            destinationTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants_Design.destinationTextFieldBottomOffset),
            destinationTextField.widthAnchor.constraint(equalToConstant: Constants_Design.destinationTextFieldWidth),
            destinationTextField.heightAnchor.constraint(equalToConstant: Constants_Design.destinationTextFieldHeight)
        ])
        return destinationTextField
    }
}
