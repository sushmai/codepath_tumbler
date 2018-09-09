//
//  FullPhotoViewController.swift
//  tumblr
//
//  Created by Kristy Caster on 11/3/16.
//  Copyright © 2016 kristeaac. All rights reserved.
//

import UIKit

class FullPhotoViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = photoImage
    }

    @IBAction func onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
}
