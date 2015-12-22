//
//  SUIDBHelper.m
//  SUIToolKitDemo
//
//  Created by zzZ on 15/12/22.
//  Copyright © 2015年 SUIO~. All rights reserved.
//

#import "SUIDBHelper.h"
#import "SUIDBEntity.h"
#import "ReactiveCocoa.h"
#import "SUIMacros.h"
#import "LKDBHelper.h"

@interface SUIDBHelper ()

@property (nonatomic,strong) id searchTerm;
@property (nonatomic,copy) NSString *orderTerm;
@property (nonatomic) BOOL ascending;
@property (nonatomic,weak) id<SUIDBHelperDelegate> delegate;

@property (nonatomic,strong) NSMutableArray *sui_objects;

@end

@implementation SUIDBHelper


- (instancetype)initWithClass:(Class)modelClass where:(NSString *)searchTerm orderBy:(NSString *)orderTerm ascending:(BOOL)ascending delegate:(id<SUIDBHelperDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.searchTerm = searchTerm;
        self.orderTerm = orderTerm;
        self.ascending = ascending;
        self.delegate = delegate;
        [self commonInitWithClass:modelClass];
    }
    return self;
}

- (void)commonInitWithClass:(Class)modelClass
{
    [self searchForInitialObjectsWithClass:modelClass];

    [self registerForObjectChangeNotificationsWithClass:modelClass];
}

- (void)searchForInitialObjectsWithClass:(Class)modelClass
{
    LKDBHelper *curDBHelper = [modelClass getUsingLKDBHelper];
    NSMutableArray *curRusultAry = [curDBHelper search:modelClass where:self.searchTerm orderBy:self.orderTerm offset:0 count:0];
    if (curRusultAry.count > 0) {
        [self.sui_objects addObjectsFromArray:curRusultAry];
        
        if ([self.delegate respondsToSelector:@selector(sui_DBHelperWillChangeContent:)]) {
            [self.delegate sui_DBHelperWillChangeContent:self];
        }
        if ([self.delegate respondsToSelector:@selector(sui_DBHelper:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [self.sui_objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.delegate sui_DBHelper:self didChangeObject:obj atIndexPath:nil forChangeType:SUIDBHelperChangeInsert newIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
        }
        if ([self.delegate respondsToSelector:@selector(sui_DBHelperDidChangeContent:)]) {
            [self.delegate sui_DBHelperDidChangeContent:self];
        }
    }
}

- (void)registerForObjectChangeNotificationsWithClass:(Class)modelClass
{
    @weakify(self)
    [[gNotiCenter rac_addObserverForName:kSUIDBHelperObjectChangeNotifications object:nil] subscribeNext:^(NSNotification *cNoti) {
        @strongify(self)
        SUIDBEntity *curEntity = cNoti.object;
        if ([curEntity isKindOfClass:modelClass])
        {
            if (![self needDeleteEntity:curEntity])
            {
                if (![self needInsertEntity:curEntity])
                {
                    if (![self needUpdateEntity:curEntity])
                    {
                        return;
                    }
                }
            }
        }
    }];
}

- (NSInteger)replaceEntity:(SUIDBEntity *)cEntity inArray:(NSMutableArray *)cArray
{
    __block NSInteger curIndex = 0;
    [cArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SUIDBEntity *curEntity = obj;
        if (curEntity.rowid == cEntity.rowid) {
            curIndex = idx;
            *stop = YES;
        }
    }];
    
    [cArray replaceObjectAtIndex:curIndex withObject:cEntity];
    return curIndex;
}

- (BOOL)needDeleteEntity:(SUIDBEntity *)cEntity
{
    if (cEntity.sui_deleted && [self.sui_objects containsObject:cEntity])
    {
        [self deleteEntity:cEntity];
        return YES;
    }
    return NO;
}

- (void)deleteEntity:(SUIDBEntity *)cEntity
{
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperWillChangeContent:)]) {
        [self.delegate sui_DBHelperWillChangeContent:self];
    }
    NSInteger curIdx = [self.sui_objects indexOfObject:cEntity];
    [self.sui_objects removeObjectAtIndex:curIdx];
    if ([self.delegate respondsToSelector:@selector(sui_DBHelper:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:curIdx inSection:0];
        [self.delegate sui_DBHelper:self didChangeObject:cEntity atIndexPath:curIndexPath forChangeType:SUIDBHelperChangeDelete newIndexPath:nil];
    }
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperDidChangeContent:)]) {
        [self.delegate sui_DBHelperDidChangeContent:self];
    }
}

