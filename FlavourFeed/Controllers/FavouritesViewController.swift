// FavouritesViewController.swift
// FlavourFeed - Tab 3: Saved Recipes

import UIKit

final class FavouritesViewController: UIViewController {

    // MARK: - Properties

    private var favourites: [Recipe] = []
    private var tableView: UITableView!
    private var emptyStateView: EmptyFavouritesView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavourites()
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: RecipeTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupEmptyState() {
        emptyStateView = EmptyFavouritesView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
        ])
    }

    // MARK: - Data

    private func loadFavourites() {
        favourites = PersistenceManager.shared.loadFavourites()
        let isEmpty = favourites.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate

extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecipeTableViewCell.reuseIdentifier, for: indexPath
        ) as? RecipeTableViewCell else { return UITableViewCell() }
        cell.configure(with: favourites[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = favourites[indexPath.row]
        let detailVC = RecipeDetailViewController()
        detailVC.mealID = recipe.id
        detailVC.mealTitle = recipe.title
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Swipe to delete (unfavourite)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recipe = favourites[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            PersistenceManager.shared.toggleFavourite(recipe)
            self?.loadFavourites()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "heart.slash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Empty State View

final class EmptyFavouritesView: UIView {

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "🤍"
        l.font = UIFont.systemFont(ofSize: 56)
        l.textAlignment = .center
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No Saved Recipes"
        l.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Browse recipes and tap the heart to save your favourites here."
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
