include 'specialFunctions.f95'

!Trace rays to local XY plane
subroutine flat(x,y,z,l,m,n,ux,uy,uz,num)
  !Declarations
  integer, intent(in) :: num
  real*8, intent(in) :: l(num),m(num),n(num)
  real*8, intent(inout) :: x(num),y(num),z(num),ux(num),uy(num),uz(num)
  integer :: i
  real*8 :: dummy

  !Loop through rays
  !$omp parallel do private(delta)
  do i=1,num
    delta = -z(i)/n(i)
    z(i) = 0.
    x(i) = x(i) + delta*l(i)
    y(i) = y(i) + delta*m(i)
    ux(i) = 0.
    uy(i) = 0.
    uz(i) = 1.
    !print *, x(i),y(i),z(i)
    !print *, l(i),m(i),n(i)
    !print *, ux(i),uy(i),uz(i)
    !read *, dummy
  end do
  !$omp end parallel do

end subroutine flat

!Trace rays to local XY plane
subroutine flatOPD(x,y,z,l,m,n,ux,uy,uz,opd,num,nr)
  !Declarations
  integer, intent(in) :: num
  real*8, intent(in) :: l(num),m(num),n(num),nr
  real*8, intent(inout) :: x(num),y(num),z(num),ux(num),uy(num),uz(num),opd(num)
  integer :: i

  !Loop through rays
  !$omp parallel do private(delta)
  do i=1,num
    delta = -z(i)/n(i)
    z(i) = 0.
    x(i) = x(i) + delta*l(i)
    y(i) = y(i) + delta*m(i)
    ux(i) = 0.
    uy(i) = 0.
    uz(i) = 1.
    opd(i) = opd(i) + delta*nr
  end do
  !$omp end parallel do

end subroutine flatOPD

!Trace rays to spherical surface, center assumed to be at origin
!Intersection taken to be the closest point to ray
subroutine tracesphere(x,y,z,l,m,n,ux,uy,uz,num,rad)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8, intent(in) :: rad
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  integer :: i
  real*8 :: mago, dotol, determinant, d1, d2

  !Loop through rays
  !$omp parallel do private(dotol,mago,determinant,d1,d2)
  do i=1,num
    !Compute dot product
    dotol= l(i)*x(i) + m(i)*y(i) + n(i)*z(i)
    mago = x(i)**2. + y(i)**2. + z(i)**2.
    !Compute distance to move rays
    determinant = dotol**2 - mago + rad**2
    !If ray does not intersect, set position and cosine vector to NaN
    if (determinant < 0) then
      x(i) = 0.
      y(i) = 0.
      z(i) = 0.
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      d1 = -dotol + sqrt(determinant)
      d2 = -dotol - sqrt(determinant)
      if (abs(d2) < abs(d1)) then
        d1 = d2
      end if
      x(i) = x(i) + d1*l(i)
      y(i) = y(i) + d1*m(i)
      z(i) = z(i) + d1*n(i)
    end if
    !Compute surface normal, just normalized position vector
    mago = sqrt(x(i)**2 + y(i)**2 + z(i)**2)
    ux(i) = x(i)/mago
    uy(i) = y(i)/mago
    uz(i) = z(i)/mago
  end do
  !$omp end parallel do

end subroutine tracesphere

