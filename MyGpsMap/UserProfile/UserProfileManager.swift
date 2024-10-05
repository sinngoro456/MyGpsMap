import UIKit

protocol UserProfileManagerDelegate: AnyObject {
    func didTapProfileButton()
}

class UserProfileManager {
    weak var delegate: UserProfileManagerDelegate?
    
    func setupProfileButton(in view: UIView) -> UIButton {
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.backgroundColor = .white
        profileButton.tintColor = .systemBlue
        profileButton.layer.cornerRadius = 8
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 600),
            profileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -11),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return profileButton
    }
    
    @objc private func profileButtonTapped() {
        print("プロフィールボタンがタップされました")
        delegate?.didTapProfileButton()
    }
}
