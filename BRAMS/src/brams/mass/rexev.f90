!############################# Change Log ##################################################
! 5.0.0
!
!###########################################################################################
!  Copyright (C)  1990, 1995, 1999, 2000 - All Rights Reserved
!  Regional Atmospheric Modeling System - RAMS
!  Mission Research Corporation / *ASTeR Division
!###########################################################################################

subroutine exevolve(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt,key)

  use mem_basic,   only: basic_g
  use mem_grid,    only: grid_g, itopo
  use mem_mass,    only: mass_g
  use mem_tend,    only: tend
  use mem_scratch, only: scratch
  use therm_lib,   only: vapour_on

  implicit none

  character(len=*) , intent(in) :: key
  integer          , intent(in) :: m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,jdim,mynum
  real             , intent(in) :: edt
  !---- Local variables -------------------------------------------------------------------!
  integer :: i,j,k

  select case (trim(key))
  case ('ADV')
     ! Initialization
     call thvlastzero(m1,m2,m3,ia,iz,ja,jz,mass_g(ifm)%thvlast(1,1,1))

     ! Calculate advective term
     call exadvlf(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,itopo                    &
       ,grid_g(ifm)%rtgu          (1,1)   ,grid_g(ifm)%fmapui        (1,1)   &
       ,grid_g(ifm)%rtgv          (1,1)   ,grid_g(ifm)%fmapvi        (1,1)   &
       ,grid_g(ifm)%f13t          (1,1)   ,grid_g(ifm)%f23t          (1,1)   &
       ,grid_g(ifm)%rtgt          (1,1)   ,grid_g(ifm)%fmapt         (1,1)   &
       ,grid_g(ifm)%dxt           (1,1)   ,grid_g(ifm)%dyt           (1,1)   &
       ,basic_g(ifm)%uc           (1,1,1) ,basic_g(ifm)%dn0u         (1,1,1) &
       ,basic_g(ifm)%vc           (1,1,1) ,basic_g(ifm)%dn0v         (1,1,1) &
       ,basic_g(ifm)%dn0          (1,1,1) ,basic_g(ifm)%wc           (1,1,1) &
       ,basic_g(ifm)%pc           (1,1,1) ,tend%pt                   (1)     )
     ! Calculate compression term
     call excondiv(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,itopo                   &
         ,basic_g(ifm)%uc         (1,1,1) ,basic_g(ifm)%vc           (1,1,1) &
         ,basic_g(ifm)%wc         (1,1,1) ,basic_g(ifm)%pc           (1,1,1) &
         ,tend%pt                 (1)     ,grid_g(ifm)%dxt           (1,1)   &
         ,grid_g(ifm)%dyt         (1,1)   ,grid_g(ifm)%rtgt          (1,1)   &
         ,grid_g(ifm)%rtgu        (1,1)   ,grid_g(ifm)%rtgv          (1,1)   &
         ,grid_g(ifm)%f13t        (1,1)   ,grid_g(ifm)%f23t          (1,1)   &
         ,grid_g(ifm)%fmapt       (1,1)   ,grid_g(ifm)%fmapui        (1,1)   &
         ,grid_g(ifm)%fmapvi      (1,1)   )
     ! Put theta_v from last timestep into memory
     if (vapour_on) then
        call fill_thvlast(m1,m2,m3,ia,iz,ja,jz                          &
            ,mass_g(ifm)%thvlast (1,1,1) ,basic_g(ifm)%theta   (1,1,1) &
            ,basic_g(ifm)%rtp     (1,1,1) ,basic_g(ifm)%rv      (1,1,1) )
     else
        !MLO - If this is a dry run, then send a dummy array of zeroes to avoid
        !      segmentation violation.
        call azero(m1*m2*m3,scratch%vt3dq(1))
        call fill_thvlast(m1,m2,m3,ia,iz,ja,jz                          &
            ,mass_g(ifm)%thvlast (1,1,1) ,basic_g(ifm)%theta   (1,1,1) &
            ,scratch%vt3dq        (1)     ,scratch%vt3dq        (1)     )
     end if
     
  case ('THA')
     if (vapour_on) then
        call advect_theta(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt   &
            ,basic_g(ifm)%up      (1,1,1) ,basic_g(ifm)%uc      (1,1,1) &
            ,basic_g(ifm)%vp      (1,1,1) ,basic_g(ifm)%vc      (1,1,1) &
            ,basic_g(ifm)%wp      (1,1,1) ,basic_g(ifm)%wc      (1,1,1) &
            ,basic_g(ifm)%pi0     (1,1,1) ,basic_g(ifm)%pc      (1,1,1) &
            ,tend%pt              (1)     ,basic_g(ifm)%theta   (1,1,1) &
            ,basic_g(ifm)%rtp     (1,1,1) ,basic_g(ifm)%rv      (1,1,1) &
            ,basic_g(ifm)%dn0     (1,1,1) ,basic_g(ifm)%dn0u    (1,1,1) &
            ,basic_g(ifm)%dn0v    (1,1,1) ,grid_g(ifm)%rtgt     (1,1)   &
            ,grid_g(ifm)%rtgu     (1,1)   ,grid_g(ifm)%rtgv     (1,1)   &
            ,grid_g(ifm)%fmapt    (1,1)   ,grid_g(ifm)%fmapui   (1,1)   &
            ,grid_g(ifm)%fmapvi   (1,1)   ,grid_g(ifm)%f13t     (1,1)   &
            ,grid_g(ifm)%f23t     (1,1)   ,grid_g(ifm)%dxu      (1,1)   &
            ,grid_g(ifm)%dyv      (1,1)   ,grid_g(ifm)%dxt      (1,1)   &
            ,grid_g(ifm)%dyt      (1,1)   ,mass_g(ifm)%thvadv  (1,1,1)  &
            ,mass_g(ifm)%thetav  (1,1,1) )

     else
        call azero(m1*m2*m3,scratch%vt3dq(1))
        call advect_theta(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt   &
            ,basic_g(ifm)%up      (1,1,1) ,basic_g(ifm)%uc      (1,1,1) &
            ,basic_g(ifm)%vp      (1,1,1) ,basic_g(ifm)%vc      (1,1,1) &
            ,basic_g(ifm)%wp      (1,1,1) ,basic_g(ifm)%wc      (1,1,1) &
            ,basic_g(ifm)%pi0     (1,1,1) ,basic_g(ifm)%pc      (1,1,1) &
            ,tend%pt              (1)     ,basic_g(ifm)%theta   (1,1,1) &
            ,scratch%vt3dq        (1)     ,scratch%vt3dq        (1)     &
            ,basic_g(ifm)%dn0     (1,1,1) ,basic_g(ifm)%dn0u    (1,1,1) &
            ,basic_g(ifm)%dn0v    (1,1,1) ,grid_g(ifm)%rtgt     (1,1)   &
            ,grid_g(ifm)%rtgu     (1,1)   ,grid_g(ifm)%rtgv     (1,1)   &
            ,grid_g(ifm)%fmapt    (1,1)   ,grid_g(ifm)%fmapui   (1,1)   &
            ,grid_g(ifm)%fmapvi   (1,1)   ,grid_g(ifm)%f13t     (1,1)   &
            ,grid_g(ifm)%f23t     (1,1)   ,grid_g(ifm)%dxu      (1,1)   &
            ,grid_g(ifm)%dyv      (1,1)   ,grid_g(ifm)%dxt      (1,1)   &
            ,grid_g(ifm)%dyt      (1,1)   ,mass_g(ifm)%thvadv  (1,1,1) &
            ,mass_g(ifm)%thetav  (1,1,1) )

    end if
    
  case ('THS')
     if (vapour_on) then
        call storage_theta(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,mynum,edt   &
            ,basic_g(ifm)%pi0     (1,1,1) ,basic_g(ifm)%pc      (1,1,1) &
            ,basic_g(ifm)%rtp     (1,1,1) ,basic_g(ifm)%rv      (1,1,1) &
            ,basic_g(ifm)%theta   (1,1,1) ,mass_g(ifm)%thvlast (1,1,1)  &
            ,mass_g(ifm)%thvtend (1,1,1) ,tend%pt              (1)     )
     else
        call azero(m1*m2*m3,scratch%vt3dq(1))
        call storage_theta(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,mynum,edt   &
            ,basic_g(ifm)%pi0     (1,1,1) ,basic_g(ifm)%pc      (1,1,1) &
            ,scratch%vt3dq        (1)     ,scratch%vt3dq        (1)     &
            ,basic_g(ifm)%theta   (1,1,1) ,mass_g(ifm)%thvlast (1,1,1) &
            ,mass_g(ifm)%thvtend (1,1,1) ,tend%pt              (1)     )
     end if
  case default
     call abort_run('Unexpected key'//trim(key)//'!!!'                  &
                   ,'exevolve','rexev.f90')
  end select

  return
