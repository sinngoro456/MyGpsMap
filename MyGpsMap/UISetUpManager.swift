import UIKit
import MapKit

class UISetupManager {
    func setupButtonConstraints(_ button: UIView, in view: UIView, top: CGFloat?, bottom: CGFloat?, leading: CGFloat?, trailing: CGFloat?) {
        var constraints = [NSLayoutConstraint]()
        
        if let top = top {
            constraints.append(button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top))
        }
        if let bottom = bottom {
            constraints.append(button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -bottom))
        }
        if let leading = leading {
            constraints.append(button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: leading))
        }
        if let trailing = trailing {
            constraints.append(button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: trailing))
        }
        
        if !(button is MKCompassButton) {
            constraints.append(contentsOf: [
                button.widthAnchor.constraint(equalToConstant: Constants_Design.buttonWidth),
                button.heightAnchor.constraint(equalToConstant: Constants_Design.buttonHeight)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }

    func setupCompassButton(in view: UIView, mapView: MKMapView) -> MKCompassButton {
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        view.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        
        setupButtonConstraints(compassButton, in: view,
                               top: Constants_Design.compassButtonTop,
                               bottom: Constants_Design.compassButtonBottom,
                               leading: Constants_Design.compassButtonLeading,
                               trailing: Constants_Design.compassButtonTrailing)
        
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
        
        setupButtonConstraints(userTrackingButton, in: view,
                               top: Constants_Design.userTrackingButtonTop,
                               bottom: Constants_Design.userTrackingButtonBottom,
                               leading: Constants_Design.userTrackingButtonLeading,
                               trailing: Constants_Design.userTrackingButtonTrailing)
        
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
        
        setupButtonConstraints(spotifyButton, in: view,
                               top: Constants_Design.spotifyButtonTop,
                               bottom: Constants_Design.spotifyButtonBottom,
                               leading: Constants_Design.spotifyButtonLeading,
                               trailing: Constants_Design.spotifyButtonTrailing)
        
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
        
        setupButtonConstraints(profileButton, in: view,
                               top: Constants_Design.profileButtonTop,
                               bottom: Constants_Design.profileButtonBottom,
                               leading: Constants_Design.profileButtonLeading,
                               trailing: Constants_Design.profileButtonTrailing)
        
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
        
        setupButtonConstraints(radikoButton, in: view,
                               top: Constants_Design.radikoButtonTop,
                               bottom: Constants_Design.radikoButtonBottom,
                               leading: Constants_Design.radikoButtonLeading,
                               trailing: Constants_Design.radikoButtonTrailing)
        
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
            destinationTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants_Design.destinationTextFieldBottom),
            destinationTextField.widthAnchor.constraint(equalToConstant: Constants_Design.destinationTextFieldWidth),
            destinationTextField.heightAnchor.constraint(equalToConstant: Constants_Design.destinationTextFieldHeight)
        ])
        
        return destinationTextField
    }
}
