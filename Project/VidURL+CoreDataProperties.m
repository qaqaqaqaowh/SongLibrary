//
//  VidURL+CoreDataProperties.m
//  Project
//
//  Created by NEXTAcademy on 12/4/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "VidURL+CoreDataProperties.h"

@implementation VidURL (CoreDataProperties)

+ (NSFetchRequest<VidURL *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VidURL"];
}

@dynamic string;

@end
