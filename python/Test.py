print("Hello world!")

bikes = ['trek', 'redline', 'giant']

for bike in bikes:
 print(f"\nWelcome, {bike}!")
 print("We're so glad you joined!")


for bike in bikes:
 print(bike)


 str = "Scott"

 print(str)
 
#Create foilder
import os
path = "D:\Temp\TestPython"
# Check whether the specified path exists or not
isExist = os.path.exists(path)
if not isExist:
   # Create a new directory because it does not exist
    try: 
        os.makedirs(path)
        print("The new directory is created!")
    except OSError as err:
        print("Folder creation error:", err)
else:
   print("Directory already exists!")


#Date - Time
import time

foldername = (time.strftime("%d-%b-%Y_%H-%M"))
path = f"D:\Temp\TestPython\{foldername}"

print("Foldername: %s" % path)

isExist = os.path.exists(path)
if not isExist:
   # Create a new directory because it does not exist
    try: 
        os.makedirs(path)
        print(f"New directory {path} is created!")
    except OSError as err:
        print("Folder creation error:", err)
else:
   print(f"Directory {path} already exists!")

