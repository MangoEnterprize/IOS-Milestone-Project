// MealAPIService.swift
// FlavourFeed

import Foundation
import UIKit


protocol RecipeFetchable {
    func fetchMeals(for category: String, completion: @escaping (Result<[MealSummary], AppError>) -> Void)
    func fetchMealDetail(id: String, completion: @escaping (Result<MealDetail, AppError>) -> Void)
}

final class MealAPIService: RecipeFetchable {

    static let shared = MealAPIService()
    private init() {}

    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    private let session: URLSession = .shared

    // MARK: - Fetch Meal List by Category

    func fetchMeals(for category: String, completion: @escaping (Result<[MealSummary], AppError>) -> Void) {
        let encoded = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
        guard let url = URL(string: "\(baseURL)/filter.php?c=\(encoded)") else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(MealListResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.meals ?? []))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }


    func fetchMealDetail(id: String, completion: @escaping (Result<MealDetail, AppError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/lookup.php?i=\(id)") else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(MealDetailResponse.self, from: data)
                guard let detail = decoded.meals?.first else {
                    DispatchQueue.main.async { completion(.failure(.noData)) }
                    return
                }
                DispatchQueue.main.async { completion(.success(detail)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }


    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        // Check cache first
        if let cached = ImageCache.shared.image(for: urlString) {
            completion(cached)
            return
        }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            ImageCache.shared.store(image, for: urlString)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}


final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    private var cache = NSCache<NSString, UIImage>()

    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func store(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

