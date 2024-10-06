import UIKit
import CoreLocation

class ViewController_NewPin: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: ViewController_NewPinDelegate?
    private var titleTextField: UITextField!
    private var descriptionTextField: UITextField!
    private var imageScrollView: UIScrollView!
    private var imageStackView: UIStackView!
    var tappedCoordinate: CLLocationCoordinate2D?
    private var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // タイトルラベルの追加
        let titleLabel = UILabel()
        titleLabel.text = "お気に入りの場所を登録"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Xボタンの追加
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // ＋ボタンの追加
        let plusButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        plusButton.setImage(largeImage, for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        view.addSubview(plusButton)
        
        // タイトル用テキストフィールドの追加
        titleTextField = UITextField()
        titleTextField.placeholder = "タイトル"
        titleTextField.borderStyle = .roundedRect
        titleTextField.autocapitalizationType = .allCharacters
        titleTextField.delegate = self
        view.addSubview(titleTextField)
        
        // 説明用テキストフィールドの追加
        descriptionTextField = UITextField()
        descriptionTextField.placeholder = "説明"
        descriptionTextField.borderStyle = .roundedRect
        descriptionTextField.font = UIFont.systemFont(ofSize: 18)
        descriptionTextField.delegate = self
        view.addSubview(descriptionTextField)
        
        // 画像追加ボタンの追加
        let addImageButton = UIButton(type: .system)
        addImageButton.setTitle("画像を追加", for: .normal)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        view.addSubview(addImageButton)
        
        // 画像スクロールビューの追加
        imageScrollView = UIScrollView()
        imageScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(imageScrollView)
        
        // 画像スタックビューの追加
        imageStackView = UIStackView()
        imageStackView.axis = .horizontal
        imageStackView.spacing = 10
        imageScrollView.addSubview(imageStackView)
        
        // Auto Layout の設定
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            imageScrollView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 16),
            imageScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalToConstant: 100),
            
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor, constant: 16),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor, constant: -16),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor)
        ])
    }
    
    @objc func addImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImages.append(selectedImage)
            updateImageScrollView()
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func updateImageScrollView() {
        // 既存の画像ビューをすべて削除
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 新しい画像ビューを追加
        for image in selectedImages {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            imageStackView.addArrangedSubview(imageView)
        }
    }
    
    @objc func plusButtonTapped() {
        print("+")
        delegate?.viewController_NewPinDidTapPlus(self, title: titleTextField.text, description: descriptionTextField.text)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        print("ピンを削除しました")
        delegate?.viewController_NewPinDidTapClose(self)
        dismiss(animated: true, completion: nil)
    }
    
    // UITextFieldDelegate メソッド：リターンキーが押されたときにキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol ViewController_NewPinDelegate: AnyObject {
    func viewController_NewPinDidTapPlus(_ controller: ViewController_NewPin, title: String?, description: String?)
    func viewController_NewPinDidTapClose(_ controller: ViewController_NewPin)
}
