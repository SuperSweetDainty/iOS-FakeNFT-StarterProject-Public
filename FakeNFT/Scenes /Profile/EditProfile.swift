import UIKit
import PhotosUI

// MARK: - EditProfileViewController

final class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let user: User
    private let onSave: (User) -> Void
    private let onCancel: () -> Void
    
    private var editedUser: User
    private var currentAvatarImage: UIImage?
    private var avatarWasRemoved: Bool = false
    private var hasChanges: Bool = false {
        didSet {
            updateSaveButtonVisibility()
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var photoChangerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .photoChanger)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(hexString: "1A1B22")
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Имя"
        textField.font = .bodyRegular
        textField.textColor = UIColor(hexString: "1A1B22")
        textField.borderStyle = .none
        textField.backgroundColor = .segmentInactive
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(hexString: "1A1B22")
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .bodyRegular
        textView.textColor = UIColor(hexString: "1A1B22")
        textView.backgroundColor = .segmentInactive
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.text = "Сайт"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(hexString: "1A1B22")
        return label
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Веб-сайт"
        textField.font = .bodyRegular
        textField.textColor = UIColor(hexString: "1A1B22")
        textField.borderStyle = .none
        textField.backgroundColor = .segmentInactive
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 0
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hexString: "1A1B22")
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.isHidden = true
        return button
    }()
    
    internal lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(user: User, currentAvatarImage: UIImage?, onSave: @escaping (User) -> Void, onCancel: @escaping () -> Void) {
        self.user = user
        self.editedUser = user
        self.currentAvatarImage = currentAvatarImage
        self.onSave = onSave
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        populateFields()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .background
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hexString: "1A1B22")
        
        // Hide navigation bar title
        navigationItem.title = ""
        
        // Add all subviews
        [scrollView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [avatarImageView, photoChangerImageView, nameLabel, nameTextField, descriptionLabel, descriptionTextView, websiteLabel, websiteTextField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // PhotoChanger
            photoChangerImageView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 0),
            photoChangerImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 0),
            photoChangerImageView.widthAnchor.constraint(equalToConstant: 24),
            photoChangerImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Name TextField
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Description TextView
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Website Label
            websiteLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            websiteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Website TextField
            websiteTextField.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 8),
            websiteTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            websiteTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            websiteTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Save Button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let contentViewHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow
        contentViewHeightConstraint.isActive = true
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add tap gestures to avatar and photo changer
        let avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(avatarTapGesture)
        
        let photoChangerTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoChangerTapped))
        photoChangerImageView.addGestureRecognizer(photoChangerTapGesture)
        
        // Add text change observers
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        websiteTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Add tap gesture to website field
        let websiteTapGesture = UITapGestureRecognizer(target: self, action: #selector(websiteFieldTapped))
        websiteTextField.addGestureRecognizer(websiteTapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange),
            name: UITextView.textDidChangeNotification,
            object: descriptionTextView
        )
    }
    
    private func populateFields() {
        nameTextField.text = user.name
        descriptionTextView.text = user.description
        websiteTextField.text = user.website?.absoluteString
        
        // Set up avatar - display current avatar if available, otherwise placeholder
        if let currentAvatarImage = currentAvatarImage {
            avatarImageView.image = currentAvatarImage
            avatarImageView.tintColor = nil
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }
        avatarWasRemoved = false // Reset removal flag
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        if hasChanges {
            presentExitConfirmation()
        } else {
            onCancel()
        }
    }
    
    @objc private func avatarTapped() {
        presentAvatarActionSheet()
    }
    
    @objc private func photoChangerTapped() {
        presentAvatarActionSheet()
    }
    
    @objc private func textFieldDidChange() {
        checkForChanges()
    }
    
    @objc private func textViewDidChange() {
        checkForChanges()
    }
    
    @objc private func websiteFieldTapped() {
        presentWebsiteAlert()
    }
    
    @objc private func saveButtonTapped() {
        saveProfile()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Private Methods
    
    private func presentImagePicker() {
        if #available(iOS 14.0, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Fallback to UIImagePickerController for iOS 13
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    private func saveProfile() {
        // Validate input
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError(ErrorModel(
                message: "Имя не может быть пустым",
                actionText: "OK",
                action: {}
            ))
            return
        }
        
        // Validate website URL if provided
        let websiteText = websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !websiteText.isEmpty {
            guard URL(string: websiteText) != nil else {
                showError(ErrorModel(
                    message: "Неверный формат URL",
                    actionText: "OK",
                    action: {}
                ))
                return
            }
        }
        
        // Create updated user
        let updatedUser = User(
            id: user.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
            avatar: user.avatar, // Keep existing avatar for now
            website: URL(string: websiteText),
            nfts: user.nfts,
            likes: user.likes
        )
        
        editedUser = updatedUser
        
        // Show loading
        showLoading()
        saveButton.isEnabled = false
        
        // Simulate network delay with error handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if Bool.random() && Int.random(in: 1...10) <= 1 {
                self?.hideLoading()
                self?.saveButton.isEnabled = true
                self?.showError(ErrorModel(
                    message: "Ошибка сети. Проверьте подключение к интернету.",
                    actionText: "Повторить",
                    action: { [weak self] in
                        self?.saveProfile()
                    }
                ))
            } else {
                self?.hideLoading()
                self?.saveButton.isEnabled = true
                self?.onSave(updatedUser)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - New Methods
    
    private func updateSaveButtonVisibility() {
        saveButton.isHidden = !hasChanges
    }
    
    private func checkForChanges() {
        let nameChanged = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != user.name
        let descriptionChanged = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines) != user.description
        let websiteChanged = websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != (user.website?.absoluteString ?? "")
        let avatarChanged = currentAvatarImage != nil || avatarWasRemoved // Avatar changed if we have a new image or it was removed
        
        hasChanges = nameChanged || descriptionChanged || websiteChanged || avatarChanged
    }
    
    private func presentAvatarActionSheet() {
        let actionSheet = UIAlertController(title: "Фото профиля", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Изменить фото", style: .default) { [weak self] _ in
            self?.presentImagePicker()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Удалить фото", style: .destructive) { [weak self] _ in
            self?.removeAvatar()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentWebsiteAlert() {
        let alert = UIAlertController(title: "Ссылка на фото", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Введите ссылку"
            textField.text = self.websiteTextField.text
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first, let text = textField.text {
                self?.websiteTextField.text = text
                self?.checkForChanges()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    private func presentExitConfirmation() {
        let alert = UIAlertController(title: "Уверены, что хотите выйти?", message: nil, preferredStyle: .alert)
        
        let stayAction = UIAlertAction(title: "Остаться", style: .default)
        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.onCancel()
        }
        
        alert.addAction(stayAction)
        alert.addAction(exitAction)
        
        present(alert, animated: true)
    }
    
    private func removeAvatar() {
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray3
        currentAvatarImage = nil
        avatarWasRemoved = true
        checkForChanges()
        
        // Send notification about avatar removal
        let notification = ["image": NSNull()]
        NotificationCenter.default.post(
            name: .avatarDidChange,
            object: notification
        )
    }
}

// MARK: - ErrorView & LoadingView

extension EditProfileViewController: ErrorView, LoadingView {
    // ErrorView and LoadingView implementations are inherited from the protocols
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension EditProfileViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.avatarImageView.image = image
                    self?.currentAvatarImage = image
                    self?.avatarImageView.tintColor = nil
                    self?.avatarWasRemoved = false
                    self?.checkForChanges()
                    
                    // Send notification about avatar change
                    let notification = ["image": image]
                    NotificationCenter.default.post(
                        name: .avatarDidChange,
                        object: notification
                    )
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[.editedImage] as? UIImage {
            avatarImageView.image = editedImage
            currentAvatarImage = editedImage
            avatarImageView.tintColor = nil
            avatarWasRemoved = false
            checkForChanges()
            
            // Send notification about avatar change
            let notification = ["image": editedImage]
            NotificationCenter.default.post(
                name: .avatarDidChange,
                object: notification
            )
        } else if let originalImage = info[.originalImage] as? UIImage {
            avatarImageView.image = originalImage
            currentAvatarImage = originalImage
            avatarImageView.tintColor = nil
            avatarWasRemoved = false
            checkForChanges()
            
            // Send notification about avatar change
            let notification = ["image": originalImage]
            NotificationCenter.default.post(
                name: .avatarDidChange,
                object: notification
            )
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