!Trace rays to spherical surface, center assumed to be at origin
!Intersection taken to be the closest point to ray
subroutine tracesphereOPD(opd,x,y,z,l,m,n,ux,uy,uz,num,rad,nr)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8, intent(in) :: rad,nr
  real*8 , intent(inout) :: opd(num),x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  integer :: i
  real*8 :: mago, dotol, determinant, d1, d2

  !Loop through rays
  !$omp parallel do private(dotol,mago,determinant,d1,d2)
  do i=1,num
    !Compute dot product
    dotol= l(i)*x(i) + m(i)*y(i) + n(i)*z(i)
    mago = x(i)**2. + y(i)**2. + z(i)**2.
    !Compute distance to move rays
    determinant = dotol**2 - mago + rad**2
    !If ray does not intersect, set position and cosine vector to NaN
    if (determinant < 0) then
      x(i) = 0.
      y(i) = 0.
      z(i) = 0.
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      d1 = -dotol + sqrt(determinant)
      d2 = -dotol - sqrt(determinant)
      if (abs(d2) < abs(d1)) then
        d1 = d2
      end if
      x(i) = x(i) + d1*l(i)
      y(i) = y(i) + d1*m(i)
      z(i) = z(i) + d1*n(i)
      opd(i) = opd(i) + d1*nr
    end if
    !Compute surface normal, just normalized position vector
    mago = sqrt(x(i)**2 + y(i)**2 + z(i)**2)
    ux(i) = x(i)/mago
    uy(i) = y(i)/mago
    uz(i) = z(i)/mago
  end do
  !$omp end parallel do

end subroutine tracesphereOPD


!Traces onto a cylinder
!Center is assumed to be at origin, y axis is cylindrical axis
subroutine tracecyl(x,y,z,l,m,n,ux,uy,uz,num,rad)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8, intent(in) :: rad
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  integer :: i
  real*8 :: a,b,c,mag,d1,d2,det,dum

  !$omp parallel do private(a,b,c,det,mag,d1,d2)
  !Compute a,b,c terms in quadratic solution for distance to move rays
  do i=1,num
    a = l(i)**2 + n(i)**2
    b = 2*(x(i)*l(i)+z(i)*n(i))
    c = x(i)**2 + z(i)**2 - rad**2
    !Compute determinant, if < 0, set ray to 0's
    det = b**2 - 4*a*c
    if (det < 0) then
      x(i) = 0.
      y(i) = 0.
      z(i) = 0.
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      !Find smallest distance to cylinder
      d1 = (-b + sqrt(det))/2/a
      d2 = (-b - sqrt(det))/2/a
      if (abs(d2) < abs(d1)) then
        d1 = d2
      end if
      !Move ray
      x(i) = x(i) + l(i)*d1
      y(i) = y(i) + m(i)*d1
      z(i) = z(i) + n(i)*d1
    end if
    !Compute surface normal
    mag = sqrt(x(i)**2+z(i)**2)
    ux(i) = x(i)/mag
    uz(i) = z(i)/mag
    uy(i) = 0.
  end do
  !$omp end parallel do

end subroutine tracecyl

!Traces onto a cylinder
!Center is assumed to be at origin, y axis is cylindrical axis
subroutine tracecylOPD(opd,x,y,z,l,m,n,ux,uy,uz,num,rad,nr)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8, intent(in) :: rad,nr
  real*8 , intent(inout) :: opd(num),x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  integer :: i
  real*8 :: a,b,c,mag,d1,d2,det,dum

  !$omp parallel do private(a,b,c,det,mag,d1,d2)
  !Compute a,b,c terms in quadratic solution for distance to move rays
  do i=1,num
    a = l(i)**2 + n(i)**2
    b = 2*(x(i)*l(i)+z(i)*n(i))
    c = x(i)**2 + z(i)**2 - rad**2
    !Compute determinant, if < 0, set ray to 0's
    det = b**2 - 4*a*c
    if (det < 0) then
      x(i) = 0.
      y(i) = 0.
      z(i) = 0.
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      !Find smallest distance to cylinder
      d1 = (-b + sqrt(det))/2/a
      d2 = (-b - sqrt(det))/2/a
      if (abs(d2) < abs(d1)) then
        d1 = d2
      end if
      !Move ray
      x(i) = x(i) + l(i)*d1
      y(i) = y(i) + m(i)*d1
      z(i) = z(i) + n(i)*d1
      opd(i) = opd(i) + d1*nr
    end if
    !Compute surface normal
    mag = sqrt(x(i)**2+z(i)**2)
    ux(i) = x(i)/mag
    uz(i) = z(i)/mag
    uy(i) = 0.
  end do
  !$omp end parallel do

end subroutine tracecylOPD

