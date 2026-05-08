// RecipeTableViewCell.swift
// FlavourFeed

import UIKit

final class RecipeTableViewCell: UITableViewCell {

    static let reuseIdentifier = "RecipeTableViewCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(named: "CardBackground") ?? .secondarySystemBackground
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        return v
    }()

    let recipeImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        return l
    }()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white
        l.backgroundColor = UIColor(named: "AccentOrange") ?? .systemOrange
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }()

    private let favouriteIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemRed
        return iv
    }()

    private let arrowIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(recipeImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryBadge)
        containerView.addSubview(favouriteIcon)
        containerView.addSubview(arrowIcon)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            recipeImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            recipeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            recipeImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            recipeImageView.widthAnchor.constraint(equalToConstant: 80),
            recipeImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: arrowIcon.leadingAnchor, constant: -8),

            categoryBadge.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 12),
            categoryBadge.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            categoryBadge.heightAnchor.constraint(equalToConstant: 22),
            categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            favouriteIcon.leadingAnchor.constraint(equalTo: categoryBadge.trailingAnchor, constant: 8),
            favouriteIcon.centerYAnchor.constraint(equalTo: categoryBadge.centerYAnchor),
            favouriteIcon.widthAnchor.constraint(equalToConstant: 16),
            favouriteIcon.heightAnchor.constraint(equalToConstant: 16),

            arrowIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowIcon.widthAnchor.constraint(equalToConstant: 10),
            arrowIcon.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    // MARK: - Configure

    func configure(with meal: MealSummary, category: String, isFavourited: Bool) {
        titleLabel.text = meal.strMeal
        categoryBadge.text = "  \(category)  "
        favouriteIcon.image = UIImage(systemName: isFavourited ? "heart.fill" : "heart")
        favouriteIcon.tintColor = isFavourited ? .systemRed : .systemGray3
        recipeImageView.image = nil

        MealAPIService.shared.loadImage(from: meal.strMealThumb) { [weak self] image in
            self?.recipeImageView.image = image
        }
    }

    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        categoryBadge.text = "  \(recipe.category)  "
        favouriteIcon.image = UIImage(systemName: "heart.fill")
        favouriteIcon.tintColor = .systemRed
        recipeImageView.image = nil

        MealAPIService.shared.loadImage(from: recipe.thumbnailURL) { [weak self] image in
            self?.recipeImageView.image = image
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = nil
        titleLabel.text = nil
        categoryBadge.text = nil
    }
}
