// FeedTableViewCell.swift
// FlavourFeed

import UIKit

protocol FeedCellDelegate: AnyObject {
    func didTapLike(on cell: FeedTableViewCell)
}

final class FeedTableViewCell: UITableViewCell {

    static let reuseIdentifier = "FeedTableViewCell"
    weak var delegate: FeedCellDelegate?

    // MARK: - UI

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let userAvatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 18
        iv.clipsToBounds = true
        return iv
    }()

    private let usernameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .label
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        return l
    }()

    let foodImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let recipeTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = .label
        return l
    }()

    private let categoryLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = UIColor(named: "AccentOrange") ?? .systemOrange
        return l
    }()

    private lazy var likeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.tintColor = .systemGray
        b.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        return b
    }()

    private let likesLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
    }()

    private let commentsIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "bubble.right")
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
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

    // MARK: - Layout

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)

        [userAvatarImageView, usernameLabel, timeLabel,
         foodImageView, recipeTitleLabel, categoryLabel,
         likeButton, likesLabel, commentsIcon, commentsLabel].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            userAvatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            userAvatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 36),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 36),

            usernameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            usernameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 10),

            timeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 10),

            foodImageView.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: 10),
            foodImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            foodImageView.heightAnchor.constraint(equalToConstant: 200),

            recipeTitleLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 12),
            recipeTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            recipeTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            categoryLabel.topAnchor.constraint(equalTo: recipeTitleLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),

            likeButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            likeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            likeButton.widthAnchor.constraint(equalToConstant: 28),
            likeButton.heightAnchor.constraint(equalToConstant: 28),

            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likesLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),

            commentsIcon.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentsIcon.leadingAnchor.constraint(equalTo: likesLabel.trailingAnchor, constant: 16),
            commentsIcon.widthAnchor.constraint(equalToConstant: 22),
            commentsIcon.heightAnchor.constraint(equalToConstant: 22),

            commentsLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentsLabel.leadingAnchor.constraint(equalTo: commentsIcon.trailingAnchor, constant: 4),
        ])
    }

    // MARK: - Configure

    func configure(with post: FeedPost) {
        usernameLabel.text = "@\(post.username)"
        timeLabel.text = post.timeAgo
        recipeTitleLabel.text = post.recipeTitle
        categoryLabel.text = "\(post.category.emoji) \(post.category.rawValue)"
        likesLabel.text = "\(post.likesCount)"
        commentsLabel.text = "\(post.commentsCount)"

        let heartImage = post.isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartImage), for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : .systemGray

        foodImageView.image = nil
        MealAPIService.shared.loadImage(from: post.imageURL) { [weak self] image in
            self?.foodImageView.image = image
        }
    }

    @objc private func likeTapped() {
        delegate?.didTapLike(on: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        foodImageView.image = nil
    }
}
