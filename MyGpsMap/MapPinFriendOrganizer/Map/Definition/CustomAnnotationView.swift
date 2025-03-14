import MapKit

class CustomAnnotationView: MKAnnotationView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10 // 画像を角丸にする
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    // 隠し情報を保持するプロパティ
    var user_id: String?
    var pin_id: String?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // 画像とタイトルを表示するためのUIを追加
        addSubview(imageView)
        addSubview(titleLabel)

        // レイアウト制約を設定
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
    }

    func configure(with pin: Data_Pin) {
        // ピンの画像を設定
        if let firstImage = pin.images.first {
            imageView.image = firstImage
        } else {
            imageView.removeFromSuperview() // 画像がない場合は画像ビューを削除
            let pinImage = UIImage(systemName: "mappin.circle.fill")?
                .withTintColor(.red, renderingMode: .alwaysOriginal) // 赤色に変更
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .default)) // サイズを大きくする
            self.image = pinImage
        }

        // ピンのタイトルを設定
        titleLabel.text = pin.title

        // 隠し情報を保持
        user_id = pin.user_id
        pin_id = pin.pin_id
    }
}
