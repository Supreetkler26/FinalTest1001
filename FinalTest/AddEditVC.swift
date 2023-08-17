//
//  AddEditVC.swift
//  FinalTest
//
//  Created by Ravi  on 2023-08-16.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher

class AddEditVC: UIViewController {
    
    @IBOutlet var addEditLabel: UILabel!
    
    @IBOutlet var addEditButton: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleTextField: UITextField!
    
    @IBOutlet var originTextField: UITextField!
    
    @IBOutlet var recipeIDTextField: UITextField!
    
    @IBOutlet var servingSizeTextField: UITextField!
    
    @IBOutlet var difficultyTextField: UITextField!
    
    @IBOutlet var prepTimeTextField: UITextField!
    
    @IBOutlet var calorieCountTextField: UITextField!
    
    @IBOutlet var sourceURLTextField: UITextField!
    
    @IBOutlet var microNutrientsTextField: UITextView!
    
    @IBOutlet var ingredientsTextField: UITextView!
    
    @IBOutlet var instructionsTextField: UITextView!
    
    var recipe: Recipe?
    var recipeViewController: FirebaseCRUDVC?
    var recipeUpdateCallback: (() -> Void)?
    var selectedImageUrl: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let imageUrl = selectedImageUrl, let url = URL(string: imageUrl) {
               imageView.kf.setImage(with: url)
           } else {
               imageView.image = UIImage(named: "assetsImage")
           }
        
        if let recipe = recipe {
            // Editing existing movie
            recipeIDTextField.text = "\(recipe.recipeID)"
            titleTextField.text = recipe.title
            originTextField.text = recipe.origin
            servingSizeTextField.text = recipe.servingSize
            difficultyTextField.text = recipe.difficulty
            prepTimeTextField.text = recipe.preparationTime
            calorieCountTextField.text = "\(recipe.calorieCount)"
            sourceURLTextField.text = recipe.sourceURL
            microNutrientsTextField.text = recipe.microNutrients
            ingredientsTextField.text = recipe.ingredients
            instructionsTextField.text = recipe.instructions
 
            
            addEditLabel.text = "Edit Recipe"
            addEditButton.setTitle("Update", for: .normal)
        } else {
            addEditLabel.text = "Add Recipe"
            addEditButton.setTitle("Add", for: .normal)
        }
        
    }
    

    
    @IBAction func addEditButtonfn(_ sender: Any) {
        
        let constantImage = UIImage(named: "assetsImage")
        imageView.image = constantImage
        
        guard
            let recipeIDString = recipeIDTextField.text,
            let recipeID = Int(recipeIDString),
            let title = titleTextField.text,
            let origin = originTextField.text,
            let servingSize = servingSizeTextField.text,
            let difficulty = difficultyTextField.text,
            let prepTime = prepTimeTextField.text,
            let calorieCountString = calorieCountTextField.text,
            let calorieCount = Double(calorieCountString),
            let sourceURL = sourceURLTextField.text,
            let microNutrients = microNutrientsTextField.text,
            let ingredients = ingredientsTextField.text,
            let instructions = instructionsTextField.text
        else {
            print("Invalid data")
            return
        }

        
        let db = Firestore.firestore()
        
        if let recipe = recipe {
            // Update existing movie
            guard let documentID = recipe.documentID else {
                print("Document ID not available.")
                return
            }
            
            // Preserve the existing imgURL when updating
            var updatedData: [String: Any] = [
                "recipeID": recipeID,
                "title": title,
                "origin": origin,
                "servingSize": servingSize,
                "difficulty": difficulty,
                "preparationTime": prepTime,
                "calorieCount": calorieCount,
                "sourceURL": sourceURL,
                "microNutrients": microNutrients,
                "ingredients": ingredients,
                "instructions": instructions
            ]
            
            // Only update imgURL if it exists
            if let imageURL = recipe.imageURL {
                updatedData["imageURL"] = imageURL
            }
            
            let recipeRef = db.collection("recipes").document(documentID)
            recipeRef.updateData(updatedData) { [weak self] error in
                if let error = error {
                    print("Error updating recipe: \(error)")
                } else {
                    print("Recipe updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.recipeUpdateCallback?()
                    }
                }
            }
        }  else {
            // Add new movie with default image
            let defaultImage = "assetsImage"
            let newRecipe = [
                "recipeID": Int(recipeID),
                "title": title,
                "origin": origin,
                "servingSize": servingSize,
                "difficulty": difficulty,
                "preparationTime": prepTime,
                "calorieCount": Double(calorieCount),
                "sourceURL": sourceURL,
                "microNutrients": microNutrients,
                "ingredients": ingredients,
                "instructions": instructions,
                "imageURL": defaultImage
            ] as [String : Any]
            
            var ref: DocumentReference? = nil
            ref = db.collection("recipes").addDocument(data: newRecipe) { [weak self] error in
                if let error = error {
                    print("Error adding movie: \(error)")
                } else {
                    print("Recipe added successfully.")
                    self?.dismiss(animated: true) {
                        self?.recipeUpdateCallback?()
                    }
                }
            }
            imageView.image = UIImage(named: defaultImage)
            
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
                
        dismiss(animated: true, completion: nil)
    }
    

}
