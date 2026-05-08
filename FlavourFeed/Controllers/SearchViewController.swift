// SearchViewController.swift
// FlavourFeed - Tab 2: Browse & Search Recipes

import UIKit

final class SearchViewController: UIViewController {

    // MARK: - Properties

    var preloadCategory: String?

    private var meals: [MealSummary] = []
    private var filteredMeals: [MealSummary] = []
    private var selectedCategory: MealCategory = .chicken
    private var isLoading = false

    // MARK: - UI

    private var tableView: UITableView!
    private var categoryCollectionView: UICollectionView!
    private var searchBar: UISearchBar!
    private var activityIndicator: UIActivityIndicatorView!
    private var emptyStateLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = true

        setupSearchBar()
        setupCategoryCollection()
        setupTableView()
        setupActivityIndicator()
        setupEmptyState()

        if let preload = preloadCategory,
           let cat = MealCategory(rawValue: preload) {
            selectedCategory = cat
        }

        fetchRecipes(for: selectedCategory)
    }

    // MARK: - Setup UI

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search recipes..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
    }

    private func setupCategoryCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 90, height: 36)
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryChipCell.self, forCellWithReuseIdentifier: CategoryChipCell.reuseID)
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(categoryCollectionView)

        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

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
            tableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(named: "AccentOrange") ?? .systemOrange
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupEmptyState() {
        emptyStateLabel = UILabel()
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No recipes found"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: 17)
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Data

    private func fetchRecipes(for category: MealCategory) {
        isLoading = true
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateLabel.isHidden = true

        MealAPIService.shared.fetchMeals(for: category.rawValue) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false

            switch result {
            case .success(let meals):
                self.meals = meals
                self.filteredMeals = meals
                self.emptyStateLabel.isHidden = !meals.isEmpty
                self.tableView.reloadData()
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func filterMeals(query: String) {
        if query.isEmpty {
            filteredMeals = meals
        } else {
            filteredMeals = meals.filter { $0.strMeal.lowercased().contains(query.lowercased()) }
        }
        emptyStateLabel.isHidden = !filteredMeals.isEmpty
        tableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecipeTableViewCell.reuseIdentifier, for: indexPath
        ) as? RecipeTableViewCell else { return UITableViewCell() }

        let meal = filteredMeals[indexPath.row]
        let isFav = PersistenceManager.shared.isFavourited(id: meal.idMeal)
        cell.configure(with: meal, category: selectedCategory.rawValue, isFavourited: isFav)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meal = filteredMeals[indexPath.row]
        let detailVC = RecipeDetailViewController()
        detailVC.mealID = meal.idMeal
        detailVC.mealTitle = meal.strMeal
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CollectionView (Category Chips)

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MealCategory.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryChipCell.reuseID, for: indexPath
        ) as? CategoryChipCell else { return UICollectionViewCell() }

        let cat = MealCategory.allCases[indexPath.item]
        cell.configure(with: cat, isSelected: cat == selectedCategory)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cat = MealCategory.allCases[indexPath.item]
        guard cat != selectedCategory else { return }
        selectedCategory = cat
        collectionView.reloadData()
        fetchRecipes(for: cat)
    }
}

// MARK: - SearchBar Delegate

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMeals(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - CategoryChipCell

final class CategoryChipCell: UICollectionViewCell {

    static let reuseID = "CategoryChipCell"

    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 14
        contentView.layer.borderWidth = 1.5
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with category: MealCategory, isSelected: Bool) {
        label.text = "\(category.emoji) \(category.rawValue)"
        let accent = UIColor(named: "AccentOrange") ?? .systemOrange
        if isSelected {
            contentView.backgroundColor = accent
            contentView.layer.borderColor = accent.cgColor
            label.textColor = .white
        } else {
            contentView.backgroundColor = .secondarySystemBackground
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            label.textColor = .label
        }
    }
}