end subroutine exevolve

!==========================================================================================!
!==========================================================================================!
! �������������������������� Set of subroutines for key = 'ADV' �������������������������� !
!==========================================================================================!
!==========================================================================================!

!===========================================================================================
subroutine thvlastzero(m1,m2,m3,ia,iz,ja,jz,thvlast)
  implicit none
  integer , intent(in)                       :: m1,m2,m3,ia,iz,ja,jz
  real    , intent(out), dimension(m1,m2,m3) :: thvlast
  !----- Local variables
  integer :: i,j,k

  do i=ia,iz
    do j=ja,jz
      do k=1,m1
        thvlast(k,i,j) = 0.0
      end do
    end do
  end do

  return
end subroutine thvlastzero

!===========================================================================================
subroutine exadvlf(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,itopo                                 &
                  ,rtgu,fmapui,rtgv,fmapvi,f13t,f23t,rtgt,fmapt,dxt,dyt                    &
                  ,uc,dn0u,vc,dn0v,dn0,wc,pc,pt)
  use mem_grid, only : hw4,dzt
  implicit none
  integer , intent(in)                         :: m1,m2,m3,ia,iz,ja,jz,izu,jzv,itopo,jdim
  real    , intent(in)   , dimension(m2,m3)    :: rtgu,fmapui,rtgv,fmapvi,f13t,f23t
  real    , intent(in)   , dimension(m2,m3)    :: rtgt,fmapt,dxt,dyt
  real    , intent(in)   , dimension(m1,m2,m3) :: uc,dn0u,vc,dn0v,dn0,wc,pc
  real    , intent(inout), dimension(m1,m2,m3) :: pt

  !----- Local variables
  integer                                      :: i,j,k,im,jm
  real                                         :: c1z,c1x,c1y
  real    ,                dimension(m1,m2,m3) :: flxu,flxv,flxw

  ! Compute momentum fluxes flxu, flxv, flxw

  do j = 1,m3
     do i = 1,m2
        do k = 1,m1
           flxu(k,i,j) = uc(k,i,j) * dn0u(k,i,j) * rtgu(i,j) * fmapui(i,j)
           flxv(k,i,j) = vc(k,i,j) * dn0v(k,i,j) * rtgv(i,j) * fmapvi(i,j)
        enddo
     enddo
  enddo
  
  if(itopo == 0) then
     do j = 1,m3
        do i = 1,m2
           do k = 1,m1-1
              flxw(k,i,j) = wc(k,i,j) * .5 * (dn0(k,i,j) + dn0(k+1,i,j))
           enddo
        enddo
     enddo
  else
     do j = 1,m3
        jm = max(j-1,1)
        do i = 1,m2
           im = max(i-1,1)
           do k = 1,m1-1
              flxw(k,i,j) = wc(k,i,j) * .5 * (dn0(k,i,j) + dn0(k+1,i,j))  &
               + hw4(k) * ((flxu(k,i,j) + flxu(k+1,i,j)  &
                           + flxu(k,im,j) + flxu(k+1,im,j)) * f13t(i,j)  &
                           + (flxv(k,i,j) + flxv(k+1,i,j)  &
                           + flxv(k,i,jm) + flxv(k+1,i,jm)) * f23t(i,j))
           enddo
        enddo
     enddo
  endif
  
  ! Compute advection contribution to U tendency
  
  do j = ja,jz
     do i = ia,izu
        c1x = 0.5 / rtgt(i,j) * fmapt(i,j) * dxt(i,j)
        do k = 2,m1-1
           pt(k,i,j) = pt(k,i,j) - c1x / dn0(k,i,j) * (  &
                flxu(k,i,j)  &
                * (pc(k,i,j) + pc(k,i+1,j))  &
                - flxu(k,i-1,j)  &
                * (pc(k,i,j) + pc(k,i-1,j))  &
                - (flxu(k,i,j) - flxu(k,i-1,j)) * 2.* pc(k,i,j) )
        enddo
     enddo
  enddo

  do j=ja,jzv
     do i=ia,iz
        c1y = 0.5 / rtgt(i,j) * fmapt(i,j) * dyt(i,j)
        do k=2,m1-1
           pt(k,i,j)=pt(k,i,j) - c1y /dn0(k,i,j) * ( &
                flxv(k,i,j)  &
                * (pc(k,i,j)+pc(k,i,j+jdim))  &
                -flxv(k,i,j-jdim)  &
                * (pc(k,i,j)+pc(k,i,j-jdim))  &
                -  (flxv(k,i,j)-flxv(k,i,j-jdim))*2.*pc(k,i,j) )
        enddo
     enddo
  enddo
  
  do j=ja,jz
     do i=ia,iz
        c1z = 0.5 / rtgt(i,j)
        do k=2,m1-1
           pt(k,i,j)=pt(k,i,j) - c1z * dzt(k) /dn0(k,i,j) * ( &
                flxw(k,i,j)  &
                * (pc(k,i,j)+pc(k+1,i,j))  &
                -flxw(k-1,i,j)  &
                * (pc(k,i,j)+pc(k-1,i,j))  &
                -  (flxw(k,i,j)-flxw(k-1,i,j))*2.*pc(k,i,j) )
        enddo
     enddo
  enddo
  
  return
