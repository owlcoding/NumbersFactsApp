//
//  ViewController.swift
//  Ideas
//
//  Created by Pawel Maczewski on 22/05/15.
//  Copyright (c) 2015 Pawel Maczewski. All rights reserved.
//

import UIKit
import Social


var animator: UIDynamicAnimator!
var ideaView: UIVisualEffectView!
var snapBehavior : UISnapBehavior!
var attachmentBehavior : UIAttachmentBehavior!
var ideaNumber: Int = 0;
var ideaTitle : UILabel!


class ViewController: UIViewController {

    @IBOutlet weak var twitterImage: UIImageView!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var trashImage: UIImageView!

    var fbimg: UIImage!
    var twimg: UIImage!
    var trimg: UIImage!
    var fbimg_: UIImage!
    var twimg_: UIImage!
    var trimg_: UIImage!

    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        ideaView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func imageHighlighted (image: UIImage, color: UIColor) -> UIImage
    {
        var newImage : UIImage
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0); // 0.0 for scale means "scale for device's main screen".
        var rect = CGRectZero;
        rect.size = image.size;
        
        // tint the image
        image.drawInRect(rect);
        color.set()

        UIRectFillUsingBlendMode(rect, kCGBlendModeMultiply);
        
        // restore alpha channel
        image.drawInRect(rect, blendMode: kCGBlendModeDestinationIn, alpha: 1.0);

        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;

    }
    
    func newFact ()
    {
        let act = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        ideaView.addSubview(act)
        act.center = CGPointMake(ideaView.bounds.size.width / 2, ideaView.bounds.size.height / 2)
        act.startAnimating()
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer ()
        manager.responseSerializer = AFJSONResponseSerializer ()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-type");
        
        manager.GET(
            "http://numbersapi.com/random",
            parameters: nil,
            success: { (operation : AFHTTPRequestOperation!, responseObject : AnyObject!) in
                println("JSON: " + responseObject.description)
                ideaTitle.text = (responseObject ["type"] as! String?)! + ": " + (responseObject ["text"] as! String?)!
                act.stopAnimating()
                act.removeFromSuperview()
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
    }
    func createIdeaView ()
    {
        ideaView?.removeFromSuperview()
        ideaView = UIVisualEffectView (effect: UIBlurEffect(style: UIBlurEffectStyle.Dark));
        ideaView.setTranslatesAutoresizingMaskIntoConstraints(false);
        var w = NSLayoutConstraint (
            item: ideaView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Width,
            multiplier: 0.8,
            constant: 0);
        
        var h = NSLayoutConstraint (
            item: ideaView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0.7,
            constant: 0);
        
        var x = NSLayoutConstraint (item: ideaView, attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0);
        var y = NSLayoutConstraint (item: ideaView, attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0);

        view.addSubview(ideaView)
        view.addConstraints([w, h, x, y]);
        
        if ( ideaTitle == nil ) {
            ideaTitle = UILabel ()
            ideaTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
            ideaView.contentView.addSubview(ideaTitle)
            ideaTitle.font = UIFont (name: "Gill Sans", size: 28)
            ideaTitle.textColor = UIColor.whiteColor()
            ideaTitle.textAlignment = NSTextAlignment.Center
            ideaTitle.numberOfLines = 0
            ideaTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            
            ideaView.contentView.addConstraints([
                NSLayoutConstraint (item: ideaTitle, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: ideaView.contentView, attribute: NSLayoutAttribute.Width, multiplier: 0.8, constant: 0),
                NSLayoutConstraint (item: ideaTitle, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: ideaView.contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0),
                NSLayoutConstraint (item: ideaTitle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: ideaView.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0),
                NSLayoutConstraint (item: ideaTitle, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: ideaView.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0),
                ])

        }
        ideaView.layer.cornerRadius = 10;
        ideaTitle.text = "";
        
        snapBehavior = UISnapBehavior(item: ideaView, snapToPoint: self.view.center)
        
        createGestureRecognizer()
        self.view.bringSubviewToFront(facebookImage)
        self.view.bringSubviewToFront(twitterImage)
        self.view.bringSubviewToFront(trashImage)
        
        newFact()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true;
        animator = UIDynamicAnimator (referenceView: view)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)

        // Do any additional setup after loading the view, typically from a nib.
        
        fbimg = facebookImage.image
        twimg = twitterImage.image
        trimg = trashImage.image
        
        fbimg_ = imageHighlighted(fbimg, color: UIColor.redColor())
        twimg_ = imageHighlighted(twimg, color: UIColor.redColor())
        trimg_ = imageHighlighted(trimg, color: UIColor.redColor())
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        createIdeaView ()
    }
    func rotated()
    {
        animator.removeAllBehaviors()
        attachmentBehavior = nil
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            println("landscape")
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            println("Portrait")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func isTouch (touch: CGPoint, withinImage: UIImageView) -> Bool
    {
        if (CGRectContainsPoint(withinImage.frame, touch)) {
            return true;
        } else {
            return false;
        }
    }
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (ideaView != nil) {
            let alertView = sender.view!;
            let panLocationInView = sender.locationInView(view)
            let panLocationInAlertView = sender.locationInView(sender.view)
            
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                
                let offset = UIOffsetMake(panLocationInAlertView.x - CGRectGetMidX(alertView.bounds), panLocationInAlertView.y - CGRectGetMidY(alertView.bounds));
                attachmentBehavior = UIAttachmentBehavior(item: alertView, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                
                animator.addBehavior(attachmentBehavior)
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                attachmentBehavior.anchorPoint = panLocationInView
                if (isTouch(panLocationInView, withinImage: facebookImage)) {
                    facebookImage.image = fbimg_;
                } else {
                    facebookImage.image = fbimg;
                }
                if (isTouch(panLocationInView, withinImage: twitterImage)) {
                    twitterImage.image = twimg_;
                } else {
                    twitterImage.image = twimg;
                }
                if (isTouch(panLocationInView, withinImage: trashImage)) {
                    trashImage.image = trimg_;
                } else {
                    trashImage.image = trimg;
                }
                
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                facebookImage.image = fbimg;
                twitterImage.image = twimg;
                trashImage.image = trimg;
                if ( isTouch(panLocationInView, withinImage: trashImage)) {
                    ideaTitle.text = ""
                    newFact()
                }
                if ( isTouch(panLocationInView, withinImage: twitterImage)) {
                    // share on Twitter
                    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                        
                        var tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                        tweetShare.setInitialText(ideaTitle.text! + " - http://numbersapi.com")
                        
                        self.presentViewController(tweetShare, animated: true, completion: nil)
                        
                    } else {
                        
                        var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                if ( isTouch(panLocationInView, withinImage: facebookImage)) {
                    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                        var fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                        fbShare.setInitialText(ideaTitle.text! + " - http://numbersapi.com")
                        self.presentViewController(fbShare, animated: true, completion: nil)

                    } else {
                        var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                animator.removeAllBehaviors()
                
                snapBehavior = UISnapBehavior(item: alertView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
            }
        }
        
    }

    @IBAction func tapLink(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://numbersapi.com")!)
    }
}

