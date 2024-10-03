import UIKit

class RadikoManager {
    func setupRadikoButton(in view: UIView) -> UIButton {
        let radikoButton = UIButton(type: .system)
        radikoButton.setImage(UIImage(systemName: "radio"), for: .normal)
        radikoButton.backgroundColor = .white
        radikoButton.tintColor = .systemRed
        radikoButton.layer.cornerRadius = 8
        radikoButton.addTarget(self, action: #selector(radikoButtonTapped), for: .touchUpInside)
        
        view.addSubview(radikoButton)
        radikoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radikoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            radikoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            radikoButton.widthAnchor.constraint(equalToConstant: 40),
            radikoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return radikoButton
    }
    
    @objc private func radikoButtonTapped() {
        // Radiko起動処理をここに追加
        print("Radikoボタンがタップされました")
    }
}
