//
//  SUIMVVMRootTitleVM.m
//  SUIToolKitDemo
//
//  Created by RandomSuio on 16/1/11.
//  Copyright © 2016年 RandomSuio. All rights reserved.
//

#import "SUIMVVMRootTitleVM.h"
#import "SUIMVVMRootTitleMD.h"
#import "SUIToolKit.h"

@interface SUIMVVMRootTitleVM ()

@property (nonatomic,strong) SUIMVVMRootTitleMD *model;

@end

@implementation SUIMVVMRootTitleVM
@dynamic model;


- (void)sui_commonInit
{
    SUIVMRAC(text1, kw);
    RAC(self, text2) = [SUIVMObserve(numOfAlbums) map:^id(NSNumber *cNum) {
        return gFormat(@"num:%@",cNum);
    }];
    RAC(self, textColo1) = [SUIVMObserve(numOfAlbums) map:^id(id value) {
        return gRandomColo;
    }];
    RAC(self, textColo2) = [SUIVMObserve(numOfAlbums) map:^id(id value) {
        return gRandomColo;
    }];
}


@end
