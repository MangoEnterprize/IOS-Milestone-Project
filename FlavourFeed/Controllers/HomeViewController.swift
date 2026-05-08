// HomeViewController.swift
// FlavourFeed - Tab 1: Social Feed

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private var posts: [FeedPost] = MockData.feedPosts
    private var tableView: UITableView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "FlavourFeed"
        navigationController?.navigationBar.prefersLargeTitles = true

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AccentOrange") ?? UIColor.systemOrange,
            .font: UIFont.systemFont(ofSize: 28, weight: .heavy)
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = attrs

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
        searchButton.tintColor = UIColor(named: "AccentOrange") ?? .systemOrange
        navigationItem.rightBarButtonItem = searchButton
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.showsVerticalScrollIndicator = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func searchTapped() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath
        ) as? FeedTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to search/browse for now (feed posts are mock data)
        let post = posts[indexPath.row]
        let searchVC = SearchViewController()
        searchVC.preloadCategory = post.category.rawValue
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

// MARK: - FeedCellDelegate

extension HomeViewController: FeedCellDelegate {

    func didTapLike(on cell: FeedTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        posts[indexPath.row].isLiked.toggle()
        posts[indexPath.row].likesCount += posts[indexPath.row].isLiked ? 1 : -1

        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