end subroutine exadvlf

!===========================================================================================

subroutine excondiv(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,itopo              &
                   ,uc,vc,wc,pc,pt                                       &
                   ,dxt,dyt,rtgt,rtgu,rtgv,f13t,f23t,fmapt,fmapui,fmapvi )
  use rconstants, only : rocv
  use mem_grid,   only : hw4,dzm
  implicit none
  
  integer , intent(in) :: m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,itopo
  real    , intent(in)    , dimension(m2,m3)    :: dxt,dyt,rtgt,rtgu,rtgv
  real    , intent(in)    , dimension(m2,m3)    :: f13t,f23t,fmapt,fmapui,fmapvi
  real    , intent(in)    , dimension(m1,m2,m3) :: uc,vc,wc,pc
  real    , intent(inout) , dimension(m1,m2,m3) :: pt
  !----- Local variables
  integer                                       :: i,j,k,im,jm
  real                                          :: c1z,c1x,c1y
  real, dimension(m1,m2,m3)                     :: flxu,flxv,flxw
                             
  ! Compute divergence
  !-----------
  ! Prep Fluxes
  !-----------
  
  !  These are:  (transformed velocities) times (a) times (mapfactor)
  do j=1,m3
     do i=1,m2
        do k=1,m1
           flxu(k,i,j)=uc(k,i,j)*rtgu(i,j)*fmapui(i,j)
           flxv(k,i,j)=vc(k,i,j)*rtgv(i,j)*fmapvi(i,j)
        enddo
     enddo
  enddo
  
  if(itopo == 0)then
     do j=1,m3
        do i=1,m2
           do k=1,m1-1
              flxw(k,i,j)=wc(k,i,j)
           enddo
        enddo
     enddo
  else
     do j=1,m3
        jm=max(j-1,1)
        do i=1,m2
           im=max(i-1,1)
           do k=1,m1-1
              flxw(k,i,j)=wc(k,i,j) &
                   + hw4(k) * ( (flxu(k,i,j)+flxu(k+1,i,j) &
                   +flxu(k,im,j) + flxu(k+1,im,j)) * f13t(i,j) &
                   + (flxv(k,i,j)+flxv(k+1,i,j) &
                   +flxv(k,i,jm) + flxu(k+1,i,jm)) * f23t(i,j)) 
           enddo
        enddo
     enddo
  endif
  
  do j=ja,jz
     do i=ia,izu
        c1x=fmapt(i,j)*dxt(i,j)/rtgt(i,j)
        do k=2,m1-1
           pt(k,i,j)=pt(k,i,j)     & 
                - c1x * ( flxu(k,i,j)-flxu(k,i-1,j) )   &
                * pc(k,i,j) * rocv
        enddo
     enddo
  enddo
  
  do j=ja,jzv
     do i=ia,iz
        c1y=fmapt(i,j)*dyt(i,j)/rtgt(i,j)
        do k=2,m1-1
           pt(k,i,j)=pt(k,i,j)  &
                - c1y * (flxv(k,i,j)-flxv(k,i,j-jdim) )  &
                * pc(k,i,j) *rocv
        enddo
     enddo
  enddo
  
  do j=ja,jz
     do i=ia,iz
        c1z=1.0/rtgt(i,j)
        do k=2,m1-1
           pt(k,i,j)=pt(k,i,j)  &
                - c1z * dzm(k) * (flxw(k,i,j)-flxw(k-1,i,j) )   &
                * pc(k,i,j) * rocv
        enddo
     enddo
  enddo
  
  return
