//
//  AuthenticationResult.h
//  SoundCloudPLM
//
//  Created by Vasilii Muravev on 17.09.16.
//  Copyright © 2016 Vasilii Muravev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthResult : NSObject
@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *responseType;
@end
