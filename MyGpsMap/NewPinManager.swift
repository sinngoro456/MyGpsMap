import UIKit
import CoreLocation

class NewPinManager: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: NewPinManagerDelegate?
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
        
        let titleLabel = UISetUpManager_NewPin.setupTitleLabel()
        let closeButton = UISetUpManager_NewPin.setupCloseButton(target: self, action: #selector(closeButtonTapped))
        let plusButton = UISetUpManager_NewPin.setupPlusButton(target: self, action: #selector(plusButtonTapped))
        
        titleTextField = UISetUpManager_NewPin.setupTextField(placeholder: "タイトル", autocapitalizationType: .allCharacters)
        titleTextField.delegate = self
        
        descriptionTextField = UISetUpManager_NewPin.setupTextField(placeholder: "説明")
        descriptionTextField.delegate = self
        
        let addImageButton = UISetUpManager_NewPin.setupAddImageButton(target: self, action: #selector(addImageButtonTapped))
        
        imageScrollView = UISetUpManager_NewPin.setupImageScrollView()
        imageStackView = UISetUpManager_NewPin.setupImageStackView()
        
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView].forEach { view.addSubview($0) }
        imageScrollView.addSubview(imageStackView)
        
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView, imageStackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        UISetUpManager_NewPin.setupConstraints(for: view, titleLabel: titleLabel, closeButton: closeButton, plusButton: plusButton, titleTextField: titleTextField, descriptionTextField: descriptionTextField, addImageButton: addImageButton, imageScrollView: imageScrollView, imageStackView: imageStackView)
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
        delegate?.newPinManagerDidTapPlus(self, title: titleTextField.text, description: descriptionTextField.text)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        print("ピンを削除しました")
        delegate?.newPinManagerDidTapClose(self)
        dismiss(animated: true, completion: nil)
    }
    
    // UITextFieldDelegate メソッド：リターンキーが押されたときにキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol NewPinManagerDelegate: AnyObject {
    func newPinManagerDidTapPlus(_ controller: NewPinManager, title: String?, description: String?)
    func newPinManagerDidTapClose(_ controller: NewPinManager)
}
