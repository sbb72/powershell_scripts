from numpy import sqrt
print("You have an equation ax^2 +bx+c = 0")
a=float(input("a ="))
b=float(input("b ="))
c=float(input("c ="))

if a==0:
  print("What the what?? This is not a quadratic equation.")
  b=0
  c=0
  a=1

x1=(-b+sqrt(b**2-4*a*c))/(2*a)
x2=(-b-sqrt(b**2-4*a*c))/(2*a)


print("x1 = "+str(x1))
print("x2 = "+str(x2))