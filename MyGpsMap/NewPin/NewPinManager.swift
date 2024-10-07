import UIKit
import CoreLocation
import EventKit

protocol NewPinManagerDelegate: AnyObject {
    func newPinManagerDidTapPlus(_ controller: NewPinManager, pinData: Data_Pin, isValid: Bool)
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
    var tappedTitle: String = ""
    var tappedDescription: String = ""
    var tappedImages: [UIImage] = []
    var tappedCategory: String = ""
    var tappedTags: [String] = []
    var selectedTitle: String = ""
    var selectedDescription: String = ""
    var selectedImages: [UIImage] = []
    var selectedCategory: String = ""
    var selectedTags: [String] = []
    private var titleLabel: UILabel!
    private var initialPinData: Data_Pin?
    static var titleLabelText: String = "お気に入りの場所を登録"
    var isNewPin: Bool = true  // デフォルトは新しいピン
    
    init(pinData: Data_Pin) {
        super.init(nibName: nil, bundle: nil)
        self.tappedCoordinate = pinData.coordinate
        self.tappedTitle = pinData.title ?? ""
        self.tappedDescription = pinData.description ?? ""
        self.tappedImages = pinData.images
        self.tappedCategory = pinData.category ?? ""
        self.tappedTags = pinData.tags ?? []
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    private func setupUI() {
        view.backgroundColor = .white
        let closeButton = UISetUpManager_NewPin.setupCloseButton(target: self, action: #selector(closeButtonTapped))
        let plusButton = UISetUpManager_NewPin.setupPlusButton(target: self, action: #selector(plusButtonTapped))
        let addImageButton = UISetUpManager_NewPin.setupAddImageButton(target: self, action: #selector(addImageButtonTapped))
        
        titleLabel = UISetUpManager_NewPin.setupTitleLabel()
        
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
    
    func configure(for pinType: PinType, with pinData: Data_Pin? = nil) {
        self.initialPinData = pinData
    }
    private func updateTitleLabel() {
        NewPinManager.titleLabelText = isNewPin ? "お気に入りの場所を登録" : "ピンを編集"
        titleLabel.text = NewPinManager.titleLabelText
    }
    
    enum PinType {
        case new
        case existing
    }
    
    private func updateUI() {
        updateTitleLabel()
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
        print("+が押されました")
        guard let coordinate = tappedCoordinate else {
            print("tappedCoordinateがnilです")
            return
        }
        
        // 画像の確認
        if selectedImages.isEmpty {
            print("選択された画像はありません")
        } else {
            print("選択された画像の数: \(selectedImages.count)")
            for (index, image) in selectedImages.enumerated() {
                print("画像 \(index + 1): \(image)")
            }
        }
        
        let pinData = Data_Pin(coordinate: coordinate,
                               title: titleTextField.text,
                               description: descriptionTextField.text,
                               images: selectedImages,
                               category: tappedCategory,
                               tags: tappedTags)
        
        delegate?.newPinManagerDidTapPlus(self, pinData: pinData,isValid: !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
                                          !(descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
                                          !(selectedImages.isEmpty ? tappedImages.isEmpty : false) &&
                                          !(tappedCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) &&
                                          !tappedTags.isEmpty)
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
