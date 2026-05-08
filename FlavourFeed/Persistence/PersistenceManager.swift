// PersistenceManager.swift
// FlavourFeed

import Foundation

// MARK: - Protocol

protocol DataPersisting {
    func saveFavourites(_ recipes: [Recipe])
    func loadFavourites() -> [Recipe]
    func saveUserProfile(_ profile: UserProfile)
    func loadUserProfile() -> UserProfile
    func toggleFavourite(_ recipe: Recipe) -> Bool
    func isFavourited(id: String) -> Bool
}

// MARK: - Persistence Manager

final class PersistenceManager: DataPersisting {

    static let shared = PersistenceManager()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let favourites   = "ff_favourites"
        static let userProfile  = "ff_user_profile"
    }

    // MARK: - Favourites

    func saveFavourites(_ recipes: [Recipe]) {
        guard let encoded = try? JSONEncoder().encode(recipes) else { return }
        defaults.set(encoded, forKey: Keys.favourites)
    }

    func loadFavourites() -> [Recipe] {
        guard let data = defaults.data(forKey: Keys.favourites),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return decoded
    }

    /// Toggles favourite status. Returns true if now favourited, false if removed.
    @discardableResult
    func toggleFavourite(_ recipe: Recipe) -> Bool {
        var favourites = loadFavourites()
        if let index = favourites.firstIndex(where: { $0.id == recipe.id }) {
            favourites.remove(at: index)
            saveFavourites(favourites)
            return false
        } else {
            var saved = recipe
            saved.isFavourited = true
            favourites.append(saved)
            saveFavourites(favourites)
            return true
        }
    }

    func isFavourited(id: String) -> Bool {
        return loadFavourites().contains(where: { $0.id == id })
    }

    // MARK: - User Profile

    func saveUserProfile(_ profile: UserProfile) {
        guard let encoded = try? JSONEncoder().encode(profile) else { return }
        defaults.set(encoded, forKey: Keys.userProfile)
    }

    func loadUserProfile() -> UserProfile {
        guard let data = defaults.data(forKey: Keys.userProfile),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return .default
        }
        return decoded
    }

    func updateRecipesSaved(count: Int) {
        var profile = loadUserProfile()
        profile.recipesSaved = count
        saveUserProfile(profile)
    }
}
