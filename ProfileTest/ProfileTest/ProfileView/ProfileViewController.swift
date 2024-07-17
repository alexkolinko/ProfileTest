//
//  ProfileViewController.swift
//  ProfileTest
//
//  Created by kolinko oleksandr on 16.07.2024.
//


import UIKit

class ProfileViewController: UIViewController {
    
    // - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var fullNameContentView: UIView!
    @IBOutlet weak var fullNameTitle: UILabel!
    @IBOutlet weak var fullNameField: UITextField!
    
    @IBOutlet weak var genderContentView: UIView!
    @IBOutlet weak var genderTitle: UILabel!
    @IBOutlet weak var genderValue: UILabel!
    
    @IBOutlet weak var birthdayContentView: UIView!
    @IBOutlet weak var birthdayTitle: UILabel!
    @IBOutlet weak var birthdayValue: UILabel!
    
    @IBOutlet weak var phoneContentView: UIView!
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var emailContentView: UIView!
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var userNameContentView: UIView!
    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // - Internal properties
    private let genders = Gender.allCases
    private var selectedGender: Gender = .male
    private var selectedImageData: Data?
    private var selectedBirthday: Date?
    private var item: ProfileData?
    
    private let defaultPhonePrefix = "+"
    private let defaultNamePrefix = "@"
    private let phoneMask = "(+XXX) XXXXXXXXX"
    private let phonePattern = "^\\(\\+\\d{3}\\) \\d{8,9}$"
    private let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private let dateFormat = "dd-MM-yyyy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedBirthday = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        self.item = DataManager.getProfile()
        
