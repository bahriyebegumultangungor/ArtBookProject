//
//  DetailsViewController.swift
//  ArtBookProject
//
//  Created by Bahriye Begum Ultan Gungor on 17.08.2020.
//  Copyright © 2020 Bahriye Begum Ultan Gungor. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenPainting != "" {
//             Core data
            
            saveButton.isHidden = true
//            or
            //saveButton.isEnabled = false
            
            
//            AppDelegate çağır
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
//            CoreDatadaki veri sonuçlarını almak için
            let fecthRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = choosenPaintingId!.uuidString
            
//            id'si idStringe eşit olanı bana getir
            fecthRequest.predicate = NSPredicate(format: "id = %@", idString)
            fecthRequest.returnsObjectsAsFaults = false
            
//            CoreDatadan verileri çekip detayları göster
            do {
                let results = try context.fetch(fecthRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let image = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: image)
                            imageView.image = image
                        }
                    }
                }
            } catch{
                print("Error")
            }
            print(idString)
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false

            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
//        Recognizers
//        Klavyeyi kapattırdık
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view.
        
//        Kullanıcı imageview'e tıklayabilir mi
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
//    Klavyeyi kapattırdık
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
//    Telefonda albümlere erişmek için
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        // uyarı mesajı gibi
        present(picker, animated: true, completion: nil)
    }
    
//    Albümden image seçildikten sonra kapan
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
//        CoreDataya kayıt ettik
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
//        Attributes
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }

//        Swift kendi id oluşturuyor
        newPainting.setValue(UUID(), forKey:"id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success")
        } catch{
            print("Error")
        }
//        CoreDataya kayıt ettik
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