!This routine traces rays to a cylindrical conic surface
!z axis is cylindrical axis, rays have been traced to the xy
!plane, and sag is in the y direction
subroutine cylconic(x,y,z,l,m,n,ux,uy,uz,num,rad,k)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: rad,k
  real*8 :: low,high,dL,dH
  real*8 :: F,Fx,Fy,Fp,delt,dum
  integer :: i

  !Z derivative of surface function is 0 due to cylindrical symmetry
  !This is essentially a 2D problem

  !Loop through rays and trace to mirror
  !$omp parallel do private(delt,F,Fx,Fy,Fp,low,high,dL,dH)
  do i=1,num
    delt = 100.
    do while(abs(delt)>1.e-10)
      low = 1 + sqrt(1 - (1+k)*rad**2*x(i)**2)
      high = rad*x(i)**2
      dL = -(1+k)*rad**2*x(i) / sqrt(1 - (1+k)*rad**2*x(i)**2)
      dH = 2*rad*x(i)
      F = y(i) - high/low
      Fx = (high*dL - low*dH) / low**2
      Fy = 1.
      Fp = Fx*l(i) + Fy*m(i)
      delt = -F/Fp
      x(i) = x(i) + l(i)*delt
      y(i) = y(i) + m(i)*delt
      z(i) = z(i) + n(i)*delt
      !print *, x(i),y(i),z(i)
      !print *, F, Fp
      !print * ,delt
      !read *, dum
    end do
    Fp = sqrt(Fx*Fx+Fy*Fy)
    ux(i) = Fx/Fp
    uy(i) = Fy/Fp
    uz(i) = 0.
    !print *, x(i),y(i),z(i)
    !print *, ux(i),uy(i),uz(i)
    !read *, dum
  end do
  !$omp end parallel do

end subroutine cylconic

!Function to trace to a general conic
!Vertex assumed at origin, opening up in the +z direction
!Radius of curvature and conic constant are required parameters
!Traces to solution closest to vertex
subroutine conic(x,y,z,l,m,n,ux,uy,uz,num,R,K)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: R,K
  real*8 :: s1,s2,s,z1,z2,denom,b,c,disc,dummy
  integer :: i

  !Loop through rays and trace to the conic
  !$omp parallel do private(s,denom,b,c,disc,s1,s2,z1,z2)
  do i=1,num
    !Compute amount to move ray s
    s = 0.
    if (K .eq. -1 .and. abs(n(i))==1.) then
      s = (x(i)**2 + y(i)**2 - 2*R*z(i)) / (2*R*n(i))
    else
      denom = l(i)**2 + m(i)**2 + (K+1)*n(i)**2
      b = x(i)*l(i) + y(i)*m(i) + ((K+1)*z(i) - R)*n(i)
      b = b/denom
      c = x(i)**2 + y(i)**2 - 2*R*z(i) + (K+1)*z(i)**2
      c = c/denom
      disc = b**2 - c
      !print *, x(i)**2+y(i)**2
      !print *, denom,b,c,disc
      !read *, dummy
      if (disc .ge. 0.) then
        s1 = -b + sqrt(disc)
        s2 = -b - sqrt(disc)
        !Choose smallest distance
        if (abs(s1) .le. abs(s2)) then
          s = s1
        else
          s = s2
        end if
        !print *, s
        !read *, dummy
      end if
    end if
    !Advance ray
    if (s==0.) then
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      x(i) = x(i) + l(i)*s
      y(i) = y(i) + m(i)*s
      z(i) = z(i) + n(i)*s
      !Compute normal derivative
      denom = sqrt(R**2 - K*(x(i)**2+y(i)**2))
      ux(i) = -x(i) / denom
      uy(i) = -y(i) / denom
      uz(i) = -R/abs(R) * sqrt(R**2 - (K+1)*(x(i)**2+y(i)**2))
      uz(i) = -uz(i) / denom
    end if
  end do
  !$omp end parallel do

end subroutine conic