end subroutine excondiv

!===========================================================================================
subroutine fill_thvlast(m1,m2,m3,ia,iz,ja,jz,thvlast,theta,rtp,rv)

  implicit none
  integer , intent(in)                         :: m1, m2, m3, ia, iz, ja, jz
  real    , intent(in)  , dimension(m1,m2,m3)  :: theta, rtp, rv
  real    , intent(out) , dimension(m1,m2,m3)  :: thvlast
  !-Local variables
  integer :: k, i, j

  do j=ja,jz
    do i=ia,iz
      do k=1,m1
        thvlast(k,i,j)=theta(k,i,j)*(1.0+1.61*rv(k,i,j))/(1.0+rtp(k,i,j))
      end do
    end do
  end do

  return
end subroutine fill_thvlast





!==========================================================================================!
!==========================================================================================!
! �������������������������� Set of subroutines for key = 'THA' �������������������������� !
!==========================================================================================!
!==========================================================================================!


!===========================================================================================
subroutine advect_theta(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt                        &
                       ,up,uc,vp,vc,wp,wc,pi0,pc,pt,theta,rtp,rv,dn0,dn0u,dn0v             &
                       ,rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi,f13t,f23t,dxu,dyv,dxt,dyt       &
                       ,thvadv,thetav)
  implicit none
  integer , intent(in)                          :: m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum
  real    , intent(in)                          :: edt 
  real    , intent(in)    , dimension(m1,m2,m3) :: up,uc,vp,vc,wp,wc,pi0,pc,rtp,theta,rv
  real    , intent(in)    , dimension(m1,m2,m3) :: dn0,dn0u,dn0v
  real    , intent(in)    , dimension(m2,m3)    :: rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi
  real    , intent(in)    , dimension(m2,m3)    :: f13t,f23t,dxu,dyv,dxt,dyt
  real    , intent(out)   , dimension(m1,m2,m3) :: thvadv,thetav
  real    , intent(inout) , dimension(m1,m2,m3) :: pt

  call exthvadv(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt                  &
               ,up,uc,vp,vc,wp,wc,theta,rtp,rv,dn0,dn0u,dn0v                 &
               ,rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi,f13t,f23t,dxu,dyv,dxt,dyt &
               ,thvadv,thetav)
  call exhtend_ad(m1,m2,m3,ia,iz,ja,jz,pi0,pc,theta,rtp,rv,pt,thvadv)
  return
