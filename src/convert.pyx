import tpm

cdef _convert(list ra, list dec, int s1, int s2,
              double epoch, double equinox,
              double utc, double delta_ut, double delta_at,
              double lon, double lat, double alt,
              double xpole, double ypole,
              double T, double P, double H,
              double wavelength):
    """Utility function for coordinate conversion.

    Only for use from within Cython.
    """
    cdef int i
    tstate = tpm.TSTATE()
    pvec = tpm.PVEC()

    # Initialize TPM state.
    tpm.tpm_data(tstate, tpm.TPM_INIT)
    
    # Set independent quantities.
    tstate.utc = utc
    tstate.delta_ut = delta_ut
    tstate.delta_at = delta_at
    tstate.lon = lon
    tstate.lat = lat
    tstate.alt = alt
    tstate.xpole = xpole
    tstate.ypole = ypole
    tstate.T = T
    tstate.P = P
    tstate.H = H
    tstate.wavelength = wavelength

    tpm.tpm_data(tstate, tpm.TPM_ALL)

    ra_out = []
    dec_out = []
    for i in range(len(ra)):
        v6 = tpm.V6S()
        v6.r = 1e9
        v6.alpha = ra[i] 
        v6.delta = dec[i] 

        pvec[s1] = v6.s2c()
        tpm.tpm(pvec, s1, s2, epoch, equinox, tstate)
        v6 = pvec[s2].c2s()
    
        ra_out.append(v6.nalpha)
        dec_out.append(v6.ndelta)

    return ra_out, dec_out

def convert(ra=-999, dec=-999, double utc=-999, double delta_at=-999,
            double delta_ut=-999,
            int s1=tpm.TPM_S06, int s2=tpm.TARGET_OBS_AZEL,
            double epoch=tpm.J2000, double equinox=tpm.J2000,
            double lon=-111.598333,
            double lat=31.956389,
            double alt=2093.093,
            double xpole=0.0, double ypole=0.0,
            double T=273.15, double P=1013.25, double H=0.0,
            double wavelength=0.550):
    """Utility function for performing coordinate conversions.

    :param ra: Input longitudinal angle or angles, like ra, in degrees.
    :type ra: float
    :param de: Input latitudinal angle or angles, like dec, in degrees.
    :type de: float
    :param utc: "Current" UTC time as a Julian date.
    :type utc: float
    :param delta_at: TAI - UTC in seconds.
    :type delta_at: float
    :param delta_ut: UT1 - UTC in seconds.
    :type delta_ut: float
    :param s1: Initial state.
    :type s1: integer
    :param s2: Final state.
    :type s2: integer
    :param epoch: Epoch of input coordinates as a Julian date.
    :type epoch: float
    :param equniox: Equinox of input or output coordinates.
    :type equinox: float
    :param lon: Geodetic longitude in degeres.
    :type lon: float    
    :param lat: Geodetic latitude in degrees.
    :type lat: float
    :param alt: Altitude in meters.
    :type alt: float
    :param xpole: Polar motion in radians.
    :type xpole: float
    :param ypole: Ploar motion in radians.
    :type ypole: float
    :param T: Ambient temperature in Kelvin.
    :type T: float
    :param P: Ambient pressure in millibars.
    :type P: float
    :param H: Ambient humidity in the range 0-1.
    :type H: float
    :param wavelength: Wavelength of observation in microns.
    :type wavelength: float

    :return: Output angles, (ra_like, dec_like), in degrees
    :rtype:  One 2-element tuple, or a list of 2-element tuples, of floats

    Most often we just want to convert two angles from one coordinate
    system into another. We do not worry about proper motions and all
    conversions happen at the same "current time". This simplies the
    procedure a lot. Given a list of coordinates, most of the
    calculations need to be performed only once.

    This function performs such as coordinate conversion. It takes a
    list of ra like longitudinal angles in degrees, a list of dec like
    latitudinal angles and all parameters needed for performing a
    particular transformation. All of these parameters have defualts.

    The default location is KPNO and the values are taken from the TPM
    C code.

    If ``utc`` is not provided then it is set to J2000.0 AND BOTH
    ``delta_at`` and ``delta_ut`` ARE SET TO THEIR VALUES AT
    J2000.0. That is, if ``utc`` is not given then the specified values
    for these two are ignored. If ``utc`` is given but ``delta_at``
    and/or ``delta_ut`` is not given, then the missing value is set to
    that at the given ``utc``.

    The TPM state data structure is initialized, the independent
    parameters are set, and all the dependent parameters are calculated
    using ``tpm_data(tstate, TPM_INIT)``. This calculation is done only
    once. Then each of the coordinates are converted, by creating a
    ``V6`` vector and calling ``tpm()``.

    The returned result is a list of tuples, where each tuple has the
    final ra like angle as the first element, and the final de like
    angle as the second element. If the input coordinates are single
    values and not lists, then the output is a single 2-element tuple.
    
    For details on the parameters see the PyTPM reference documentation
    and the TPM manual. The latter gives an example for the usage of
    this function.
    """
    if ra == -999 or dec == -999:
        raise TypeError, "ra and dec cannot be empty."
    if utc == -999:
        # UTC not supplied set all three time scale values, ignoring
        # the given values of delta_at and delta_ut.
        utc = tpm.J2000
        delta_at = tpm.delta_AT(utc)
        delta_ut = tpm.delta_UT(utc)
    else:
        if delta_at == -999:
            delta_at = tpm.delta_AT(utc)
        if delta_ut == -999:
            delta_ut = tpm.delta_UT(utc)

    try:
        len(ra)
    except TypeError:
        # Not a list. Assume that this is a single number.
        ra = [tpm.d2r(ra)]
    else:
        ra = [tpm.d2r(i) for i in ra]        
    try:
        len(dec)
    except TypeError:
        # Not a list. Assume that this is a single number.
        dec = [tpm.d2r(dec)]
    else:
        dec = [tpm.d2r(i) for i in dec]
        
    if len(ra) != len(dec):
            raise ValueError, "Both ra and dec must be of equal length."

    lon = tpm.d2r(lon)
    lat = tpm.d2r(lat)

    ra_out, dec_out = _convert(ra, dec, s1,  s2, epoch,  equinox,
                              utc,  delta_ut, delta_at, lon, lat,
                              alt, xpole,  ypole, T,  P,  H,
                              wavelength)

    x = [(tpm.r2d(i), tpm.r2d(j)) for i,j in zip(ra_out, dec_out)]
    if len(x) == 1:
        return x[0]
    return x