!Function to trace to a general conic
!Vertex assumed at origin, opening up in the +z direction
!Radius of curvature and conic constant are required parameters
!Traces to solution closest to vertex
subroutine conicopd(opd,x,y,z,l,m,n,ux,uy,uz,num,R,K,nr)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num),opd(num)
  real*8, intent(in) :: R,K,nr
  real*8 :: s1,s2,s,z1,z2,denom,b,c,disc
  integer :: i

  !Loop through rays and trace to the conic
  !$omp parallel do private(s,denom,b,c,disc,s1,s2,z1,z2)
  do i=1,num
    !Compute amount to move ray s
    s = 0.
    if (K .eq. -1 .and. abs(n(i))==1.) then
      s = (x(i)**2 + y(i)**2 - 2*R*z(i)) / (2*R*n(i))
    else
      denom = l(i)**2 + m(i)**2 + (K+1)*n(i)**2
      b = x(i)*l(i) + y(i)*m(i) + ((K+1)*z(i) - R)*n(i)
      b = b/denom
      c = x(i)**2 + y(i)**2 + (K+1)*z(i)**2 - 2*R*z(i)
      c = c/denom
      disc = b**2 - c
      if (disc .ge. 0.) then
        s1 = -b + sqrt(disc)
        s2 = -b - sqrt(disc)
        !Choose smallest distance
        if (abs(s1) .le. abs(s2)) then
          s = s1
        else
          s = s2
        end if
      end if
    end if
    !Advance ray
    if (s==0.) then
      l(i) = 0.
      m(i) = 0.
      n(i) = 0.
    else
      x(i) = x(i) + l(i)*s
      y(i) = y(i) + m(i)*s
      z(i) = z(i) + n(i)*s
      opd(i) = opd(i) + s*nr
      !Compute normal derivative
      denom = sqrt(R**2 - K*(x(i)**2+y(i)**2))
      ux(i) = -x(i) / denom
      uy(i) = -y(i) / denom
      uz(i) = -R/abs(R) * sqrt(R**2 - (K+1)*(x(i)**2+y(i)**2))
      uz(i) = -uz(i) / denom
    end if
  end do
  !$omp end parallel do

end subroutine conicopd

!Trace an ideal paraxial lens
subroutine paraxial(x,y,z,l,m,n,ux,uy,uz,num,F)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: F
  integer :: i

  !Loop through rays and apply appropriate perturbations to cosines
  !$omp parallel do
  do i=1,num
    !Compute 
    l(i) = l(i) - x(i)/F
    m(i) = m(i) - y(i)/F
  end do
  !$omp end parallel do

end subroutine paraxial

!Trace an ideal paraxial lens
subroutine paraxialY(x,y,z,l,m,n,ux,uy,uz,num,F)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: F
  integer :: i

  !Loop through rays and apply appropriate perturbations to cosines
  !$omp parallel do
  do i=1,num
    !Compute 
    m(i) = m(i) - y(i)/F
  end do
  !$omp end parallel do

end subroutine paraxialY

!Trace rays to a torus. Outer radius is in xy plane, inner radius is
!orthogonal. Geometry and equations taken from 
!http://www.emeyex.com/site/projects/raytorus.pdf
!Will also need routine to determine groove geometry
!and apply grating equation over torus
!Shifted equations to be with respect to tangent plane

subroutine torus(x,y,z,l,m,n,ux,uy,uz,num,rin,rout)
  !Declarations
  implicit none
  integer, intent(in) :: num
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: rin,rout
  real*8 :: F,Fx,Fy,Fz,Fp,delt,dum
  integer :: i

  !Loop through rays and trace to mirror
  !$omp parallel do private(delt,F,Fx,Fy,Fz,Fp)
  do i=1,num
    delt = 100.
    do while(abs(delt)>1.e-10)
      F = ((z(i)+rin+rout)**2+y(i)**2+x(i)**2+rout**2-rin**2)**2 - (4*rout**2*(y(i)**2+(z(i)+rin+rout)**2))

      Fx = 4*x(i) * (-rin**2+(rin+rout+z(i))**2+rout**2+x(i)**2+y(i)**2)
      Fy = 4*y(i) * (2*rin*(rout+z(i)) + 2*rout*z(i) + z(i)**2+y(i)**2+x(i)**2)
      Fz = 4*(rout+rin+z(i))*(2*rin*(rout+z(i)) + 2*rout*z(i)+z(i)**2+y(i)**2+x(i)**2)
      Fp = Fx*l(i) + Fy*m(i) + Fz*n(i)
      delt = -F/Fp
      !print *, x(i),y(i),z(i)
      !print *, F, Fp
      !print * ,delt
      !read *, dum
      x(i) = x(i) + l(i)*delt
      y(i) = y(i) + m(i)*delt
      z(i) = z(i) + n(i)*delt
    end do
    Fp = sqrt(Fx*Fx+Fy*Fy)
    ux(i) = Fx/Fp
    uy(i) = Fy/Fp
    uz(i) = Fz/Fp
    !print *, x(i),y(i),z(i)
    !print *, ux(i),uy(i),uz(i)
    !read *, dum
  end do
  !$omp end parallel do

