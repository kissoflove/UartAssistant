//
// Created by 李坚 on 14-8-19.
// Copyright (c) 2014 lijian. All rights reserved.
//

#import "CharChangeUtil.h"

typedef enum {
    Number, UpperCase, LowerCase, Other
} char_type_e;

char_type_e charType(char ch) {
    if (ch >='0' && ch <= '9')
        return Number;
    else if (ch >= 'a' && ch <= 'f')
        return LowerCase;
    else if (ch >= 'A' && ch <= 'F')
        return UpperCase;
    return Other;
}

unsigned char changeToHex(char *str){
    int i = 0;
    char *temp = str;
    unsigned char result;
    char ch[2];

    if (strlen(temp) == 1) {
        switch(charType(temp[0])) {
            case Number:result = 0x0 | (*temp & 0x0f); break;
            case LowerCase:result = 0x0 | (*temp - 87); break;
            case UpperCase:result = 0x0 | (*temp - 55); break;
            default:result = 0x00; break;
        }
    } else {
        while (*temp) {
            switch(charType(*temp)) {
                case Number:ch[i] = (*temp & 0x0f); break;
                case LowerCase:ch[i] = (*temp - 87);break;
                case UpperCase:ch[i] = (*temp - 55);break;
                default:ch[i] = 0x00; break;
            }
            temp ++;
            i++;
        }
        result = (ch[0] << 4) | ch[1];
    }
    return result;
}

@implementation CharChangeUtil {

}

+ (int)stringToHex:(NSString *)str Hex:(unsigned char *)hex {
    int size=0;

    unsigned char ch;
    const char *c_str=[str UTF8String];
    char buff[2048];
    strcpy(buff,c_str);
    char *ptr = buff;
    char *temp = NULL;
    while (ptr && strlen(ptr)>0) {
        temp = strchr(ptr, ' ');//如果有多个空格，可换成while循环
        if (temp) {
            *temp++ = '\0';
        }
        if (strlen(ptr) > 2) ptr[2] = '\0';
        ch = changeToHex(ptr);
        ptr = temp;

        *hex++=ch;
        size++;
    }
    return size;
}

+ (NSString *)hexToString:(unsigned char *)hex Size:(int)size {
    char buff[16];
    NSMutableString *mutableString= [[NSMutableString alloc] init];
    for(int i=0;i<size;i++){
        sprintf(buff, "%02X ",hex[i]);
        [mutableString appendFormat:@"%s",buff];
    }

    return mutableString;
}

@end