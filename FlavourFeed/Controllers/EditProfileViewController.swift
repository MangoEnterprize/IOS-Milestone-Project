// EditProfileViewController.swift
// FlavourFeed

import UIKit

protocol EditProfileDelegate: AnyObject {
    func didUpdateProfile(_ profile: UserProfile)
}

final class EditProfileViewController: UIViewController {

    // MARK: - Properties (data passed in)

    var profile: UserProfile = .default
    weak var delegate: EditProfileDelegate?

    // MARK: - UI

    private var tableView: UITableView!
    private var displayNameField: UITextField!
    private var usernameField: UITextField!
    private var bioField: UITextView!
    private var categoryPicker: UIPickerView!

    private enum Row: Int, CaseIterable {
        case displayName, username, bio, category
        var title: String {
            switch self {
            case .displayName: return "Display Name"
            case .username:    return "Username"
            case .bio:         return "Bio"
            case .category:    return "Favourite Category"
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .systemGroupedBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self, action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self, action: #selector(saveTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange

        setupTableView()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EditCell")
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        var updated = profile
        updated.displayName = displayNameField?.text?.trimmingCharacters(in: .whitespaces) ?? profile.displayName
        updated.username = usernameField?.text?.trimmingCharacters(in: .whitespaces) ?? profile.username
        updated.bio = bioField?.text ?? profile.bio

        if let picker = categoryPicker {
            let selectedRow = picker.selectedRow(inComponent: 0)
            updated.favouriteCategory = MealCategory.allCases[selectedRow]
        }

        if updated.displayName.isEmpty || updated.username.isEmpty {
            let alert = UIAlertController(title: "Required", message: "Name and username cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        delegate?.didUpdateProfile(updated)
        dismiss(animated: true)
    }
}

// MARK: - TableView DataSource

extension EditProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Profile Info"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath)
        cell.selectionStyle = .none

        switch Row(rawValue: indexPath.row)! {

        case .displayName:
            let field = makeTextField(placeholder: "Display Name", text: profile.displayName)
            displayNameField = field
            cell.contentView.addSubview(field)
            pinToCell(field, in: cell)

        case .username:
            let field = makeTextField(placeholder: "Username", text: profile.username)
            field.autocapitalizationType = .none
            usernameField = field
            cell.contentView.addSubview(field)
            pinToCell(field, in: cell)

        case .bio:
            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.text = profile.bio
            textView.font = UIFont.systemFont(ofSize: 15)
            textView.backgroundColor = .clear
            bioField = textView
            cell.contentView.addSubview(textView)
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
                textView.heightAnchor.constraint(equalToConstant: 80),
            ])

        case .category:
            let picker = UIPickerView()
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.delegate = self
            picker.dataSource = self
            categoryPicker = picker
            if let idx = MealCategory.allCases.firstIndex(of: profile.favouriteCategory) {
                picker.selectRow(idx, inComponent: 0, animated: false)
            }
            cell.contentView.addSubview(picker)
            NSLayoutConstraint.activate([
                picker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                picker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                picker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                picker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                picker.heightAnchor.constraint(equalToConstant: 120),
            ])
        }

        return cell
    }

    private func makeTextField(placeholder: String, text: String) -> UITextField {
        let f = UITextField()
        f.translatesAutoresizingMaskIntoConstraints = false
        f.placeholder = placeholder
        f.text = text
        f.font = UIFont.systemFont(ofSize: 15)
        f.borderStyle = .none
        f.clearButtonMode = .whileEditing
        return f
    }

    private func pinToCell(_ field: UITextField, in cell: UITableViewCell) {
        NSLayoutConstraint.activate([
            field.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            field.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            field.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            field.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

extension EditProfileViewController: UITableViewDelegate {}

// MARK: - UIPickerView

extension EditProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MealCategory.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let cat = MealCategory.allCases[row]
        return "\(cat.emoji) \(cat.rawValue)"
    }
}