end subroutine advect_theta

!===========================================================================================
subroutine exthvadv(m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum,edt                            &
                   ,up,uc,vp,vc,wp,wc,theta,rtp,rv,dn0,dn0u,dn0v                           &
                   ,rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi,f13t,f23t,dxu,dyv,dxt,dyt           &
                   ,thvadv,thetav)
  use mem_scratch, only : scratch,vctr1,vctr2
  implicit none
  integer, intent(in)                       :: m1,m2,m3,ia,iz,ja,jz,izu,jzv,jdim,mynum
  real   , intent(in)                       :: edt
  real   , intent(in) , dimension(m1,m2,m3) :: up,uc,vp,vc,wp,wc,theta,rtp,rv,dn0,dn0u,dn0v
  real   , intent(in) , dimension(m2,m3)    :: rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi,         &
                                               f13t,f23t,dxu,dyv,dxt,dyt
  real   , intent(out), dimension(m1,m2,m3) :: thvadv,thetav
  !----- Local variables ------------------------------------------------------------------!
  integer :: i,j,k

  call prep_vt3dabc(m1,m2,m3,edt,up,uc,vp,vc,wp,wc &
                   ,scratch%vt3da(1),scratch%vt3db(1),scratch%vt3dc(1))
  
  call prep_thetv(m1,m2,m3,ia,iz,ja,jz,theta,rtp,rv,thetav)
  
  call fa_preptc(m1,m2,m3 &
                ,scratch%vt3da(1),scratch%vt3db(1),scratch%vt3dc(1) &
                ,scratch%vt3dd(1),scratch%vt3de(1),scratch%vt3df(1) &
                ,scratch%vt3dh(1),scratch%vt3di(1),scratch%vt3dj(1) &
                ,scratch%vt3dk(1)                                   &
                ,dn0,dn0u,dn0v,rtgt,rtgu,rtgv,fmapt,fmapui,fmapvi   &
                ,f13t,f23t,dxu,dyv,dxt,dyt,mynum)

  call atob(m1*m2*m3,thetav,scratch%scr1(1))


  call fa_xc(m1,m2,m3,ia,iz,1,m3,thetav                          &
            ,scratch%scr1(1) ,scratch%vt3da(1),scratch%vt3dd(1)  &
            ,scratch%vt3dg(1),scratch%vt3dh(1),scratch%vt3di(1)  &
            ,mynum)

  if (jdim == 1)  &
    call fa_yc(m1,m2,m3,ia,iz,ja,jz,thetav                        &
            ,scratch%scr1(1) ,scratch%vt3db(1),scratch%vt3de(1)  &
            ,scratch%vt3dg(1),scratch%vt3dj(1),scratch%vt3di(1)  &
            ,jdim,mynum)
  
  call fa_zc(m1,m2,m3,ia,iz,ja,jz,thetav                         &
            ,scratch%scr1(1) ,scratch%vt3dc(1),scratch%vt3df(1)  &
            ,scratch%vt3dg(1),scratch%vt3dk(1),vctr1,vctr2,mynum )

  call azero(m1*m2*m3,thvadv)
  call advtndc(m1,m2,m3,ia,iz,ja,jz,thetav,scratch%scr1(1),thvadv,edt,mynum)
  do i=1,m2
    do j=1,m3
      do k=1,m1
        thvadv(k,i,j)=-1.0*thvadv(k,i,j)
      end do
    end do
  end do 
  
  return
