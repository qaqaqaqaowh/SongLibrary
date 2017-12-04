//
//  VidURL+CoreDataProperties.h
//  Project
//
//  Created by NEXTAcademy on 12/4/17.
//  Copyright © 2017 asd. All rights reserved.
//

#import "VidURL+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VidURL (CoreDataProperties)

+ (NSFetchRequest<VidURL *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *string;

@end

NS_ASSUME_NONNULL_END
