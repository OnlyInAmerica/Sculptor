//
//  SCLMantleResponseSerializer.m
//  Sculptor
//
//  Created by David Caunt on 13/10/2013.
//  Copyright (c) 2013 David Caunt. All rights reserved.
//

#import "SCLMantleResponseSerializer.h"
#import <Mantle/Mantle.h>

@interface SCLMantleResponseSerializer ()
@property (nonatomic, strong, readwrite) id<SCLModelMatcher> modelMatcher;
@end

@implementation SCLMantleResponseSerializer

+ (instancetype)serializerWithModelMatcher:(id<SCLModelMatcher>)modelMatcher readingOptions:(NSJSONReadingOptions)readingOptions
{
	SCLMantleResponseSerializer *responseSerializer = [self serializerWithReadingOptions:readingOptions];
	responseSerializer.modelMatcher = modelMatcher;
	return responseSerializer;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	NSError *parentError = nil;
	id responseObject = [super responseObjectForResponse:response data:data error:&parentError];

	if (parentError != nil) {
		*error = parentError;
		return nil;
	}
	
	Class modelClass = [self.modelMatcher modelClassForResponse:response data:data];
	NSAssert(modelClass, @"Unable to match response URL %@ to a model class", response.URL);

	NSValueTransformer *JSONTransformer = nil;
	if ([responseObject isKindOfClass:[NSDictionary class]]) {
		JSONTransformer = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:modelClass];
	} else if ([responseObject isKindOfClass:[NSArray class]]) {
		JSONTransformer = [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:modelClass];
	} else {
		NSAssert(NO, @"Invalid JSON type returned by JSON response serializer");
	}
	
	return [JSONTransformer transformedValue:responseObject];
}

@end
