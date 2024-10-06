import MapKit

class CustomAnnotationView: MKAnnotationView {
    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: -41, y: -90, width: 80, height: 80))
        view.backgroundColor = .white
        view.layer.cornerRadius = 16.0
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var bottomCornerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        return view
    }()
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let customAnnotation = newValue as? CustomAnnotation else { return }
            canShowCallout = true
            addSubview(containerView)
            containerView.addSubview(bottomCornerView)
            containerView.addSubview(imageView)
            
            // Configure imageView
            imageView.image = customAnnotation.image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0),
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0),
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
                imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0)
            ])
            
            // Configure bottomCornerView
            bottomCornerView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15.0).isActive = true
            bottomCornerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            bottomCornerView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            bottomCornerView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            let angle = (39.0 * CGFloat.pi) / 180
            bottomCornerView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
