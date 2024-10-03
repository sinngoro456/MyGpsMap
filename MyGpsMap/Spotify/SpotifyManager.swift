import UIKit

class SpotifyManager {
    func setupSpotifyButton(in view: UIView) -> UIButton {
        let spotifyButton = UIButton(type: .system)
        spotifyButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        spotifyButton.backgroundColor = .white
        spotifyButton.tintColor = .systemGreen
        spotifyButton.layer.cornerRadius = 8
        spotifyButton.addTarget(self, action: #selector(spotifyButtonTapped), for: .touchUpInside)
        
        view.addSubview(spotifyButton)
        spotifyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spotifyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            spotifyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            spotifyButton.widthAnchor.constraint(equalToConstant: 40),
            spotifyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return spotifyButton
    }
    
    @objc private func spotifyButtonTapped() {
        // Spotify起動処理をここに追加
        print("Spotifyボタンがタップされました")
    }
}
