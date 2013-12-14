//
//  UIDevice+Additions.m
//  X-Touch 2.0
//
//  Created by shengchao yang on 12-3-6.
//  Copyright (c) 2012年 home user. All rights reserved.
//

#import "UIDevice+Additions.h"
#import <dlfcn.h>
#include <sys/socket.h> // Per msqr  
#include <sys/sysctl.h>  
#include <net/if.h>  
#include <net/if_dl.h>  
#import <mach/port.h>
#import <mach/kern_return.h>
#include <mach/mach.h>
#import "NSString+Additions.h"

@interface UIDevice(Private)  
    - (NSString *) macaddress;  
@end  

@implementation UIDevice (Additions)
- (NSString *) serialNumber{
	NSString *serialNumber = nil;
	
	void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
	if (IOKit)
	{
		mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
		CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
		mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
		CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
		kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
		
		if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
		{
			mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
			if (platformExpertDevice)
			{
				CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
				if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
				{
					serialNumber = [NSString stringWithString:(NSString*)platformSerialNumber];
					CFRelease(platformSerialNumber);
				}
				IOObjectRelease(platformExpertDevice);
			}
		}
		dlclose(IOKit);
	}
	
	return serialNumber;
}
//可用内存(参考)
- (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

////////////////////////////////////////////////////////////////////////////////  
#pragma mark -  
#pragma mark Private Methods  

// Return the local MAC addy  
// Courtesy of FreeBSD hackers email list  
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.  
- (NSString *) macaddress{  
    int                 mib[6];  
    size_t              len;  
    char                *buf;  
    unsigned char       *ptr;  
    struct if_msghdr    *ifm;  
    struct sockaddr_dl  *sdl;  
    
    mib[0] = CTL_NET;  
    mib[1] = AF_ROUTE;  
    mib[2] = 0;  
    mib[3] = AF_LINK;  
    mib[4] = NET_RT_IFLIST;  
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {  
        printf("Error: if_nametoindex error\n");  
        return NULL;  
    }  
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {  
        printf("Error: sysctl, take 1\n");  
        return NULL;  
    }  
    
    if ((buf = malloc(len)) == NULL) {  
        printf("Could not allocate memory. error!\n");  
        return NULL;  
    }  
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {  
        printf("Error: sysctl, take 2");  
        return NULL;  
    }  
    
    ifm = (struct if_msghdr *)buf;  
    sdl = (struct sockaddr_dl *)(ifm + 1);  
    ptr = (unsigned char *)LLADDR(sdl);  
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",   
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];  
    free(buf);  
    return outstring;  
}  

////////////////////////////////////////////////////////////////////////////////  
#pragma mark -  
#pragma mark Public Methods  
- (NSString *) uniqueDeviceIdentifier{  
    NSString *macaddress = [[UIDevice currentDevice] macaddress];  
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];  
    NSString *uniqueIdentifier = [stringToHash stringFromMD5];    
    return uniqueIdentifier;  
}  
- (NSString *) uniqueGlobalDeviceIdentifier{  
    NSString *macaddress = [[UIDevice currentDevice] macaddress];  
    NSString *uniqueIdentifier = [macaddress stringFromMD5];      
    return uniqueIdentifier;  
}  
@end
