import pygame
import random
from random import shuffle
import numpy as np
import copy 
import os
pygame.init()
white = (255, 255, 255)
# assigning values to height and width variable 
height = 1200
width = 960
# creating the display surface object 
# of specific dimension..e(X, Y). 
display_surface = pygame.display.set_mode((height, width))
global image_list
image_list=[]
# set the pygame window name 
pygame.display.set_caption('Image')
position_list = [[0,0],[240,0],[480,0],[720,0],
	[0,240],[240,240],[480,240],[720,240],
	[0,480],[240,480],[480,480],[720,480],
	[0,720],[240,720],[480,720],[720,720]]
path=os.getcwd()+"/img/"
labelpath=os.getcwd()+"/label/"
	#image = pygame.image.load(path+"123.jpg")
okmark=pygame.image.load(path+"ok_woman.png")
resetmark=pygame.image.load(path+"reset_buttn_off.png")
dic={}
allLabels={}
imagevector={}
def reset():

	global ChoosenImage
	ChoosenImage=[]
	global ChoosenLabel
	ChoosenLabel=[]
	global dic
	global vectorindex
	global labelvector
	global imagevector
	vectorindex=[]
	labelvector=[]
	
	global times
	times=0

	print("[INFO] loading images and labels...")

	for i in range(1419):#获取所有标签和向量位数
		f = open (labelpath+str(i)+'.txt','r',encoding="utf-8")
		i = i + 1
		lines = f.readlines()
		

		for line in lines:
			line = line.split("：" )
			l = line[1].strip('\n').strip(' ')
			if l not in vectorindex :
				vectorindex.append(l)
				labelvector.append(0)
	print(i)
	#print(label)
	#print(vectorindex)
	#print(labelvector)
	i=0
	for i in range(1419):#储存每一个图片和对应向量
		label=labelvector.copy()
		f = open (labelpath+str(i)+'.txt','r',encoding="utf-8")
		
		lines = f.readlines()
		for line in lines:
			line = line.split("：" )
			l = line[1].strip('\n').strip(' ')
			if l in vectorindex :
				j=vectorindex.index(l)
				label[j]=label[j]+1
		allLabels[i]=label
		#i = i + 1
		print(i)
	print(allLabels)
	
	
	
	global image_list
	image_list=[]
	while len(image_list)<16:
		for i in range(16):
			imageN=random.randint(0,1419)
			if str(imageN)+".jpg" not in image_list:
				image_list.append(str(imageN)+".jpg")
reset()


def cos_sim(vector_a, vector_b):
    """
    计算两个向量之间的余弦相似度
    :param vector_a: 向量 a 
    :param vector_b: 向量 b
    :return: sim
    """
    vector_a = np.mat(vector_a)
    vector_b = np.mat(vector_b)
    num = float(vector_a * vector_b.T)
    denom = np.linalg.norm(vector_a) * np.linalg.norm(vector_b)
    cos = num / denom
    sim = 0.5 + 0.5 * cos
    return sim

def resetbutton(x, y, w, h, inactive, active,action=None):
	
	mouse = pygame.mouse.get_pos()
	click = pygame.mouse.get_pressed()
	if x + w > mouse[0] > x and y + h > mouse[1] > y:
		display_surface.blit(active, (x, y))
        #print("jinle")
		if click[0] == 1 and action is not None:
			f=open(os.getcwd()+"/index.txt","w",encoding="utf-8")
			i=0
			import pandas as pd
			for line in vectorindex:
				f.write(line+'\n')
				
			f.close()
			f=open(os.getcwd()+"/vector.txt","w",encoding="utf-8")
			
			import pandas as pd
			for line in labelvector:
				f.write(str(line)+'\n')
				
			f.close()
			reset()
			main(image_list)
		else:
			display_surface.blit(inactive, (x, y))
