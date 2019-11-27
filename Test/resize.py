# encoding: utf-8
from PIL import Image
import os

def main():
    #文件夹下所有文件名
    list = os.listdir('.')
    #images收集图片名
    images = []
    for file in list:
        if file.endswith('.png') or file.endswith('.jpg'):
            if '@' not in file:
                images.append(file)


    image = images[0]

    path = "result"
    if not os.path.exists(path):
        os.makedirs(path)

    for image in images:

        image2 = image[:-4] + '@2' + image[-4:]
        image3 = image[:-4] + '@3' + image[-4:]

        im = Image.open(image)
        (w,h) = im.size
        # 生成三倍图
        size = (w,h)
        im.thumbnail(size)
        im.save(path + '/' + image3, 'png')

        # 生成二倍图
        size = (w/3*2,h/3*2)
        im.thumbnail(size)
        im.save(path + '/' + image2, 'png')

        # 生成一倍图
#        os.remove("./" + image)
        size = (w/3,h/3)
        im.thumbnail(size)
        im.save(path + '/' + image, 'png')
        im.close

if __name__ == '__main__':
    main()
    # 上面只定义函数，可共享于其他文件
    # from module2 import foo 或者 import module3 或者 import module3 as m3
    # 下面代码只在本文件夹可执行

"""
    举个?
    执行前:
FileName |
         | resize.py
         | word.png(132*132)
         | image.png(132*132) PS: 这个是三倍图，生成的2倍1倍在result下
         | hel@2.png  PS:这张图片不会生成，因为名字含@
         
    执行后:
FileName |
         | resize.py
         | image.png(132*132)
         | word.png(132*132)
         | hel@2.png
         | result |
                  | image.png(44*44)
                  | image@2.png(88*88)
                  | image@3.png(132*132)
                  | word.png(44*44)
                  | word@2.png(88*88)
                  | word@3.png(132*132)
                  
      PS:
      1、在FileName下放三倍图,生成的2倍1倍存放在result下，并会重命名自身保存在result下
      1、会过滤图片名含@的图片
"""