import UIKit
import CoreLocation

class ViewController_NewPin: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ViewController_NewPinDelegate?
    private var titleTextField: UITextField!
    private var descriptionTextField: UITextField!
    var tappedCoordinate: CLLocationCoordinate2D?
    
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
        
        // Auto Layout の設定
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        
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
            descriptionTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
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
    
    // UITextFieldDelegate method to dismiss keyboard when return is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol ViewController_NewPinDelegate: AnyObject {
    func viewController_NewPinDidTapPlus(_ controller: ViewController_NewPin, title: String?, description: String?)
    func viewController_NewPinDidTapClose(_ controller: ViewController_NewPin)
}