- (BOOL)needInsertEntity:(SUIDBEntity *)cEntity
{
    if (cEntity.sui_inserted)
    {
        if ([self checkEntityIsNeededForThisHelper:cEntity])
        {
            [self insertEntity:cEntity];
            return YES;
        }
    }
    return NO;
}

- (void)insertEntity:(SUIDBEntity *)cEntity
{
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperWillChangeContent:)]) {
        [self.delegate sui_DBHelperWillChangeContent:self];
    }
    NSMutableArray *curRusultAry = [cEntity.class searchWithWhere:self.searchTerm orderBy:self.orderTerm offset:0 count:0];
    [self.sui_objects removeAllObjects];
    [self.sui_objects addObjectsFromArray:curRusultAry];
    NSInteger curIdx = [self replaceEntity:cEntity inArray:self.sui_objects];
    if ([self.delegate respondsToSelector:@selector(sui_DBHelper:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:curIdx inSection:0];
        [self.delegate sui_DBHelper:self didChangeObject:cEntity atIndexPath:nil forChangeType:SUIDBHelperChangeInsert newIndexPath:curIndexPath];
    }
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperDidChangeContent:)]) {
        [self.delegate sui_DBHelperDidChangeContent:self];
    }
}

- (BOOL)checkEntityIsNeededForThisHelper:(SUIDBEntity *)cEntity
{
    id curSearchTerm = nil;
    if ([self.searchTerm isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *searchTermDict = [NSMutableDictionary dictionaryWithDictionary:self.searchTerm];
        [searchTermDict setObject:@(cEntity.rowid) forKey:@"rowid"];
        curSearchTerm = searchTermDict;
    }
    else if ([self.searchTerm isKindOfClass:[NSString class]] && ([LKDBUtils checkStringIsEmpty:self.searchTerm] == NO))
    {
        NSMutableString *searchTermString = [NSMutableString stringWithString:gFormat(@"rowid = %zd and ", cEntity.rowid)];
        [searchTermString appendString:self.searchTerm];
        curSearchTerm = searchTermString;
    }
    
    LKDBHelper *curDBHelper = [cEntity.class getUsingLKDBHelper];
    BOOL ret = [curDBHelper isExistsClass:cEntity.class where:curSearchTerm];
    return ret;
}

- (BOOL)needUpdateEntity:(SUIDBEntity *)cEntity
{
    if (cEntity.sui_updated)
    {
        if ([self checkEntityIsNeededForThisHelper:cEntity])
        {
            if ([self.sui_objects containsObject:cEntity])
            {
                [self updateEntity:cEntity];
            }
            else
            {
                [self insertEntity:cEntity];
            }
            return YES;
        }
        else if ([self.sui_objects containsObject:cEntity])
        {
            [self deleteEntity:cEntity];
            return YES;
        }
    }
    return NO;
}

- (void)updateEntity:(SUIDBEntity *)cEntity
{
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperWillChangeContent:)]) {
        [self.delegate sui_DBHelperWillChangeContent:self];
    }
    NSMutableArray *curRusultAry = [cEntity.class searchWithWhere:self.searchTerm orderBy:self.orderTerm offset:0 count:0];
    NSInteger eveIdx = [self replaceEntity:cEntity inArray:self.sui_objects];
    NSInteger curIdx = [self replaceEntity:cEntity inArray:curRusultAry];
    
    if (![curRusultAry isEqualToArray:self.sui_objects]) {
        [self.sui_objects removeAllObjects];
        [self.sui_objects addObjectsFromArray:curRusultAry];
        if ([self.delegate respondsToSelector:@selector(sui_DBHelper:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            NSIndexPath *eveIndexPath = [NSIndexPath indexPathForRow:eveIdx inSection:0];
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:curIdx inSection:0];
            [self.delegate sui_DBHelper:self didChangeObject:cEntity atIndexPath:eveIndexPath forChangeType:SUIDBHelperChangeMove newIndexPath:curIndexPath];
            [self.delegate sui_DBHelper:self didChangeObject:cEntity atIndexPath:curIndexPath forChangeType:SUIDBHelperChangeUpdate newIndexPath:nil];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(sui_DBHelper:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:curIdx inSection:0];
            [self.delegate sui_DBHelper:self didChangeObject:cEntity atIndexPath:curIndexPath forChangeType:SUIDBHelperChangeUpdate newIndexPath:nil];
        }
    }
    if ([self.delegate respondsToSelector:@selector(sui_DBHelperDidChangeContent:)]) {
        [self.delegate sui_DBHelperDidChangeContent:self];
    }
}


#pragma mark - Lazily instantiate

- (NSMutableArray *)sui_objects
{
    if (!_sui_objects) {
        _sui_objects = [NSMutableArray array];
    }
    return _sui_objects;
}


@end