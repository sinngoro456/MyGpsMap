import UIKit
import CoreLocation
import EventKit

protocol NewPinManagerDelegate: AnyObject {
    func newPinManagerDidTapPlus(_ controller: NewPinManager, pinData: Data_Pin)
    func newPinManagerDidTapClose(_ controller: NewPinManager, pinData: Data_Pin)
}

class NewPinManager: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: NewPinManagerDelegate?
    private var imageScrollView: UIScrollView!
    private var imageStackView: UIStackView!
    private let eventStore = EKEventStore()
    private var datePicker: UIDatePicker!
    var titleTextField: UITextField!
    var descriptionTextField: UITextField!
    var tappedId: Int = 0
    var tappedCoordinate: CLLocationCoordinate2D?
    var tappedTitle: String = ""
    var tappedDescription: String = ""
    var tappedImages: [UIImage] = []
    var tappedDate: Date?
    var tappedCategory: String = ""
    var tappedTags: [String] = []
    var selectedTitle: String = ""
    var selectedDescription: String = ""
    var selectedColor: UIColor = .orange
    var selectedImages: [UIImage] = []
    var selectedDate: Date?
    var selectedCategory: String = ""
    var selectedTags: [String] = []
    private var titleLabel: UILabel!
    private var initialPinData: Data_Pin?
    static var titleLabelText: String = "お気に入りの場所を登録"
    var isNewPin: Bool = true  // デフォルトは新しいピン
    
    init(pinData: Data_Pin) {
        super.init(nibName: nil, bundle: nil)
        self.tappedId = pinData.id ?? 0
        self.tappedCoordinate = pinData.coordinate
        self.tappedTitle = pinData.title ?? ""
        self.tappedDescription = pinData.description ?? ""
        self.tappedImages = pinData.images
        self.tappedDate = pinData.date
        self.tappedCategory = pinData.category ?? ""
        self.tappedTags = pinData.tags ?? []
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeValues()
    }
    private func setupUI() {
        view.backgroundColor = .white
        let closeButton = UISetUpManager_NewPin.setupCloseButton(target: self, action: #selector(closeButtonTapped))
        let plusButton = UISetUpManager_NewPin.setupPlusButton(target: self, action: #selector(plusButtonTapped))
        let addImageButton = UISetUpManager_NewPin.setupAddImageButton(target: self, action: #selector(addImageButtonTapped))
        
        titleLabel = UISetUpManager_NewPin.setupTitleLabel()
        
        titleTextField = UISetUpManager_NewPin.setupTextField(placeholder: "タイトル", autocapitalizationType: .allCharacters)
        titleTextField.delegate = self
        if self.tappedTitle == "新しいピン" {
            titleTextField.text = ""
        } else {
            titleTextField.text = self.tappedTitle
        }
        
        descriptionTextField = UISetUpManager_NewPin.setupTextField(placeholder: "コメント")
        descriptionTextField.delegate = self
        
        imageScrollView = UISetUpManager_NewPin.setupImageScrollView()
        imageStackView = UISetUpManager_NewPin.setupImageStackView()
        
        datePicker = UISetUpManager_NewPin.setupDatePicker()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
                
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView, datePicker].forEach { view.addSubview($0) }
        imageScrollView.addSubview(imageStackView)
        
        [titleLabel, closeButton, plusButton, titleTextField, descriptionTextField, addImageButton, imageScrollView, imageStackView, datePicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        UISetUpManager_NewPin.setupConstraints(for: view, titleLabel: titleLabel, closeButton: closeButton, plusButton: plusButton, titleTextField: titleTextField, descriptionTextField: descriptionTextField, addImageButton: addImageButton, datePicker: datePicker, imageScrollView: imageScrollView, imageStackView: imageStackView)
    }
    
    private func initializeValues() {
        titleTextField.text = self.tappedTitle
        print(self.tappedDescription)
        descriptionTextField.text = self.tappedDescription
        selectedImages = self.tappedImages
        // datePickerに日付を設定
        if let date = tappedDate {
            datePicker.date = date
        }
        updateImageScrollView()
    }
    
    @objc func addImageButtonTapped() {
        print("image")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @objc func plusButtonTapped() {
        print("+が押されました")
        guard let coordinate = tappedCoordinate else {
            print("tappedCoordinateがnilです")
            return
        }
        
        let pinData = Data_Pin(id: tappedId,
                               coordinate: coordinate,
                               title: titleTextField.text,
                               description: descriptionTextField.text,
                               color: selectedColor,
                               images: selectedImages,
                               date: datePicker.date,
                               category: tappedCategory,
                               tags: tappedTags)
        
        delegate?.newPinManagerDidTapPlus(self, pinData: pinData)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        print("ピンを削除しました")
        guard let coordinate = tappedCoordinate else {
            print("tappedCoordinateがnilです")
            return
        }
        
        let pinData = Data_Pin(id: tappedId,coordinate: coordinate,
                               title: titleTextField.text,
                               description: descriptionTextField.text,
                               color: selectedColor,
                               images: selectedImages,
                               category: tappedCategory,
                               tags: tappedTags)
        
        delegate?.newPinManagerDidTapClose(self,pinData: pinData)
        dismiss(animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