end subroutine torus

!Function to trace to a general conic
!Vertex assumed at origin, opening up in the +z direction
!Radius of curvature and conic constant are required parameters
!Uses Newton shooting, with p as a vector of even polynomial terms
!p(1) is quadratic, p(2) is quartic, etc.
subroutine conicplus(x,y,z,l,m,n,ux,uy,uz,num,R,K,p,Np)
  !Declarations
  implicit none
  integer, intent(in) :: num,Np
  real*8, intent(in) :: p(Np)
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: R,K
  real*8 :: c,delt,rad,a0,a1,F,Fr,Fx,Fy,Fz,Fp,denom,dum
  integer :: i,j

  !Trace to conic first, then perform Newton shooting?
  Fz = 1.
  c = 1/R

  !Implement Newton shooting
  !Loop through rays and trace to mirror
  !$omp parallel do private(delt,rad,a0,a1,denom,j,F,Fr,Fx,Fy,Fp)
  do i=1,num
    delt = 100.
    do while(abs(delt)>1.e-10)
      !Compute summation terms
      rad = sqrt(x(i)**2+y(i)**2)
      a0 = 0.
      a1 = 0.
      do j=1,Np
        a0 = a0 + p(j)*rad**(2*j)
        a1 = a1 + p(j)*(2*j)*rad**(2*j-1)
      end do
      !Compute function and derivatives
      !F = rad**2 - 2*R*(z(i)-a0) + (K+1)*(z(i)-a0)**2
      denom = sqrt(1-(K+1)*c**2*rad**2)+1
      F = z(i) - c*rad**2 / denom + a0
      Fr = -(2*c*rad/denom + ((K+1)*rad**3*c**3)/(denom**2*sqrt(1-(K+1)*c**2*rad**2)))+a1
      Fx = Fr * x(i)/rad
      Fy = Fr * y(i)/rad
      Fp = Fx*l(i) + Fy*m(i) + Fz*n(i)
      delt = -F/Fp
      !print *, x(i),y(i),z(i)
      !print *, Fx,Fy,Fz
      !print *, F, Fp
      !print * ,delt
      !read *, dum
      x(i) = x(i) + l(i)*delt
      y(i) = y(i) + m(i)*delt
      z(i) = z(i) + n(i)*delt
    end do
    Fp = sqrt(Fx*Fx+Fy*Fy+Fz*Fz)
    ux(i) = Fx/Fp
    uy(i) = Fy/Fp
    uz(i) = Fz/Fp
    !print *, x(i),y(i),z(i)
    !print *, ux(i),uy(i),uz(i)
    !read *, dum
  end do
  !$omp end parallel do


end subroutine conicplus

