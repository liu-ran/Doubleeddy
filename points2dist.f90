SUBROUTINE points2dist(points_num, lat_point,lat_points,lon_point,lon_points,r_point,r_points,match_use)

    IMPLICIT NONE

    integer :: i
    integer :: points_num
    real(kind=8) :: m_lldist, dist_ref
    real(kind=8), dimension(2) :: long_ref, lat_ref, long_cache , lat_cache
    real(kind=8), dimension(points_num) :: dists
    real(kind=8), dimension(:) :: lat_points , lon_points , r_points
    real(kind=8) :: lat_point,lon_point,r_point
    integer, dimension(points_num):: match_use
    !f2py intent(in) :: lat_point,lat_points,lon_point,lon_points,points_num,r_point,r_points
    !f2py intent(out) :: match_use
    
!    print *, size(lat_points,1)
!    print *, points_num

    long_ref = (/0.,0.5/)
    lat_ref  = (/0.,0./)
    dist_ref = m_lldist(long_ref,lat_ref)

    do i = 1, points_num
        long_cache = (/lon_point,lon_points(i)/)
        lat_cache  = (/lat_point,lat_points(i)/)
        dists(i) = m_lldist(long_cache, lat_cache)
    end do

    do i = 1, points_num
        
        if (dists(i) <= r_point + r_points(i) + dist_ref) then
            match_use(i) = i
        else
            match_use(i) = -1
        endif

    end do

    RETURN

END SUBROUTINE points2dist


Real(kind=8) function m_lldist(long,lat)
implicit none

real( kind=8 ) :: pi, pi180, earth_radius, long1, long2, lat1, lat2, dlon, dlat, a, angles
real( kind=8 ) , dimension(2), intent(in) :: long, lat


pi = 3.14159265;
pi180=pi/180.;
earth_radius=6378.137; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! km

long1=long(1) *pi180;  !!!!!!!!!!!!!!!!!(�� --->>> rad)
long2=long(2) *pi180;  !!!!!!!!!!!!!!!!!(�� --->>> rad)
lat1=  lat(1) *pi180;  !!!!!!!!!!!!!!!!!(�� --->>> rad)
lat2=  lat(2) *pi180;  !!!!!!!!!!!!!!!!!(�� --->>> rad)

dlon = long2 - long1; 
dlat = lat2 - lat1; 
a = (sin(dlat/2.))**2 + cos(lat1) * cos(lat2) * (sin(dlon/2.))**2;
angles = 2. * atan2( sqrt(a), sqrt(1.-a) );
m_lldist = earth_radius * angles;



end function m_lldist