//
//  FloatingView.swift
//  FloatingWindowSwift
//
//  Created by chengjie on 2018/4/24.
//  Copyright © 2018年 chengjie. All rights reserved.
//

import UIKit
import SnapKit

class FloatingView: UIView {
    
    var versionLabel: UILabel = UILabel()
    var fpsLabel: UILabel = UILabel()
    var fpsLink: CADisplayLink?
    var fpsCount: Double = 0.0
    var fpsLastTime: TimeInterval = 0.0
    var distanceArray: (CGFloat,CGFloat) = (0.0,0.0)

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
        
        AAA.ocLog();
        
        fpsLabel.textAlignment = NSTextAlignment.left;
        fpsLabel.font = UIFont.systemFont(ofSize: 11);
        fpsLabel.isUserInteractionEnabled = false;
        
        versionLabel.textAlignment = NSTextAlignment.center;
        versionLabel.font = UIFont.systemFont(ofSize: 11);
        versionLabel.isUserInteractionEnabled = false;
        versionLabel.attributedText = self.attributedOneString(oneString: "版本号", oneColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), twoString: "\(Bundle.main.infoDictionary)", twoColor: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
        self.commonInit()
        
        self.fpsLink = CADisplayLink(target: self, selector: #selector(self.fpsLinkTick))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        self.addGestureRecognizer(pan)
        
        self.showFPS()
    }
    
    @objc func panGesture(_ panGesture:UIPanGestureRecognizer){
        switch panGesture.state {
        case .began:
            self.distanceArray = (self.center.x,self.center.y);
            break;
        case .changed:
            let location: CGPoint = panGesture.translation(in: self.superview)
            
//            let sss: CGFloat = self.distanceArray?[0] as! CGFloat
//            let aaaa: CGFloat = self.distanceArray?[1] as! CGFloat
            
            self.center = CGPoint(x: location.x + self.distanceArray.0, y: location.y + self.distanceArray.1)
            break;
        case .ended:
            var frame: CGRect = self.frame;
            let screenWidth: CGFloat = UIScreen.main.bounds.size.width;
            let screenHeight: CGFloat = UIScreen.main.bounds.size.height;
            let frameWidth = frame.size.width;
            let frameHeight = frame.size.height;
            let frameX = frame.origin.x;
            let frameY = frame.origin.y;
            
            if frameX <= ((screenWidth - frameWidth)/2.0) && frameY > frameHeight && frameY < (screenHeight - 2 * frameHeight){
                frame.origin.x = 0;
            }else if frameX > ((screenWidth - frameWidth)/2.0) && frameY > frameHeight && frameY < (screenHeight - 2 * frameHeight){
                frame.origin.x = screenWidth - frameWidth;
            }else if frameY <= frameHeight{
                frame.origin.y = 0;
            }else if frameY >= (screenHeight - 2 * frameHeight){
                frame.origin.y = screenHeight - frameHeight;
            }
            
            UIView .animate(withDuration: 0.3, animations: {
                self.frame = frame;
            })
            
            break;
        default:
            break;
        }
    }
    
    private func commonInit() {
        self.backgroundColor = #colorLiteral(red: 0.9716552782, green: 0.4651253351, blue: 1, alpha: 1);
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = 3.0;
        self.addSubview(self.versionLabel)
        self.addSubview(self.fpsLabel)
        
//        versionLabel.mas_makeConstraints { (make) in
//            make?.left.equalTo()(self)?.setOffset(15)
//            make?.width.equalTo()(100)
//            make?.height.equalTo()(20)
//            make?.top.equalTo()(self)?.setOffset(0)
//        }
//        
//        fpsLabel.mas_makeConstraints { (make) in
//            make?.left.equalTo()(15)
//            make?.top.equalTo()(versionLabel.mas_bottom)?.setOffset(15)
//            make?.width.equalTo()(versionLabel.mas_width)
//            make?.height.equalTo()(versionLabel.mas_height)
//        }
        
        versionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        fpsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(versionLabel.snp.left)
            make.top.equalTo(versionLabel.snp.bottom)
            make.width.equalTo(versionLabel.snp.width)
            make.height.equalTo(versionLabel.snp.height)
        }
    }
    
    private func showFPS() {
        
        self.fpsLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    @objc func fpsLinkTick() {
        if self.fpsLastTime == 0{
            self.fpsLastTime = (self.fpsLink?.timestamp)!;
            return;
        }
        self.fpsCount = self.fpsCount + 1;
        let delta: Double = (self.fpsLink?.timestamp)! - self.fpsLastTime;
        if delta < 1.0{
            return;
        }
        self.fpsLastTime = (self.fpsLink?.timestamp)!;
        var fps = self.fpsCount/delta;
        self.fpsCount = 0;
        
        fpsLabel.attributedText = self.attributedOneString(oneString: "FPS", oneColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), twoString: "\(fps)", twoColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
    }
    
    override func removeFromSuperview() {
        self.fpsLink?.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes);
    }
    
    private func attributedOneString(oneString:String,oneColor:UIColor,twoString:String,twoColor:UIColor) -> NSMutableAttributedString{
        let oneAttString: NSMutableAttributedString = NSMutableAttributedString.init(string: oneString, attributes: [NSAttributedStringKey.foregroundColor : oneColor])
        
        let twoAttString: NSMutableAttributedString = NSMutableAttributedString.init(string: twoString, attributes: [NSAttributedStringKey.foregroundColor : twoColor])
        
        oneAttString.append(twoAttString);
        
        return oneAttString;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
