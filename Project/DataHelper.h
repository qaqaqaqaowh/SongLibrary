//
//  DataHelper.h
//  Project
//
//  Created by NEXTAcademy on 12/4/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface DataHelper : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

-(NSManagedObjectContext *)managedObjectContext;

+(instancetype)shared;

- (void)saveContext;

@end
