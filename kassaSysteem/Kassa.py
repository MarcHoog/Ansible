from tkinter import *
from tkinter import scrolledtext
from tkinter import messagebox
from tkinter import font
from tkinter.ttk import Progressbar
from tkinter import filedialog
from tkinter import Menu


window = Tk()
window.geometry = ('1920x1080')
window.title("Doekoe Kassa systemen 2020")


#ITEMS
def helloCallBack(row,item,buttontext,price):
    messagebox.showinfo("infobox",f"{buttontext},item = {item} ${price}")
 
#Frames
left_frame = Frame(window, width=500, height= 900)
left_frame.grid(row=0, column=0, padx=10, pady=5)
right_frame = Frame(window, width=650, height=400)
right_frame.grid(row=0, column=1, padx=10, pady=5)
right_bellowframe = Frame(window,width=650, height=50) 
right_bellowframe.grid(row=1,column=1,padx=10, pady=5)

#NON DYNMAIC ITEMS
items = Label(right_frame,width=100,height=50, font=("Arial Bold",10),bg='light grey')
items.grid(row=0,column=1)
sendbutton = Button(right_bellowframe,text='PAY',width=15,height=2, font=("Arial Bold",10))
sendbutton.grid(row=0,column=0)


#DYNAMIC BUTTONS BASED ON INPUT
def Create_buttons(row,item,price):
    buttonleft  = Button(left_frame,text='<<',width=15,height=2, font=("Arial Bold",10),
                                        command=lambda 
                                        row=r,item=item,buttontext='<<',price=price
                                        :helloCallBack(row,item,buttontext,price))
    
    namelabel = Label(left_frame,text=f'{item}',width=15,height=2, font=("Arial Bold",10))
    
    pricelabel = Label(left_frame,text=f'{price}',width=5,height=2,font=("Arial Bold",10))
    
    buttonright  = Button(left_frame,text='>>',width=15,height=2, font=("Arial Bold",10),
                                        command=lambda 
                                        row=r,item=item,buttontext='>>',price=price
                                        :helloCallBack(row,item,buttontext,price))
    
    
    buttonleft.grid(column=1,row=r)
    namelabel.grid(column=2,row=r)
    pricelabel.grid(column=3,row=r)
    buttonright.grid(column=4,row=r)

   

items = ['Frikandel','Kroket','Gehaktbal']
for r in range(len(items)):      
        Create_buttons(row=r,item=items[r],price='2.75')
       
                    
window.mainloop()