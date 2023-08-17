//
//  FirebaseCRUDVC.swift
//  FinalTest
//
//  Created by Ravi  on 2023-08-16.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Kingfisher

class FirebaseCRUDVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var recipes: [Recipe] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
         

        KingfisherManager.shared.defaultOptions = [.fromMemoryCacheOrRefresh]
           fetchRecipesFromFirestore()
        
    }
    
    func fetchRecipesFromFirestore() {
        let db = Firestore.firestore()
        db.collection("recipes").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedRecipes: [Recipe] = []

            for document in snapshot!.documents {
                                let data = document.data()
                
                                do {
                                    var recipe = try Firestore.Decoder().decode(Recipe.self, from: data)
                
                                    recipe.documentID = document.documentID
                                    fetchedRecipes.append(recipe)
                                } catch {
                                    print("Error decoding recipe data: \(error)")
                                }
                            }

            DispatchQueue.main.async {
                self.recipes = fetchedRecipes
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell

        let recipe = recipes[indexPath.row]

        cell.titleLabel?.text = recipe.title
        cell.calorieCountLabel?.text = "\(recipe.calorieCount)"
        cell.originLabel?.text = recipe.origin

           if let imageUrl = recipe.imageURL, let url = URL(string: imageUrl) {
               cell.thumbView.kf.setImage(with: url)
           } else {
               cell.thumbView.image = UIImage(named: "assetsImage")
           }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipe = recipes[indexPath.row]
            showDeleteConfirmationAlert(for: recipe) { confirmed in
                if confirmed {
                    self.deleteMovie(at: indexPath)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEditSegue" {
            if let addEditVC = segue.destination as? AddEditVC {
                addEditVC.recipeViewController = self
                
                if let indexPath = sender as? IndexPath {
                               let recipe = recipes[indexPath.row]
                               addEditVC.recipe = recipe
                               addEditVC.selectedImageUrl = recipe.imageURL
                           } else {
                               addEditVC.recipe = nil
                               addEditVC.selectedImageUrl = nil
                           }
                addEditVC.recipeUpdateCallback = { [weak self] in
                    self?.fetchRecipesFromFirestore()
                }
            }
        }
    }

    func showDeleteConfirmationAlert(for recipe: Recipe, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            completion(true)
        })

        present(alert, animated: true, completion: nil)
    }

    func deleteMovie(at indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]

        guard let documentID = recipe.documentID else {
            print("Invalid document ID")
            return
        }

        let db = Firestore.firestore()
        db.collection("recipes").document(documentID).delete { [weak self] error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                DispatchQueue.main.async {
                    print("Recipe deleted successfully.")
                    self?.recipes.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    
    
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
   

}
