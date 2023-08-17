//
//  Recipe.swift
//  FinalTest
//
//  Created by Ravi  on 2023-08-16.
//

import Foundation

struct Recipe: Codable {
    
    var documentID: String?
    var recipeID: Int
    var title: String?
    var ingredients: String?
    var instructions: String?
    var origin: String?
    var preparationTime: String?
    var servingSize: String?
    var difficulty: String?
    var calorieCount: Double
    var microNutrients: String?
    var sourceURL: String?
    var imageURL: String?

    }
