//
//  NSString+Additions.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "NSString+Additions.h"

#import <sys/xattr.h>

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additions)



- (NSString *) MD5 {
    // Create pointer to the string as UTF8
	const char* ptr = [self UTF8String];
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x",md5Buffer[i]];
	}
    
	return output;
}
@end
