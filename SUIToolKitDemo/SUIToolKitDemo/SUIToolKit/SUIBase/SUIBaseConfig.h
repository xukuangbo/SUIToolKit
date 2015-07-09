//
//  SUIBaseConfig.h
//  SUIToolKitDemo
//
//  Created by zzZ on 15/6/26.
//  Copyright (c) 2015年 SUIO~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SUIBaseConfig : NSObject

+ (instancetype)sharedConfig;

/** default is whiteColor */
@property (nonatomic,strong) UIColor *backgroundColor;
/** default is 20,20,20,1 */
@property (nonatomic,strong) UIColor *separatorColor;
/** default is {0,10,0,0} */
@property (nonatomic,copy) NSString *separatorInset;
/** default is Default ... (None, Blue, Gray) */
@property (nonatomic,copy) NSString *selectionStyle;

/** default is POST (GET, POST) */
@property (nonatomic,copy) NSString *httpMethod;
@property (nonatomic,copy) NSString *httpHost;

/** default is 20 */
@property (nonatomic,assign) NSInteger pageSize;

// _____________________________________________________________________________

- (void)configureController:(id<SUIBaseProtocol>)curController;

- (void)configureTableView:(UITableView *)curTableView tvc:(BOOL)tvc;


@end
