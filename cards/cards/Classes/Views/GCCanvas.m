//
//  GCCanvas.m
//  cards
//
//  Created by Anatoly Tukhtarov on 1/29/14.
//  Copyright (c) 2014 Anatoly Tukhtarov. All rights reserved.
//

#import "GCCanvas.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

static CGRect const kFaceRect = (CGRect){400.f, 175.f, 195.f, 255.f};

static CGAffineTransform CGAffineTransformMakeScaleMaintainAspectRation(CGFloat scale) {
    return CGAffineTransformMakeScale(scale, scale);
}

@interface GCCanvas () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, assign) CGPoint touchBegan;
@end

@implementation GCCanvas

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.photoLayer = [CALayer layer];
    
    UIImage *hendrix = [UIImage imageNamed:@"hendrix"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
    
    CIImage *coreHendrix = [CIImage imageWithCGImage:[hendrix CGImage]];
    NSArray *features = [detector featuresInImage:coreHendrix];
    
    CIFaceFeature *faceFeature = [features lastObject];
    
    CGFloat scale = [self scaleToFitFaceRectWithFaceBounds:faceFeature.bounds];
    CIImage *scaledImage = [coreHendrix imageByApplyingTransform:CGAffineTransformMakeScaleMaintainAspectRation(scale)];
    
    features = [detector featuresInImage:scaledImage];
    faceFeature = [features lastObject];
    self.photoLayer.contents = (id)[context createCGImage:scaledImage fromRect:scaledImage.extent];
    self.photoLayer.frame = CGRectMake(400.f - faceFeature.bounds.origin.x,
                                       175.f - (scaledImage.extent.size.height - faceFeature.bounds.origin.y - faceFeature.bounds.size.height),
                                       CGRectGetWidth(scaledImage.extent),
                                       CGRectGetHeight(scaledImage.extent));
    self.photoLayer.contentsGravity = kCAGravityTopLeft;
    [self.layer addSublayer:self.photoLayer];
    
    self.maskLayer = [CALayer layer];
    self.maskLayer.frame = self.bounds;
    self.maskLayer.contents = (id)[[UIImage imageNamed:@"sample"] CGImage];

    [self.layer addSublayer:self.maskLayer];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationHandler:)];
    [rotationGesture requireGestureRecognizerToFail:pinchGesture];
    [pinchGesture requireGestureRecognizerToFail:rotationGesture];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translationHandler:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
}

- (CGFloat)scaleToFitFaceRectWithFaceBounds:(CGRect)bounds {
    CGFloat scale = 1.f;
    
    if (CGRectGetWidth(kFaceRect) >= CGRectGetHeight(kFaceRect)) {
        scale = CGRectGetWidth(kFaceRect) / CGRectGetWidth(bounds);
    } else {
        scale = CGRectGetHeight(kFaceRect) / CGRectGetHeight(bounds);
    }
    
    return scale;
}

- (void)pinchHandler:(UIPinchGestureRecognizer *)gesture {
    CGAffineTransform scale = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
    self.photoLayer.affineTransform = CGAffineTransformConcat(scale, self.photoLayer.affineTransform);
}

- (void)rotationHandler:(UIRotationGestureRecognizer *)gesture {
    CGAffineTransform rotation = CGAffineTransformMakeRotation(gesture.rotation);
    self.photoLayer.affineTransform = CGAffineTransformConcat(rotation, self.photoLayer.affineTransform);
}

- (void)translationHandler:(UIPanGestureRecognizer *)gesture {
    
    CGPoint movedTo = [gesture translationInView:self];
    CGFloat dx = movedTo.x - self.touchBegan.x;
    CGFloat dy = movedTo.y - self.touchBegan.y;
    CGAffineTransform translation = CGAffineTransformMakeTranslation(dx, dy);
    self.photoLayer.affineTransform = CGAffineTransformConcat(self.photoLayer.affineTransform, translation);
    self.touchBegan = movedTo;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end