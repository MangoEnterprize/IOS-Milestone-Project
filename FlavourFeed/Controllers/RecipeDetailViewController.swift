// RecipeDetailViewController.swift
// FlavourFeed

import UIKit

final class RecipeDetailViewController: UIViewController {

    // MARK: - Properties (data passed in)

    var mealID: String = ""
    var mealTitle: String = ""

    private var recipe: Recipe?
    private var isFavourited: Bool = false
    private var ingredientsTableHeightConstraint: NSLayoutConstraint?

    // MARK: - UI

    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var heroImageView: UIImageView!
    private var titleLabel: UILabel!
    private var categoryAreaLabel: UILabel!
    private var tagsStackView: UIStackView!
    private var ingredientsHeaderLabel: UILabel!
    private var ingredientsTableView: UITableView!
    private var instructionsHeaderLabel: UILabel!
    private var instructionsLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    private var favouriteButton: UIBarButtonItem!
    private var ingredients: [String] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = mealTitle
        isFavourited = PersistenceManager.shared.isFavourited(id: mealID)
        setupNavigationBar()
        setupScrollLayout()
        fetchDetail()
    }

    // MARK: - Nav Bar

    private func setupNavigationBar() {
        let favImage = UIImage(systemName: isFavourited ? "heart.fill" : "heart")
        favouriteButton = UIBarButtonItem(
            image: favImage,
            style: .plain,
            target: self,
            action: #selector(favouriteTapped)
        )
        favouriteButton.tintColor = isFavourited ? .systemRed : UIColor(named: "AccentOrange") ?? .systemOrange

        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )
        shareButton.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange

        navigationItem.rightBarButtonItems = [shareButton, favouriteButton]
    }

    private func updateFavouriteButton() {
        let image = UIImage(systemName: isFavourited ? "heart.fill" : "heart")
        favouriteButton.image = image
        favouriteButton.tintColor = isFavourited ? .systemRed : UIColor(named: "AccentOrange") ?? .systemOrange

        // Preserve share button if present; otherwise recreate it
        let existingButtons = navigationItem.rightBarButtonItems
        let shareButton: UIBarButtonItem
        if let first = existingButtons?.first, first.action == #selector(shareTapped) {
            shareButton = first
        } else {
            let sb = UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(shareTapped)
            )
            sb.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange
            shareButton = sb
        }
        navigationItem.rightBarButtonItems = [shareButton, favouriteButton]
    }

    // MARK: - Scroll Layout

    private func setupScrollLayout() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Hero Image
        heroImageView = UIImageView()
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.backgroundColor = .systemGray5

        // Title
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label

        // Category/Area
        categoryAreaLabel = UILabel()
        categoryAreaLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryAreaLabel.font = UIFont.systemFont(ofSize: 14)
        categoryAreaLabel.textColor = .secondaryLabel

        // Tags
        tagsStackView = UIStackView()
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .center

        // Ingredients header
        ingredientsHeaderLabel = makeSectionHeader("Ingredients")

        // Ingredients table (static, embedded)
        ingredientsTableView = UITableView()
        ingredientsTableView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        ingredientsTableView.isScrollEnabled = false
        ingredientsTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        ingredientsTableView.layer.cornerRadius = 12
        ingredientsTableView.clipsToBounds = true

        // Instructions header
        instructionsHeaderLabel = makeSectionHeader("Instructions")

        // Instructions
        instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.font = UIFont.systemFont(ofSize: 15)
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .natural
        instructionsLabel.lineBreakStrategy = .standard

        // Activity Indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(named: "AccentOrange") ?? .systemOrange
        activityIndicator.startAnimating()

        [heroImageView, titleLabel, categoryAreaLabel, tagsStackView,
         ingredientsHeaderLabel, ingredientsTableView,
         instructionsHeaderLabel, instructionsLabel, activityIndicator].forEach {
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 280),

            titleLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryAreaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            categoryAreaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryAreaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tagsStackView.topAnchor.constraint(equalTo: categoryAreaLabel.bottomAnchor, constant: 10),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            ingredientsHeaderLabel.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 20),
            ingredientsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            ingredientsTableView.topAnchor.constraint(equalTo: ingredientsHeaderLabel.bottomAnchor, constant: 8),
            ingredientsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ingredientsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            instructionsHeaderLabel.topAnchor.constraint(equalTo: ingredientsTableView.bottomAnchor, constant: 20),
            instructionsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            instructionsLabel.topAnchor.constraint(equalTo: instructionsHeaderLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            instructionsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 300),
        ])
    }

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = text
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        return l
    }

    // MARK: - Fetch

    private func fetchDetail() {
        MealAPIService.shared.fetchMealDetail(id: mealID) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let detail):
                    let recipe = Recipe(from: detail)
                    self.recipe = recipe
                    self.isFavourited = PersistenceManager.shared.isFavourited(id: recipe.id)
                    self.populateUI(with: recipe)
                case .failure(let err):
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func populateUI(with recipe: Recipe) {
        titleLabel.text = recipe.title
        categoryAreaLabel.text = "🍽️ \(recipe.category)  •  🌍 \(recipe.area)"

        // Tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in recipe.tags.prefix(4) {
            let chip = makeTagChip(tag)
            tagsStackView.addArrangedSubview(chip)
        }

        // Ingredients
        ingredients = recipe.ingredients
        ingredientsTableView.reloadData()
        let tableHeight = CGFloat(ingredients.count) * 44
        if let existing = ingredientsTableHeightConstraint {
            existing.constant = tableHeight
        } else {
            let c = ingredientsTableView.heightAnchor.constraint(equalToConstant: tableHeight)
            c.isActive = true
            ingredientsTableHeightConstraint = c
        }

        instructionsLabel.text = recipe.instructions
        updateFavouriteButton()

        MealAPIService.shared.loadImage(from: recipe.thumbnailURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.heroImageView.image = image
            }
        }
    }

    private func makeTagChip(_ text: String) -> UIView {
        let chip = UILabel()
        chip.text = " \(text) "
        chip.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        chip.textColor = UIColor(named: "AccentOrange") ?? .systemOrange
        chip.backgroundColor = (UIColor(named: "AccentOrange") ?? .systemOrange).withAlphaComponent(0.12)
        chip.layer.cornerRadius = 8
        chip.clipsToBounds = true
        return chip
    }

    // MARK: - Actions

    @objc private func favouriteTapped() {
        guard let recipe = recipe else { return }
        isFavourited = PersistenceManager.shared.toggleFavourite(recipe)
        updateFavouriteButton()

        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        // Update saved count on profile
        let count = PersistenceManager.shared.loadFavourites().count
        PersistenceManager.shared.updateRecipesSaved(count: count)
    }

    @objc private func shareTapped() {
        guard let recipe = recipe else { return }
        let text = recipe.shareDescription
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }
}

// MARK: - Ingredients TableView

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        cell.textLabel?.text = "• " + ingredients[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