end subroutine exthvadv

!===========================================================================================
subroutine prep_vt3dabc(m1,m2,m3,edt,up,uc,vp,vc,wp,wc,vt3da,vt3db,vt3dc)
  implicit none
  integer , intent(in) :: m1,m2,m3
  real    , intent(in) :: edt
  real    , intent(in)  , dimension(m1,m2,m3) :: up,uc,vp,vc,wp,wc
  real    , intent(out) , dimension(m1,m2,m3) :: vt3da,vt3db,vt3dc
  !------ Local variables
  integer :: i,j,k
  do j=1,m3
    do i=1,m2
      do k=1,m1
         vt3da(k,i,j) = 0.5 * edt * (up(k,i,j) + uc(k,i,j))
         vt3db(k,i,j) = 0.5 * edt * (vp(k,i,j) + vc(k,i,j))
         vt3dc(k,i,j) = 0.5 * edt * (wp(k,i,j) + wc(k,i,j))
      end do
    end do
  end do
  return
end subroutine prep_vt3dabc

!==========================================================================

subroutine prep_thetv(m1,m2,m3,ia,iz,ja,jz,theta,rtp,rv,thetav)
  use therm_lib, only: virtt
  implicit none
  integer , intent(in)                         :: m1,m2,m3,ia,iz,ja,jz
  real    , intent(in)   , dimension(m1,m2,m3) :: theta,rtp,rv
  real    , intent(out)  , dimension(m1,m2,m3) :: thetav
  !----- Local variables
  integer                                      :: i,j,k

  do i=1,m2
    do j=1,m3
      do k=1,m1
           thetav(k,i,j)=virtt(theta(k,i,j),rv(k,i,j),rtp(k,i,j))
      enddo
    enddo
  enddo
  
  return
end subroutine prep_thetv

!===========================================================================================

