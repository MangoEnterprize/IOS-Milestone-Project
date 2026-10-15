# FlavorFeed 🍎

## Badges

[![Swift Version](https://img.shields.io/badge/Swift-5.8-orange.svg)]() [![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)]() [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Table of Contents

- [Features](#features-🌟)
- [Tech Stack](#tech-stack-💻)
- [Installation](#installation-🚀)
- [Usage](#usage-💡)
- [Project Structure](#project-structure-📂)
- [API Reference](#api-reference-🔗)
- [Contributing](#contributing-🤝)
- [License](#license-📜)
- [Important Links](#important-links-🔗)
- [Footer](#footer-❤️)

### Description

FlavorFeed is a social recipe networking application built with Swift for iOS. It allows users to discover, save, and share recipes from a vast online database. Users can browse recipes by category, view detailed instructions, save their favorites, and manage their profile. The app aims to provide an engaging and user-friendly experience for food enthusiasts.

## Features 🌟

- **Recipe Discovery:** Browse and search for recipes by various categories (e.g., Beef, Chicken, Dessert).
- **Detailed Recipe View:** View complete recipe details including ingredients, instructions, and category/area.
- **Image Display:** High-quality images for each recipe.
- **User Profiles:** Manage user profiles with display names, usernames, bios, and favorite categories.
- **Save/Unsave Recipes:** Users can favorite recipes for easy access later.
- **Social Feed:** A simulated social feed showcasing recipe posts with likes and comments.
- **Search Functionality:** Search for recipes by name.
- **Offline Support:** Saved recipes and user profiles are persisted locally using `UserDefaults`.
- **Clean UI:** Modern and intuitive user interface with a tab-based navigation.

## Tech Stack 💻

- **Language:** Swift
- **Frameworks:** UIKit
- **API:** TheMealDB API (for recipe data)
- **Persistence:** `UserDefaults` (for local storage of favorites and user profile)

## Installation 🚀

To get started with FlavorFeed, follow these steps:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/MangoEnterprize/IOS-Milestone-Project.git
    cd IOS-Milestone-Project
    ```

2.  **Open in Xcode:**
    Open the `FlavourFeed.xcodeproj` file in Xcode.

3.  **Build and Run:**
    Build the project and run it on a simulator or a physical iOS device.

*Note: FlavorFeed does not have external dependencies that require package managers like CocoaPods or Swift Package Manager at this time. All necessary code is included within the project.* 🛠️

## Usage 💡

FlavorFeed is designed to be a user-friendly recipe application.
## Wireframes

![68147](https://github.com/user-attachments/assets/28be3731-0d9f-4302-9f0f-04a23e4c8a10)



##Milestone 2 Demo


https://github.com/user-attachments/assets/13b2c5c7-c8af-484e-a851-f95ab7c562ff

##Final Demo

https://github.com/user-attachments/assets/f98a5598-51e3-4af8-8249-8fd7e845f115

### Core Functionality:

1.  **Browse Recipes:** Navigate to the "Browse" tab to explore recipes by category. You can tap on a category to filter the results and use the search bar to find specific recipes by name. 🔎
2.  **View Recipe Details:** Tap on any recipe from the browse list or the social feed to view its detailed page. This page includes ingredients, step-by-step instructions, and a high-resolution image. 📖
3.  **Save Favorites:** On the recipe detail page, tap the heart icon ❤️ to save a recipe. Saved recipes can be accessed from the "Saved" tab. Tap the filled heart to remove it from favorites.
4.  **Social Feed:** The "Feed" tab presents a simulated social feed of recipe posts. You can like posts by tapping the heart icon. Tapping on a post will navigate you to the recipe's category page.
5.  **User Profile:** The "Profile" tab displays your user information, including saved recipes count and join date. You can edit your profile details by tapping the "Edit" button. 👤

### Example Scenarios:

- **Finding a new chicken recipe:** Go to the "Browse" tab, select the "Chicken" category, and scroll through the list. Tap on a recipe to see how to make it.
- **Saving a dessert you want to try:** Find a dessert recipe, tap on it, and then tap the heart icon to save it. You can find it later in the "Saved" tab.
- **Checking your cooking stats:** Visit the "Profile" tab to see how many recipes you've saved and when you joined the FlavorFeed community.

## Project Structure 📂

The project follows a standard iOS project structure with controllers, models, networking, and persistence layers.

- **`FlavourFeed/`**: The main application directory.
  - **`Controllers/`**: Contains `UIViewController` subclasses for managing different screens (e.g., `HomeViewController`, `SearchViewController`, `RecipeDetailViewController`, `ProfileViewController`).
  - **`Models/`**: Defines data structures and enums (`MealCategory`, `Recipe`, `UserProfile`, `FeedPost`).
  - **`Networking/`**: Handles API requests, primarily `MealAPIService` for fetching recipe data.
  - **`Persistence/`**: Manages local data storage using `UserDefaults` (`PersistenceManager`).
  - **`Views/`**: Custom `UITableViewCell` and `UICollectionViewCell` subclasses (e.g., `RecipeTableViewCell`, `FeedTableViewCell`, `CategoryChipCell`).
  - **`Supporting/`**: Contains essential app setup files like `AppDelegate.swift` and `SceneDelegate.swift`.
- **`FlavourFeed.xcodeproj/`**: Xcode project configuration files.

## API Reference 🔗

FlavorFeed utilizes TheMealDB API for fetching recipe data.

- **Base URL:** `https://www.themealdb.com/api/json/v1/1`
- **Endpoints:**
  - **`filter.php?c=<Category>`**: Fetches a list of meals for a given category.
  - **`lookup.php?i=<MealID>`**: Fetches detailed information for a specific meal ID.

Detailed information about TheMealDB API can be found at [https://www.themealdb.com/api.php](https://www.themealdb.com/api.php).

## Important Links 🔗

- **Repository:** [https://github.com/MangoEnterprize/IOS-Milestone-Project](https://github.com/MangoEnterprize/IOS-Milestone-Project)
- **Live Demo:** (No live demo available for this project)
- **Author Profile:** [https://github.com/MangoEnterprize](https://github.com/MangoEnterprize)

