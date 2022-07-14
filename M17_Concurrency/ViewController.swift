
import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let service = Service()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 220, y: 220, width: 140, height: 140))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        onLoad()
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.right.left.equalToSuperview()
        }
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private let serialQueue = DispatchQueue(label: "serialQueue")
    
    var images: [UIImage] = []
   
    private func onLoad() {
        
        let group = DispatchGroup()
 
        for _ in 0...4 {
            group.enter()
            serialQueue.async(group: group) {
                
                self.service.getImageURL { urlString, error in
                    guard
                        let urlString = urlString
                    else {
                        return
                    }
                    self.images.append(self.service.loadImage(urlString: urlString)!)
                    print(self.images.count)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else  {  return }
            
            self.activityIndicator.stopAnimating()
            self.stackView.removeArrangedSubview(self.activityIndicator)
            
            for i in 0...4 {
                let image = self.images[i]
                let view = UIImageView(image: image)
                view.contentMode = .scaleAspectFit
                self.stackView.addArrangedSubview(view)
            }
        }
    }
}
