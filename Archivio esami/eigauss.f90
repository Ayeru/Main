program eigauss
implicit none
real :: z,ei,t,a,b
real, external :: fi, gauss
write(*,*) "Inserire la variabile t > 0."
read(*,*) t
!t = 1
a = 0
z = ei(gauss,t)
print*, "ei(t)= ",z
end program

real function f(x)
implicit none
real :: x
f = (exp(x)-1)/x
end function

real function fi(a,t,f,u)
implicit none
real :: u,a,t
real, external :: f
fi = 0.5*(t-a)*f(0.5*(t-a)*u+0.5*(t+a))
end function

real function ei(gauss,t)
implicit none
real :: gamma, t
real, external :: fi, gauss
gamma = 0.5772157
ei = gamma + log(t) + gauss(fi,t)
end function

real function gauss(fi,t)
implicit none
real, external :: f,fi
real :: a,t,x,u
u = 0.5773502692
gauss = fi(a,t,f,(-1*u)) + fi(a,t,f,u)
end function