subroutine exhtend_ad(m1,m2,m3,ia,iz,ja,jz,pi0,pc,theta,rtp,rv,pt,thvadv)

  use rconstants, only: rocv
  use therm_lib, only: virtt
  implicit none
  
  integer , intent(in)                          :: m1,m2,m3,ia,iz,ja,jz
  real    , intent(in)    , dimension(m1,m2,m3) :: pi0,pc,rtp,theta,thvadv,rv
  real    , intent(inout) , dimension(m1,m2,m3) :: pt

  !----- Local variables 
  integer :: i,j,k
  
  do j=ja,jz
     do i=ia,iz
        do k=2,m1-1
           pt(k,i,j) = pt(k,i,j) + rocv * (pi0(k,i,j) + pc(k,i,j))  &
                / virtt(theta(k,i,j),rv(k,i,j),rtp(k,i,j)) * thvadv(k,i,j)
        end do
     end do
  end do
  
  return
end subroutine exhtend_ad






!==========================================================================================!
!==========================================================================================!
! �������������������������� Set of subroutines for key = 'THS' �������������������������� !
!==========================================================================================!
!==========================================================================================!


!===========================================================================================
subroutine storage_theta(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,mynum,edt,pi0,pc,rtp,rv              &
                        ,theta,thvlast,thvtend,pt)
  implicit none
  integer , intent(in)                         :: m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,mynum
  real    , intent(in)                         :: edt
  real    , intent(in)    ,dimension(m1,m2,m3) :: pi0,pc,rtp,rv,theta,thvlast
  real    , intent(out)   ,dimension(m1,m2,m3) :: thvtend
  real    , intent(inout) ,dimension(m1,m2,m3) :: pt
  
  call prep_thvtend(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,edt,theta,thvlast,rtp,rv,thvtend)
  call exhtend_st(m1,m2,m3,ia,iz,ja,jz,pi0,pc,rtp,theta,thvtend,rv,pt)
  return
end subroutine storage_theta


!===========================================================================================
subroutine prep_thvtend(m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv,edt,theta,thvlast,rtp,rv,thvtend)
  use mem_grid, only: time,dtlongn
  use therm_lib, only: virtt
  implicit none
  integer , intent(in)                       :: m1,m2,m3,ifm,ia,iz,ja,jz,izu,jzv
  real    , intent(in)                       :: edt
  real    , intent(in) , dimension(m1,m2,m3) :: theta,rv,rtp,thvlast
  real    , intent(out), dimension(m1,m2,m3) :: thvtend
  !----- Local variables ------------------------------------------------------------------!
  integer                                    :: i,j,k
  real                                       :: edti
  
  ! First time the subroutine is called in this node, leave it zero
  if (time < dtlongn(ifm)) then
    do i=ia,iz
      do j=ja,jz
        do k=2,m1-1
          thvtend(k,i,j) = 0.0
        end do
      end do
    end do
    return
  end if
  
  edti=1.0/edt
  
  do j=ja,jz
     do i=ia,iz
        do k=2,m1-1
           thvtend(k,i,j) = (  virtt(theta(k,i,j),rv(k,i,j),rtp(k,i,j))    &
                            -  thvlast(k,i,j)  )  * edti
        enddo
     enddo
  enddo
  
  return
end subroutine prep_thvtend

!===========================================================================================

subroutine exhtend_st(m1,m2,m3,ia,iz,ja,jz,pi0,pc,rtp,theta,thvtend,rv,pt)
  use rconstants, only : rocv
  use therm_lib, only: virtt
  implicit none
  integer , intent(in)                         :: m1,m2,m3,ia,iz,ja,jz
  real    , intent(in)   , dimension(m1,m2,m3) :: pi0,pc,rtp,theta,thvtend,rv
  real    , intent(inout), dimension(m1,m2,m3) :: pt
  !----- Local variables 
  integer :: i,j,k
  
  do j=ja,jz
     do i=ia,iz
        do k=2,m1-1
           pt(k,i,j) = pt(k,i,j) + rocv * (pi0(k,i,j) + pc(k,i,j))  &
                / virtt(theta(k,i,j),rv(k,i,j),rtp(k,i,j))  * thvtend(k,i,j)
        end do
     end do
  end do
  
  return
end subroutine exhtend_st