//
//  OpenGLUtil
//
//  Created by tyabuta on 2013/06/01.
//  Copyright (c) 2013 tyabuta. All rights reserved.
//

#ifndef TYABUTA_OPENGL_UTIL_H
#define TYABUTA_OPENGL_UTIL_H

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


/*
 * EAGLRenderingAPIOpenGLES1
 */
EAGLContext* GLContextCreate();

/*
 * GLテクスチャの読み込み関数
 * テクスチャ画像のサイズは2のべき乗でなければならない。
 */
GLuint GLTextureLoadImage(NSString* filename);




/*------------------------------------------------------------------------------
 * Draw functions
 -----------------------------------------------------------------------------*/

/*
 * 四角形の描画
 */
void GLDrawRectangle(GLfloat x, GLfloat y, GLfloat w, GLfloat h,
                     GLubyte r, GLubyte g, GLubyte b, GLubyte a);

/*
 * テクスチャの描画
 */
void GLDrawTexture(GLfloat x, GLfloat y, GLfloat w, GLfloat h,
                   GLuint texture,
                   GLfloat u, GLfloat v, GLfloat u_width, GLfloat v_height);


#endif // TYABUTA_OPENGL_UTIL_H