        self.setupUI()
        self.setupNavigationBar()
        self.setupDetailsContent()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func birthdayContentViewTapped() {
        let alert = UIAlertController(title: "Select Birthday", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let pickerFrame = UIDatePicker()
        pickerFrame.datePickerMode = .date
        pickerFrame.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        pickerFrame.preferredDatePickerStyle = .wheels
        
        // Add picker to alert
        alert.view.addSubview(pickerFrame)
        
        // Add constraints to center the picker
        pickerFrame.translatesAutoresizingMaskIntoConstraints = false
        pickerFrame.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        pickerFrame.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -160).isActive = true
        pickerFrame.widthAnchor.constraint(equalTo: alert.view.widthAnchor).isActive = true
        pickerFrame.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            let date = pickerFrame.date
            self.birthdayValue.text = date.toString(withFormat: self.dateFormat)
            self.selectedBirthday = date
        }
        alert.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func genderContentViewTapped() {
        let alert = UIAlertController(title: "Select Gender", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 50, width: alert.view.bounds.width, height: 140))
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alert.view.addSubview(pickerFrame)
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            let selectedRow = pickerFrame.selectedRow(inComponent: 0)
            self.genderValue.text = self.genders[selectedRow].rawValue
        }
        alert.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        // Adjust content inset to show the text field being edited
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        if let activeField = findActiveField() {
            var visibleRect = view.frame
            visibleRect.size.height -= keyboardSize.height
            let activeFieldRect = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(activeFieldRect, animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset content inset when keyboard is hidden
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let isFullName = validateFullName()
        let isPhone = validatePhone()
        let isEmail = validateEmail()
        let isUserName = validateUserName()
        
        guard
            let fullName = isFullName,
            let phone = isPhone,
            let email = isEmail,
            let userName = isUserName,
            let birthday = self.selectedBirthday
        else { return }
        let user = ProfileData(imageData: self.selectedImageData, fullName: fullName, gender: self.selectedGender, birthday: birthday, phone: phone, email: email, userName: userName)
        DataManager.saveProfile(user)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ProfileViewController + private
private extension ProfileViewController {
    
    func setupDetailsContent() {
        
        fullNameTitle.text = "Full name"
        genderTitle.text = "Gender"
        birthdayTitle.text = "Birthday"
        phoneTitle.text = "Phone number"
        emailTitle.text = "Email"
        userNameTitle.text = "User name"
        
        fullNameField.placeholder = "Required full name"
        phoneField.placeholder = "Required phone number"
        emailField.placeholder = "Required email"
        userNameField.placeholder = "Required user name"
        
        guard let model = item else {
            profileImage.image = UIImage(named: "profile_ic")
            genderValue.text = selectedGender.rawValue
            birthdayValue.text = selectedBirthday?.toString(withFormat: self.dateFormat)
            userFullNameLabel.isHidden = true
            userNameLabel.isHidden = true
            return
        }
        
        userFullNameLabel.text = model.fullName
        userNameLabel.text = model.userName
        selectedImageData = model.imageData
        fullNameField.text = model.fullName
        genderValue.text = model.gender.rawValue
        birthdayValue.text = model.birthday.toString(withFormat: self.dateFormat)
        phoneField.text = model.phone
        emailField.text = model.email
        userNameField.text = model.userName
        
        if let imageData = model.imageData {
            profileImage.image = UIImage(data: imageData)
        } else {
            profileImage.image = UIImage(named: "profile_ic")
        }
    }
    
    // - UI Setup
    func setupUI() {
        
        fullNameTitle.textColor = .grayCustom
        genderTitle.textColor = .grayCustom
        birthdayTitle.textColor = .grayCustom
        phoneTitle.textColor = .grayCustom
        emailTitle.textColor = .grayCustom
        userNameTitle.textColor = .grayCustom
        
        phoneField.keyboardType = .numberPad
        phoneField.delegate = self
        userNameField.delegate = self
        
        setupRowContentView(fullNameContentView)
        setupRowContentView(genderContentView)
        setupRowContentView(birthdayContentView)
        setupRowContentView(phoneContentView)
        setupRowContentView(emailContentView)
        setupRowContentView(userNameContentView)
        
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        saveButton.layer.cornerRadius = 15.0
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        profileImage.addGestureRecognizer(tapImageGesture)
        profileImage.isUserInteractionEnabled = true
        
        let genderTapGesture = UITapGestureRecognizer(target: self, action: #selector(genderContentViewTapped))
        genderContentView.addGestureRecognizer(genderTapGesture)
        genderContentView.isUserInteractionEnabled = true
        genderValue.text = selectedGender.rawValue
        
        let birthdayTapGesture = UITapGestureRecognizer(target: self, action: #selector(birthdayContentViewTapped))
        birthdayContentView.addGestureRecognizer(birthdayTapGesture)
        birthdayContentView.isUserInteractionEnabled = true
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationLabel.text = "Edit Profile"
        self.backButton.backgroundColor = .grayCustom.withAlphaComponent(0.3)
        self.backButton.layer.cornerRadius = 12.0
    }
    
    func setupRowContentView(_ view: UIView) {
        view.layer.borderColor = UIColor.grayCustom.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 15.0
        view.layer.masksToBounds = true
    }
    
    func findActiveField() -> UIView? {
        if fullNameField.isFirstResponder {
            return fullNameContentView
        } else if phoneField.isFirstResponder {
            return phoneContentView
        } else if emailField.isFirstResponder {
            return emailContentView
        } else if userNameField.isFirstResponder {
            return userNameContentView
        }
        return nil
    }
    
    func validateFullName() -> String? {
        guard let text = fullNameField.text, !text.isEmpty else {
            fullNameContentView.layer.borderColor = UIColor.red.cgColor
            return nil
        }
        fullNameContentView.layer.borderColor = UIColor.grayCustom.cgColor
        return text
    }
    
    func validatePhone() -> String? {
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phonePattern)
        
        guard let phoneText = phoneField.text, phonePredicate.evaluate(with: phoneText) else {
            phoneContentView.layer.borderColor = UIColor.red.cgColor
            return nil
        }
        phoneContentView.layer.borderColor = UIColor.grayCustom.cgColor
        return phoneText
    }
    
    func validateEmail() -> String? {
        let emailRegex = try! NSRegularExpression(pattern: emailPattern)
        
        guard let emailText = emailField.text, (emailRegex.firstMatch(in: emailText, options: [], range: NSRange(location: 0, length: emailText.count)) != nil) else {
            emailContentView.layer.borderColor = UIColor.red.cgColor
            return nil
        }
        emailContentView.layer.borderColor = UIColor.grayCustom.cgColor
        return emailText
    }
    
    func validateUserName() -> String? {
        guard let text = userNameField.text, !text.isEmpty else {
            userNameContentView.layer.borderColor = UIColor.red.cgColor
            return nil
        }
        userNameContentView.layer.borderColor = UIColor.grayCustom.cgColor
        return text
    }
    
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var result = ""
        var index = cleanPhoneNumber.startIndex
        
        for ch in self.phoneMask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
        
    }
}

// MARK: - ProfileViewController: UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneField {
            let text = textField.text ?? ""
            if !text.contains(defaultPhonePrefix) {
                textField.text = defaultPhonePrefix
            }
        }
        
        if textField == userNameField {
            let text = textField.text ?? ""
            if !text.contains(defaultNamePrefix) {
                textField.text = defaultNamePrefix
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneField {
            let currentText = textField.text ?? ""
            let newString = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if !newString.isEmpty {
                let result = formattedNumber(number: newString)
                textField.text = result
            }
            
            return false
        }
        
        return true
    }
}

// MARK: - ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row].rawValue
    }
}

// MARK: - ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if var imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                var imageSize = Double(imageData.count) / 1024.0 / 1024.0
                
                // Compress the image until it is less than 2 MB
                var compressionQuality: CGFloat = 1.0
                while imageSize > 2.0 && compressionQuality > 0.01 {
                    compressionQuality -= 0.1
                    if let newImageData = pickedImage.jpegData(compressionQuality: compressionQuality) {
                        imageData = newImageData
                        imageSize = Double(imageData.count) / 1024.0 / 1024.0
                    }
                }
                selectedImageData = imageData
                profileImage.image = UIImage(data: imageData)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
