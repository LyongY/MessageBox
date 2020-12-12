//
//  MessageBox.swift
//  MessageBox
//
//  Created by Raysharp666 on 2020/12/10.
//

import UIKit

class MessageBox: UIView {
    enum Style {
        case list, one
    }
    
    struct MessageStyle {
        var textColor: UIColor = .white
        var backgroundColor: UIColor = UIColor(white: 0, alpha: 0.75)
        var borderColor: UIColor = .clear
        var borderWidth: CGFloat = 0
        var cornerRadius: CGFloat = 6
    }
    
    private class Message: UIView {
        init(message: String, style: MessageStyle) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel()
            label.text = message
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            addConstraints([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                label.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
                label.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            ])
            label.textColor = style.textColor
            backgroundColor = style.backgroundColor
            layer.borderColor = style.borderColor.cgColor
            layer.borderWidth = style.borderWidth
            layer.cornerRadius = style.cornerRadius
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    static let `default`: MessageBox = {
        let view = MessageBox(style: .list, frame: .zero)
        return view
    }()
    
    private weak var parentView: UIView?
    var style: Style
    var messageStyle: MessageStyle = MessageStyle()
    init(style: Style, parentView: UIView? = nil, frame: CGRect) {
        self.style = style
        self.parentView = parentView
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true
        backgroundColor = .clear
        
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        addObserver(self, forKeyPath: "center", options: .new, context: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "frame")
        removeObserver(self, forKeyPath: "bounds")
        removeObserver(self, forKeyPath: "center")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" || keyPath == "bounds" || keyPath == "center" {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = .init(x: 0, y: 0, width: rect.width, height: rect.height)
        gradientLayer.colors = [
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 1).cgColor,
            UIColor(white: 1, alpha: 1).cgColor,
            UIColor(white: 1, alpha: 0).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.05, 0.3, 1.0]
        gradientLayer.startPoint = .init(x: 0.5, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 0)
        let maskView = UIView(frame: gradientLayer.bounds)
        maskView.layer.addSublayer(gradientLayer)
        mask = maskView
    }
    
    private var messageArr: [Message] = []
}

extension MessageBox {
    func show(message: String) {
        addContainerIfNeeded()
        let messageView = addNewMessage(msg: message)
        updateConstraints(with: messageView)
        remove(message: messageView, after: 5)
    }
}

extension MessageBox {
    private static func keyWindow() -> UIWindow {
        var mainWindow: UIWindow? = nil
        for window in UIApplication.shared.windows {
            if window.windowLevel == .normal && window.frame == UIScreen.main.bounds {
                mainWindow = window
                break
            }
        }
        guard let findMainWindow = mainWindow else {
            fatalError("没找到 window")
        }
        return findMainWindow
    }
    
    private func addContainerIfNeeded() {
        if parentView?.subviews.contains(self) ?? false {
            // 已有父视图
        } else {
            self.translatesAutoresizingMaskIntoConstraints = false
            parentView = MessageBox.keyWindow()
            guard let parentView = parentView else { fatalError("不可能没有")}
            parentView.addSubview(self)
            parentView.addConstraints([
                leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 44),
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -44),
                rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -44),
                heightAnchor.constraint(equalToConstant: 150)
            ])
        }
        parentView?.bringSubviewToFront(self)
    }
    
    private func addNewMessage(msg: String) -> Message {
        let messageView = Message(message: msg, style: messageStyle)
        messageView.alpha = 0
        addSubview(messageView)
        messageArr.append(messageView)
        return messageView
    }
    
    private func updateConstraints(with messageView: Message) {
        if style == .list {
            addConstraint(messageView.topAnchor.constraint(equalTo: bottomAnchor))
            addConstraint(messageView.centerXAnchor.constraint(equalTo: centerXAnchor))
            layoutIfNeeded()
            removeConstraints(constraints)
            UIView.animate(withDuration: 0.3) {
                messageView.alpha = 1
                for (index, item) in self.messageArr.enumerated() {
                    if index == self.messageArr.count - 1 {
                        self.addConstraint(item.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20))
                    } else {
                        self.addConstraint(item.bottomAnchor.constraint(equalTo: self.messageArr[index + 1].topAnchor, constant: -8))
                    }
                    self.addConstraint(item.centerXAnchor.constraint(equalTo: self.centerXAnchor))
                }
                self.layoutIfNeeded()
            }
        } else {
            addConstraint(messageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20))
            addConstraint(messageView.centerXAnchor.constraint(equalTo: centerXAnchor))
            messageView.alpha = 0
            layoutIfNeeded()
            removeConstraints(constraints)
            UIView.animate(withDuration: 0.3) {
                for item in self.messageArr {
                    item.alpha = 0
                    self.addConstraint(item.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20))
                    self.addConstraint(item.centerXAnchor.constraint(equalTo: self.centerXAnchor))
                }
                messageView.alpha = 1
                self.layoutIfNeeded()
            }
        }
    }
    
    private func remove(message: Message, after time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            UIView.animate(withDuration: 0.3) {
                message.alpha = 0
            } completion: { (_) in
                message.removeFromSuperview()
                self.messageArr = self.messageArr.filter{ $0 != message }
                if self.messageArr.count == 0 {
                    self.removeFromSuperview()
                }
            }
        }
    }
}
