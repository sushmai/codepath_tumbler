//
//  PhotoDetailsViewController.swift
//  tumblr
//
//  Created by Kristy Caster on 11/2/16.
//  Copyright © 2016 kristeaac. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    var photoUrl : String!
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = photoImage
    }

    @IBAction func onPhotoTap(_ sender: Any) {
        performSegue(withIdentifier: "com.kristeeac.segue.fullphoto", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! FullPhotoViewController
        destinationViewController.photoImage = photoImage
    }
    
}