def button(x, y, w, h, inactive, active, imageName,action=None):
	
	mouse = pygame.mouse.get_pos()
	click = pygame.mouse.get_pressed()
	if x + w > mouse[0] > x and y + h > mouse[1] > y:
		display_surface.blit(active, (x, y))
        #print("jinle")
		if click[0] == 1 and action is not None:
			
			imageN=imageName.strip('.jpg')

			global ChoosenImage
			global ChoosenLabel
			global dic
			
			
			
			for l in readLabels(imageN):#类别加权
				if l in vectorindex :
					i=vectorindex.index(l)
					
					labelvector[i]=labelvector[i]+1
			"""print(labelvector)
			print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')"""
			print("#################################")
			ChoosenImage.append(imageName)
			print("クリックした画像番号は",imageName)
			ChoosenLabel.append(readLabels(imageN))
			
				

				#print(imageN)
				
				#print(labelvector)
				#print(ChoosenLabel)
			if len(ChoosenImage) >= 3:
				print(ChoosenLabel)
				print(ChoosenImage)
				a = np.array(labelvector)
				#print(a)
				Smimag=[]
				Smimag=getsimilar(a)
				overlevel=1
				ChoosenLabel=[]
				image_list=[]
				for imageN in ChoosenImage :
					if imageN in image_list:
						
						overlevel=overlevel+1
						if overlevel==3:
							"""for l in readLabels(imageN):#类别加权
								if l in vectorindex :
									i=vectorindex.index(l)
									
									labelvector[i]=labelvector[i]+6"""
							print("あなたの選択は"+imageN+"号avatar")
							print("掛かった回数 "+str(times)+"回")
							f=open(os.getcwd()+"/index.txt","w",encoding="utf-8")
							i=0
							import pandas as pd
							for line in vectorindex:
								f.write(line+'\n')
								
							f.close()
							f=open(os.getcwd()+"/vector.txt","w",encoding="utf-8")
							
							import pandas as pd
							for line in labelvector:
								f.write(str(line)+'\n')
								
							f.close()
							 
							'''f.writelines(str(vectorindex)+str(labelvector))
							f.close()'''
					if imageN not in image_list:
						image_list.append(str(imageN))
				'''if times > 16 :
					for imageN in Smimag:
						if str(imageN+times)+".jpg" not in image_list:
							image_list.append(str(imageN+times)+".jpg")
				else:'''
				for imageN in Smimag:
					if str(imageN)+".jpg" not in image_list:
						image_list.append(str(imageN)+".jpg")
					
				while len(image_list)<16:
					i=len(image_list)
					#print('image_list len'+str(i))
					#print('+++++++++++++++++++++++')
					if imageN not in image_list:
						image_list.append(Smimag[i])
				while len(image_list)>16:
					i=len(image_list)
					image_list.pop()
					#print('-----------------------')

				ChoosenImage=[]
				#print(image_list)
				shuffle(image_list)
				print(image_list)
				#print("回数は"+str(times)+"回")
				main(image_list)
		

		'''if click[0] == 1 and action is not None:
            action()'''
	else:
		display_surface.blit(inactive, (x, y))
def getsimilar(vector):
	a = list(allLabels.values())
	mindist=[]
	for i in a :
		b=np.array(vector)
		dist = np.linalg.norm(i - b)

		mindist.append(dist)
	import heapq
	max_number = heapq.nlargest(20,mindist)
	min_number = heapq.nsmallest(100, mindist) 
	#print(min_number)
	min_index = []
	for t in min_number:
	    index = mindist.index(t)
	    min_index.append(index)
	    mindist[index] = 0
	for t in max_number:
	    index = mindist.index(t)
	    min_index.append(index)
	    mindist[index] = 0
	random.shuffle (min_index)
	#print(min_number)
	#print(min_index)
	return min_index
def readLabels(imageN):
	labels=[]
	f = open (labelpath+str(imageN)+'.txt','r', encoding="utf-8")
	lines = f.readlines()
	for line in lines:
		#line=line.strip('\n')
		line = line.split("：" )
		l = line[1].strip('\n').strip(' ')
		labels.append(l)
	return labels

# creating a surface object, image is drawn on it. 

import time
#position_list=[[0,0],]
# infinite loop 
y=0
display_surface.fill(white)
'''for i in range(16):
	img_name =  image_list[i]
	img_path = path+img_name
	position = position_list[i]
	x=position[0]
	y=position[1]
	
	print(img_path)
	image = pygame.image.load(img_path)
	image = pygame.transform.scale(image,(480,480))
	okmark=pygame.transform.scale(okmark,(480,480))
	button(x,y,480,480,image,okmark)
	
	print(x,y)'''
	#display_surface.blit(image, (x, y))
def main(image_list):
	global times
	times=times+1
	global num
	num=0
	path=os.getcwd()+"/img/"
	labelpath=os.getcwd()+"/label/"
	image = pygame.image.load(path+"123.jpg")
	okmark=pygame.image.load(path+"ok_woman.png")
	resetmark=pygame.image.load(path+"reset_buttn_off.png")
	pygame.display.update()
	while True:
		#dis#play_surface.
		'''for i in range(16):
			img_name =  image_list[i]
			img_path = path+img_name
			position = position_list[i]
			x=position[0]
			y=position[1]
			
			#print(img_path)
			image = pygame.image.load(img_path)
			image = pygame.transform.scale(image,(480,480))
			okmark=pygame.transform.scale(okmark,(480,480))

			button(x,y,480,480,image,okmark,img_name,readLabels)'''
			

			#print(x,y)
		#display_surface.blit(image, (x, y))
		#button(x,y,480,480,image,okmark)
		#time.sleep(1)
		for event in pygame.event.get():
			resetmark=pygame.transform.scale(resetmark,(240,240))
			resetbutton(960,0,240,240,resetmark,okmark,readLabels)
			for i in range(16):
				img_name =  image_list[i]
				img_path = path+img_name
				position = position_list[i]
				x=position[0]
				y=position[1]
				
				#print(img_path)
				image = pygame.image.load(img_path)
				image = pygame.transform.scale(image,(240,240))
				okmark=pygame.transform.scale(okmark,(240,240))
				
				button(x,y,240,240,image,okmark,img_name,readLabels)

			
			if event.type == pygame.QUIT:
				pygame.quit()
				# quit the program. 
				quit()
			# Draws the surface object to the screen. 
			pygame.display.update()
main(image_list)