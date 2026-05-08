// ProfileViewController.swift
// FlavourFeed - Tab 4: User Profile

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Properties

    private var profile: UserProfile = PersistenceManager.shared.loadUserProfile()
    private var tableView: UITableView!

    private enum Section: Int, CaseIterable {
        case header, stats, preferences, about
        var title: String? {
            switch self {
            case .header: return nil
            case .stats: return "My Activity"
            case .preferences: return "Preferences"
            case .about: return "About"
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true

        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        editButton.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange
        navigationItem.rightBarButtonItem = editButton

        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profile = PersistenceManager.shared.loadUserProfile()
        tableView.reloadData()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: ProfileHeaderCell.reuseID)
        tableView.register(StatCell.self, forCellReuseIdentifier: StatCell.reuseID)
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func editTapped() {
        let editVC = EditProfileViewController()
        editVC.profile = profile
        editVC.delegate = self
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
    }
}

// MARK: - TableView DataSource

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:      return 1
        case .stats:       return 2
        case .preferences: return 1
        case .about:       return 2
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {

        case .header:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileHeaderCell.reuseID, for: indexPath
            ) as? ProfileHeaderCell else { return UITableViewCell() }
            cell.configure(with: profile)
            return cell

        case .stats:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StatCell.reuseID, for: indexPath
            ) as? StatCell else { return UITableViewCell() }
            if indexPath.row == 0 {
                cell.configure(icon: "heart.fill", title: "Saved Recipes", value: "\(PersistenceManager.shared.loadFavourites().count)")
            } else {
                cell.configure(icon: "calendar", title: "Member Since", value: formattedDate(profile.joinDate))
            }
            return cell

        case .preferences:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            cell.textLabel?.text = "Favourite Category"
            let cat = profile.favouriteCategory
            cell.detailTextLabel?.text = "\(cat.emoji) \(cat.rawValue)"
            cell.accessoryType = .disclosureIndicator
            return cell

        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "FlavourFeed"
                cell.detailTextLabel?.text = "Version 1.0"
            } else {
                cell.textLabel?.text = "API"
                cell.detailTextLabel?.text = "TheMealDB"
            }
            return cell
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}

// MARK: - TableView Delegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 140 }
        return 52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - EditProfileDelegate

extension ProfileViewController: EditProfileDelegate {
    func didUpdateProfile(_ profile: UserProfile) {
        self.profile = profile
        PersistenceManager.shared.saveUserProfile(profile)
        tableView.reloadData()
    }
}

// MARK: - ProfileHeaderCell

final class ProfileHeaderCell: UITableViewCell {

    static let reuseID = "ProfileHeaderCell"

    private let avatarView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = (UIColor(named: "AccentOrange") ?? .systemOrange).withAlphaComponent(0.15)
        v.layer.cornerRadius = 36
        return v
    }()

    private let avatarLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 36)
        l.textAlignment = .center
        l.text = "👨‍🍳"
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textColor = .label
        return l
    }()

    private let usernameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()

    private let bioLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        avatarView.addSubview(avatarLabel)
        [avatarView, nameLabel, usernameLabel, bioLabel].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 72),
            avatarView.heightAnchor.constraint(equalToConstant: 72),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),

            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with profile: UserProfile) {
        nameLabel.text = profile.displayName
        usernameLabel.text = "@\(profile.username)"
        bioLabel.text = profile.bio
    }
}

// MARK: - StatCell

final class StatCell: UITableViewCell {

    static let reuseID = "StatCell"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = .label
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = UIColor(named: "AccentOrange") ?? .systemOrange
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        [iconView, titleLabel, valueLabel].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(icon: String, title: String, value: String) {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        valueLabel.text = value
    }
}
