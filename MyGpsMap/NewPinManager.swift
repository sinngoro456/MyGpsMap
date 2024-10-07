import UIKit
import CoreLocation
import EventKit

protocol NewPinManagerDelegate: AnyObject {
    func newPinManagerDidTapPlus(_ controller: NewPinManager, pinData: Data_Pin)
    func newPinManagerDidTapClose(_ controller: NewPinManager)
}

class NewPinManager: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: NewPinManagerDelegate?
    private var imageScrollView: UIScrollView!
    private var imageStackView: UIStackView!
    private let eventStore = EKEventStore()
    private var selectedDate: Date?
    private var datePicker: UIDatePicker!
    var titleTextField: UITextField!
    var descriptionTextField: UITextField!
    var tappedCoordinate: CLLocationCoordinate2D?
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        view.backgroundColor = .white
        
        let titleLabel = UISetUpManager_NewPin.setupTitleLabel()
        let closeButton = UISetUpManager_NewPin.setupCloseButton(target: self, action: #selector(closeButtonTapped))
        let plusButton = UISetUpManager_NewPin.setupPlusButton(target: self, action: #selector(plusButtonTapped))
        let addImageButton = UISetUpManager_NewPin.setupAddImageButton(target: self, action: #selector(addImageButtonTapped))
        
        titleTextField = UISetUpManager_NewPin.setupTextField(placeholder: "タイトル", autocapitalizationType: .allCharacters)
        titleTextField.delegate = self
        
        descriptionTextField = UISetUpManager_NewPin.setupTextField(placeholder: "説明")
        descriptionTextField.delegate = self
        
        imageScrollView = UISetUpManager_NewPin.setupImageScrollView()
        imageStackView = UISetUpManager_NewPin.setupImageStackView()
        
        datePicker = UISetUpManager_NewPin.setupDatePicker()
                
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView, datePicker].forEach { view.addSubview($0) }
        imageScrollView.addSubview(imageStackView)
        
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView, imageStackView, datePicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        UISetUpManager_NewPin.setupConstraints(for: view, titleLabel: titleLabel, closeButton: closeButton, plusButton: plusButton, titleTextField: titleTextField, descriptionTextField: descriptionTextField, addImageButton: addImageButton, datePicker: datePicker, imageScrollView: imageScrollView, imageStackView: imageStackView)
    }
    @objc func addImageButtonTapped() {
        print("image")
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
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
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
        guard let coordinate = tappedCoordinate else { return }
        
        // 画像の確認
        if selectedImages.isEmpty {
            print("選択された画像はありません")
        } else {
            print("選択された画像の数: \(selectedImages.count)")
            for (index, image) in selectedImages.enumerated() {
                print("画像 \(index + 1): \(image)")
            }
        }
        
        let pinData = Data_Pin(coordinate: coordinate, title: titleTextField.text, description: descriptionTextField.text, images: selectedImages)
        delegate?.newPinManagerDidTapPlus(self, pinData: pinData)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        print("ピンを削除しました")
        delegate?.newPinManagerDidTapClose(self)
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
