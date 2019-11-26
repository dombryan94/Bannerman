//
//  Bannerman.swift
//  Bannerman
//
//  Created by Dom Bryan on 26/11/2019.
//  Copyright © 2019 Dom Bryan. All rights reserved.
//

import UIKit

protocol BannermanActionable: class {
    func bannerAction()
}

// MARK: - Button types
enum ActionButtonType {
    case view, cross
}

class Bannerman: UIView {
    
    enum BannerState {
        case notVisible, visible, showing, hidding
    }
    
    weak var delegate: BannermanActionable?
    
    private let screen = UIScreen.main.bounds
    private var backgroundViewHeight: CGFloat = 74
    private lazy var backgroundTopAnchor = backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: -backgroundViewHeight)
    private let canAutoHide: Bool!
    private let delayForAutoHide: Double!
    
    public private(set) var state: BannerState = .notVisible {
        didSet {
            #if DEBUG
            print(state)
            #endif
        }
    }
    
    // MARk: - Stored Views
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 19/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.accessibilityIdentifier = "bannerBackgroundView"
        return view
    }()
    
    private let contentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "bannerLabel"
        return label
    }()
    
    private let viewLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "VIEW"
        label.textColor = UIColor(red: 0/255.0, green: 104/255.0, blue: 255/255.0, alpha: 1.0)
        return label
    }()
    
    private let crossImageView: UIImageView = {
        let crossImageView = UIImageView()
        crossImageView.translatesAutoresizingMaskIntoConstraints = false
        crossImageView.contentMode = .scaleAspectFit
        crossImageView.image = UIImage(named: "icNotificationCrossWhite")
        return crossImageView
    }()
    
    // MARK: - Custom Init
    public required init(delegate: BannermanActionable? = nil,
                         text: String,
                         hasButton: Bool = false,
                         buttonType: ActionButtonType = .view,
                         canAutoHide: Bool = false,
                         delayForAutoHide: Double = 3.0) {
        let window = UIApplication.shared.keyWindow
        let topSafeAreaHeight = window?.safeAreaInsets.top ?? 44
        let frame = CGRect(x: 0, y: 0, width: screen.width, height: topSafeAreaHeight + backgroundViewHeight)
        self.canAutoHide = canAutoHide
        self.delayForAutoHide = delayForAutoHide
        
        super.init(frame: frame)
        
        addText(text)
        setupViews(withButton: hasButton,
                   buttonType: buttonType)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }
    
    // MARK: - Required Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK - Data methods
extension Bannerman {
    func addText(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedText = NSMutableAttributedString.init(string: text, attributes: [:])
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange.init(location: 0, length: attributedText.length))
        textLabel.attributedText = attributedText
    }
}

// MARK: - Show and Dismiss methods
extension Bannerman {
    public func show() {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(self)
            self.layoutIfNeeded()
        }
        backgroundTopAnchor.constant = safeAreaInsets.top
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.state = .showing
            self.layoutIfNeeded()
        }) { completed in
            self.state = .visible
            if self.canAutoHide {
                self.dismissAfter(seconds: self.delayForAutoHide)
            }
        }
    }
    
    public func dismiss() {
        backgroundTopAnchor.constant = -backgroundViewHeight
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.state = .hidding
            self.layoutIfNeeded()
        }) { completed in
            self.state = .notVisible
            self.transform = .identity
        }
    }
    
    private func dismissAfter(seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.dismiss()
        }
    }
}

// MARK: - Setup views method
extension Bannerman {
    private func setupViews(withButton: Bool, buttonType: ActionButtonType) {
        addSubview(backgroundView)
        backgroundView.addSubview(contentsStackView)
        
        contentsStackView.addArrangedSubview(textLabel)
        if withButton {
            switch buttonType {
            case .cross:
                contentsStackView.addArrangedSubview(crossImageView)
            case .view:
                contentsStackView.addArrangedSubview(viewLabel)
            }
        }
        let dynamicBackgroundHeight = textLabel.frame.height + 40
        let width = UIDevice.current.userInterfaceIdiom == .pad ? 375 : screen.width - 32
        let constraints: [NSLayoutConstraint] = [
            backgroundTopAnchor,
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: width),
            backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: dynamicBackgroundHeight),
            
            contentsStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            contentsStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -22),
            contentsStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20),
            contentsStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 22),
            contentsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 16),
            
            viewLabel.widthAnchor.constraint(equalToConstant: 33),
            crossImageView.widthAnchor.constraint(equalToConstant: 12)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Gesture recognisers
extension Bannerman {
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        dismiss()
        delegate?.bannerAction()
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            subviews.forEach({ (view) in
                view.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        if gesture.translation(in: nil).y < 0 {
            let translation = gesture.translation(in: nil)
            let transformation = CGAffineTransform(translationX: 0, y: translation.y)
            transform = transformation
        }
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        if gesture.translation(in: nil).y > 0 { return }
        let shouldDismiss = abs(gesture.translation(in: nil).y) > (backgroundView.frame.height / 2)
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        if shouldDismiss {
                            self.backgroundTopAnchor.constant = -self.backgroundViewHeight
                        } else {
                            self.transform = .identity
                        }
        }) { _ in
            if shouldDismiss {
                self.dismiss()
            }
        }
    }
}
