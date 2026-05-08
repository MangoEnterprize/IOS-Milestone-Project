// Models.swift
// FlavourFeed - Social Recipe Networking App

import UIKit

// MARK: - Enums

enum MealCategory: String, CaseIterable, Codable {
    case beef       = "Beef"
    case chicken    = "Chicken"
    case dessert    = "Dessert"
    case pasta      = "Pasta"
    case seafood    = "Seafood"
    case vegetarian = "Vegetarian"
    case breakfast  = "Breakfast"
    case miscellaneous = "Miscellaneous"

    var emoji: String {
        switch self {
        case .beef:          return "🥩"
        case .chicken:       return "🍗"
        case .dessert:       return "🍰"
        case .pasta:         return "🍝"
        case .seafood:       return "🦐"
        case .vegetarian:    return "🥦"
        case .breakfast:     return "🍳"
        case .miscellaneous: return "🍽️"
        }
    }
}

enum AppError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:          return "Invalid URL."
        case .noData:              return "No data received."
        case .decodingError:       return "Failed to decode data."
        case .networkError(let m): return "Network error: \(m)"
        }
    }
}

// MARK: - API Response Models (Codable)

struct MealListResponse: Codable {
    let meals: [MealSummary]?
}

struct MealDetailResponse: Codable {
    let meals: [MealDetail]?
}

struct MealSummary: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
}

struct MealDetail: Codable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?

    // Dynamic ingredient/measure parsing
    var ingredients: [String] {
        var result: [String] = []
        let mirror = Mirror(reflecting: self)
        var measures: [String] = []

        for child in mirror.children {
            if let label = child.label, label.hasPrefix("strIngredient"),
               let value = child.value as? String?, let v = value, !v.isEmpty {
                result.append(v)
            }
        }
        for child in mirror.children {
            if let label = child.label, label.hasPrefix("strMeasure"),
               let value = child.value as? String?, let v = value, !v.isEmpty {
                measures.append(v)
            }
        }
        return zip(result, measures).map { "\($1.trimmingCharacters(in: .whitespaces)) \($0)" }
    }

    // Codable keys for all 20 ingredient/measure pairs
    enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strCategory, strArea, strInstructions
        case strMealThumb, strTags, strYoutube
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }

    // All ingredient/measure stored properties
    let strIngredient1: String?;  let strIngredient2: String?;  let strIngredient3: String?
    let strIngredient4: String?;  let strIngredient5: String?;  let strIngredient6: String?
    let strIngredient7: String?;  let strIngredient8: String?;  let strIngredient9: String?
    let strIngredient10: String?; let strIngredient11: String?; let strIngredient12: String?
    let strIngredient13: String?; let strIngredient14: String?; let strIngredient15: String?
    let strIngredient16: String?; let strIngredient17: String?; let strIngredient18: String?
    let strIngredient19: String?; let strIngredient20: String?
    let strMeasure1: String?;     let strMeasure2: String?;     let strMeasure3: String?
    let strMeasure4: String?;     let strMeasure5: String?;     let strMeasure6: String?
    let strMeasure7: String?;     let strMeasure8: String?;     let strMeasure9: String?
    let strMeasure10: String?;    let strMeasure11: String?;    let strMeasure12: String?
    let strMeasure13: String?;    let strMeasure14: String?;    let strMeasure15: String?
    let strMeasure16: String?;    let strMeasure17: String?;    let strMeasure18: String?
    let strMeasure19: String?;    let strMeasure20: String?
}

// MARK: - App Domain Models

protocol Shareable {
    var shareTitle: String { get }
    var shareDescription: String { get }
}

struct Recipe: Codable {
    var id: String
    var title: String
    var category: String
    var area: String
    var instructions: String
    var thumbnailURL: String
    var ingredients: [String]
    var isFavourited: Bool
    var tags: [String]

    init(from detail: MealDetail) {
        self.id           = detail.idMeal
        self.title        = detail.strMeal
        self.category     = detail.strCategory ?? "Unknown"
        self.area         = detail.strArea ?? "Unknown"
        self.instructions = detail.strInstructions ?? ""
        self.thumbnailURL = detail.strMealThumb ?? ""
        self.ingredients  = detail.ingredients
        self.isFavourited = false
        self.tags         = detail.strTags?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
    }
}

extension Recipe: Shareable {
    var shareTitle: String { title }
    var shareDescription: String { "Check out this \(category) recipe: \(title)!" }
}

struct UserProfile: Codable {
    var username: String
    var displayName: String
    var bio: String
    var favouriteCategory: MealCategory
    var joinDate: Date
    var recipesSaved: Int

    static var `default`: UserProfile {
        UserProfile(
            username: "foodie_chef",
            displayName: "Chef Foodie",
            bio: "Passionate about cooking and sharing delicious recipes 🍴",
            favouriteCategory: .chicken,
            joinDate: Date(),
            recipesSaved: 0
        )
    }
}

// MARK: - Mock Data

struct MockData {
    static let featuredCategories: [MealCategory] = MealCategory.allCases

    static let feedPosts: [FeedPost] = [
        FeedPost(id: "1", username: "julia_eats", userAvatar: "person.circle.fill",
                 recipeTitle: "Spaghetti Carbonara", category: .pasta,
                 likesCount: 142, commentsCount: 23,
                 imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg",
                 timeAgo: "2h ago"),
        FeedPost(id: "2", username: "marco_cooks", userAvatar: "person.circle.fill",
                 recipeTitle: "BBQ Beef Ribs", category: .beef,
                 likesCount: 89, commentsCount: 11,
                 imageURL: "https://www.themealdb.com/images/media/meals/qtqvys1468573168.jpg",
                 timeAgo: "5h ago"),
        FeedPost(id: "3", username: "sweet_baker", userAvatar: "person.circle.fill",
                 recipeTitle: "Chocolate Lava Cake", category: .dessert,
                 likesCount: 310, commentsCount: 47,
                 imageURL: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
                 timeAgo: "1d ago"),
        FeedPost(id: "4", username: "green_kitchen", userAvatar: "person.circle.fill",
                 recipeTitle: "Thai Green Curry", category: .chicken,
                 likesCount: 205, commentsCount: 30,
                 imageURL: "https://www.themealdb.com/images/media/meals/sstssx1487349585.jpg",
                 timeAgo: "1d ago"),
    ]
}

struct FeedPost {
    let id: String
    let username: String
    let userAvatar: String
    let recipeTitle: String
    let category: MealCategory
    var likesCount: Int
    let commentsCount: Int
    let imageURL: String
    let timeAgo: String
    var isLiked: Bool = false
}