!Function to trace to a general conic
!Vertex assumed at origin, opening up in the +z direction
!Radius of curvature and conic constant are required parameters
!Uses Newton shooting, with p as a vector of even polynomial terms
!p(1) is quadratic, p(2) is quartic, etc.
subroutine conicplusopd(opd,x,y,z,l,m,n,ux,uy,uz,num,R,K,p,Np,nr)
  !Declarations
  implicit none
  integer, intent(in) :: num,Np
  real*8, intent(in) :: p(Np)
  real*8 , intent(inout) :: opd(num),x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: R,K,nr
  real*8 :: c,delt,rad,a0,a1,F,Fr,Fx,Fy,Fz,Fp,denom,dum
  integer :: i,j

  !Trace to conic first, then perform Newton shooting?
  Fz = 1.
  c = 1/R

  !Implement Newton shooting
  !Loop through rays and trace to mirror
  !$omp parallel do private(delt,rad,a0,a1,denom,j,F,Fr,Fx,Fy,Fp)
  do i=1,num
    delt = 100.
    do while(abs(delt)>1.e-10)
      !Compute summation terms
      rad = sqrt(x(i)**2+y(i)**2)
      a0 = 0.
      a1 = 0.
      do j=1,Np
        a0 = a0 + p(j)*rad**(2*j)
        a1 = a1 + p(j)*(2*j)*rad**(2*j-1)
      end do
      !Compute function and derivatives
      !F = rad**2 - 2*R*(z(i)-a0) + (K+1)*(z(i)-a0)**2
      denom = sqrt(1-(K+1)*c**2*rad**2)+1
      F = z(i) - c*rad**2 / denom + a0
      !Fr = 2*rad + 2*R*a1 - (K+1)*2*(z(i)-a0)*a1
      Fr = -(2*c*rad/denom + ((K+1)*rad**3*c**3)/(denom**2*sqrt(1-(K+1)*c**2*rad**2)))+a1
      Fx = Fr * x(i)/rad
      Fy = Fr * y(i)/rad
      !Fz = -2*R + (K+1)*2*(z(i)-a0)
      Fp = Fx*l(i) + Fy*m(i) + Fz*n(i)
      delt = -F/Fp
      !print *, x(i),y(i),z(i)
      !print *, Fx,Fy,Fz
      !print *, F, Fp
      !print * ,delt
      !read *, dum
      x(i) = x(i) + l(i)*delt
      y(i) = y(i) + m(i)*delt
      z(i) = z(i) + n(i)*delt
      opd(i) = opd(i) + delt*nr
    end do
    Fp = sqrt(Fx*Fx+Fy*Fy+Fz*Fz)
    ux(i) = Fx/Fp
    uy(i) = Fy/Fp
    uz(i) = Fz/Fp
    !print *, x(i),y(i),z(i)
    !print *, ux(i),uy(i),uz(i)
    !read *, dum
  end do
  !$omp end parallel do


end subroutine conicplusopd

!Trace a surface defined by a 2D Legendre phase function
!xwidth and ywidth are halfwidths (redefining [-1,1] to [-xwidth,xwidth]
subroutine legSurf(x,y,z,l,m,n,ux,uy,uz,xwidth,ywidth,order,coeff,xo,yo,Nc,num)
  !Declarations
  implicit none
  integer, intent(in) :: num,Nc
  real*8 , intent(inout) :: x(num),y(num),z(num),l(num),m(num),n(num),ux(num),uy(num),uz(num)
  real*8, intent(in) :: coeff(Nc),xwidth,ywidth,order
  integer, intent(in) :: xo(Nc),yo(Nc)
  real*8 :: dphidx,dphidy,legendre,legendrep,dum
  integer :: i,j

  !Loop through rays and apply appropriate perturbations to cosines
  !$omp parallel do private(dphidx,dphidy)
  do i=1,num
    dphidx = 0;
    dphidy = 0;
    do j=1,Nc
      !Compute Legendre derivatives at x,y location
      dphidx = dphidx + coeff(j)*legendre(y(i)/ywidth,yo(j))*legendrep(x(i)/xwidth,xo(j))
      dphidy = dphidy + coeff(j)*legendrep(y(i)/ywidth,yo(j))*legendre(x(i)/xwidth,xo(j))
    end do
    l(i) = l(i) + dphidx*order/xwidth
    m(i) = m(i) + dphidy*order/ywidth
    n(i) = n(i)/abs(n(i)) * sqrt(1.-l(i)**2-m(i)**2)
  end do
  !$omp end parallel do

end subroutine legSurf
