//
//  OpenGLUtil
//
//  Created by tyabuta on 2013/06/01.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#import "OpenGLUtil.h"


EAGLContext* GLContextCreate(){
    EAGLContext* context =
    [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if (!context) {
        NSLog(@"Failed to create OpenGL ES context");
        return nil;
    }
    return context;
}


GLuint GLTextureLoadImage(NSString* filename){

    // UIImageを使って画像読み込み
    CGImageRef imageRef = [UIImage imageNamed:filename].CGImage;
    if (!imageRef){
        NSLog(@"Error: %@ not found", filename);
        return 0;
    }

    // データ配列を確保
    size_t width   = CGImageGetWidth(imageRef);
    size_t height  = CGImageGetHeight(imageRef);
    size_t memSize = width * height * 4;
    GLubyte* imageData = (GLubyte*)malloc(memSize);
    memset(imageData, 0, memSize);

    // CGContextを使って、データをコピーする。
    CGContextRef context =
    CGBitmapContextCreate(imageData,
                          width,
                          height,
                          8,
                          width*4,
                          CGImageGetColorSpace(imageRef),
                          kCGImageAlphaPremultipliedLast);
    if (NULL == context){
        NSLog(@"Error: context could not be created");
        return 0;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    // GLテクスチャーを生成
    GLuint texture = 0;
    glGenTextures(1, &texture);
    if (0 == texture){
        NSLog(@"Error: texture could not be generate");
        free(imageData);
        return 0;
    }
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, imageData);

    free(imageData);
    return texture;
}



/*------------------------------------------------------------------------------
 * Draw functions
 -----------------------------------------------------------------------------*/
#pragma mark - Draw functions

void GLDrawRectangle(GLfloat x, GLfloat y, GLfloat w, GLfloat h,
                     GLubyte r, GLubyte g, GLubyte b, GLubyte a)
{
    const GLfloat vertices[] = {
        x,   y,
        x+w, y,
        x,   y+h,
        x+w, y+h,
    };

    // アルファブレンド
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // 頂点座標設定
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, vertices);

    // カラー設定
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4ub(r, g, b, a);

    // 描画
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // 後始末
    glColor4ub(0xff, 0xff, 0xff, 0xff);
    glDisable(GL_BLEND);

}

void GLDrawTexture(GLfloat x, GLfloat y, GLfloat w, GLfloat h,
                   GLuint texture,
                   GLfloat u, GLfloat v, GLfloat u_width, GLfloat v_height){

    const GLfloat vertices[] = {
        x,   y,
        x+w, y,
        x,   y+h,
        x+w, y+h,
    };

    const GLfloat coords[] = {
        u,         v,
        u+u_width, v,
        u,         v+v_height,
        u+u_width, v+v_height,
    };

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
}











