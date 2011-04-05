# -*- coding: utf-8 -*-
# The following line must be present in the pytpm.pyx file.
# cimport _tpm_vec

POS = _tpm_vec.POS
VEL = _tpm_vec.VEL
CARTESIAN = _tpm_vec.CARTESIAN
SPHERICAL = _tpm_vec.SPHERICAL
POLAR = _tpm_vec.POLAR

cdef class V3(object):
    """Class that wraps _tpm_vec.V3; for use from Cython only."""
    cdef _tpm_vec.V3 _v3

    def __cinit__(self):
        self._v3.type = CARTESIAN
        self._v3.v[0] = 0.0
        self._v3.v[1] = 0.0
        self._v3.v[2] = 0.0

    def __init__(self, ctype=CARTESIAN, X=0.0, Y=0.0, Z=0.0):
        self._v3.type = ctype
        self._v3.v[0] = X
        self._v3.v[1] = Y
        self._v3.v[2] = Z

    cdef int getType(self):
        return self._v3.type

    cdef setType(self, int t):
        self._v3.type = t
    
    cdef setX(self, double X):
        self._v3.v[0] = X
        
    cdef setY(self, double Y):
        self._v3.v[1] = Y

    cdef setZ(self, double Z):
        self._v3.v[2] = Z

    cdef double getX(self):
        return self._v3.v[0]
        
    cdef double getY(self):
        return self._v3.v[1]

    cdef double getZ(self):
        return self._v3.v[2]

    cdef _tpm_vec.V3 getV3(self):
        return self._v3

    cdef setV3(self, _tpm_vec.V3 _v3):
        self._v3 = _v3


cdef class V3CP(V3):
    """A V3 Cartesian position vector."""
    # The following are read only.
    ctype = CARTESIAN
    vtype = POS
    def __init__(self, x=0.0, y=0.0, z=0.0):
        self.x = x
        self.y = y
        self.z = z
        self.setType(self.ctype)

    def __getx(self):
        return self.getX()
    def __setx(self, x):
        self.setX(x)
    x = property(__getx, __setx, doc="X coordinate.")

    def __gety(self):
        return self.getY()
    def __sety(self, y):
        self.setY(y)
    y = property(__gety, __sety, doc="Y coordinate.")

    def __getz(self):
        return self.getZ()
    def __setz(self, z):
        self.setZ(z)
    z = property(__getz, __setz, doc="Z coordinate.")

    def c2s(self):
        """Convert Cartesian position vector into spherical vector."""
        cdef _tpm_vec.V3 _v3
        _v3 = _tpm_vec.v3c2s(self.getV3())
        #v3 = V3SP(r=_v3.v[0], alpha=_v3.v[1], delta=_v3[2])
        v3sp = V3SP()
        v3sp.setV3(_v3)
        return v3sp

    def __sub__(V3CP self, V3CP other):
        """Return V3CP that holds difference between two V3CPs."""
        if isinstance(self, V3CP) and isinstance(other, V3CP):
            v3cp = V3CP()
            v3cp.setV3(_tpm_vec.v3diff(self.getV3(), other.getV3()))
            return v3cp
        else:
            raise TypeError, "Can only subtract two V3CP values."

    def __add__(V3CP self, V3CP other):
        """Return V3CP that holds the sum of two V3CPs."""
        if isinstance(self, V3CP) and isinstance(other, V3CP):
            v3cp = V3CP()
            v3cp.setV3(_tpm_vec.v3sum(self.getV3(), other.getV3()))
            return v3cp
        else:
            raise TypeError, "Can only add two V3CP values."

    def __mul__(V3CP self, double n):
        """Scale X,Y and Z components with the scalar number."""
        v3cp = V3CP()
        v3cp.setV3(_tpm_vec.v3scale(self.getV3(), n))
        return v3cp
    
    def unit(self):
        """Return unit V3CP vector."""
        v3cp = V3CP()
        v3cp.setV3(_tpm_vec.v3unit(self.getV3()))
        return v3cp

    def mod(self):
        """Return modulus of the V3CP vector."""
        return _tpm_vec.v3mod(self.getV3())

    def dot(V3CP self, V3CP other):
        """Return the dot product of two V3CP vectors."""
        return _tpm_vec.v3dot(self.getV3(), other.getV3())

    def cross(V3CP self, V3CP other):
        """Return the cross product of two V3CP vectors."""
        v3cp = V3CP()
        v3cp.setV3(_tpm_vec.v3cross(self.getV3(), other.getV3()))
        return v3cp

    def __str__(self):
        """Return string representation of V3CP."""
        return self.__unicode__().encode("utf-8")

    def __unicode__(self):
        """Return unicode representation of V3CP."""
        s = _tpm_vec.v3fmt(self.getV3())
        return unicode(s)

    
cdef class V3SP(V3):
    """A V3 spherical position vector."""
    # The following are read only.
    ctype = SPHERICAL
    vtype = POS
    def __init__(self, r=0.0, alpha=0.0, delta=0.0):
        self.r = r
        self.alpha = alpha
        self.delta = delta
        self.setType(self.ctype)

    def __getr(self):
        return self.getX()
    def __setr(self, r):
        self.setX(r)
    r = property(__getr, __setr, doc="Radial coordinate.")

    def __getalpha(self):
        return self.getY()
    def __setalpha(self, alpha):
        self.setY(alpha)
    alpha = property(__getalpha, __setalpha, doc="Alpha coordinate.")

    def __getdelta(self):
        return self.getZ()
    def __setdelta(self, delta):
        self.setZ(delta)
    delta = property(__getdelta, __setdelta, doc="Delta coordinate.")

    def __getnalpha(self):
        return _tpm_vec.v3alpha(self.getV3())
    nalpha = property(__getnalpha, doc="Normalized alpha coordinate.")

    def __getndelta(self):
        return _tpm_vec.v3delta(self.getV3())
    ndelta = property(__getndelta, doc="Normalized alpha coordinate.")

    def s2c(self):
        """Convert spherical position vector into Cartesian vector."""
        cdef _tpm_vec.V3 _v3
        _v3 = _tpm_vec.v3s2c(self.getV3())
        v3cp = V3CP()
        v3cp.setV3(_v3)
        return v3cp
        
    def __sub__(V3SP self, V3SP other):
        """Return V3SP that holds difference between two V3SPs."""
        if isinstance(self, V3SP) and isinstance(other, V3SP):
            v3cp = V3CP()
            v3cp.setV3(_tpm_vec.v3diff(self.getV3(), other.getV3()))
            return v3cp.c2s()
        else:
            raise TypeError, "Can only subtract two V3SP values."

    def __add__(V3SP self, V3SP other):
        """Return V3SP that holds the sum of two V3SPs."""
        if isinstance(self, V3SP) and isinstance(other, V3SP):
            v3cp = V3CP()
            v3cp.setV3(_tpm_vec.v3sum(self.getV3(), other.getV3()))
            return v3cp.c2s()
        else:
            raise TypeError, "Can only add two V3SP values."

    def __mul__(V3SP self, double n):
        """Scale R with the scalar number."""
        v3sp = V3SP()
        v3sp.setV3(_tpm_vec.v3scale(self.getV3(), n))
        return v3sp

    def mod(self):
        """Return modulus of the V3SP vector; magnitude of R component."""
        return _tpm_vec.v3mod(self.getV3())

    def dot(V3SP self, V3SP other):
        """Return the dot product of two V3SP vectors."""
        return _tpm_vec.v3dot(self.getV3(), other.getV3())
    
    def cross(V3SP self, V3SP other):
        """Return the cross product of two V3SP vectors."""
        v3cp = V3CP()
        v3cp.setV3(_tpm_vec.v3cross(self.getV3(), other.getV3()))
        return v3cp.c2s()

    def __str__(self):
        """Return string representation of V3SP"""
        return self.__unicode__().encode("utf-8")

    def __unicode__(self):
        """Return unicode representation of V3SP"""
        s = _tpm_vec.v3fmt(self.getV3())
        return unicode(s)

cdef class V6(object):
    """Class that wraps _tpm_vec.V6; for use from Cython only."""
    cdef _tpm_vec.V6 _v6

    def __cinit__(self):
        self._v6.v[POS].type = CARTESIAN
        self._v6.v[POS].v[0] = 0.0
        self._v6.v[POS].v[1] = 0.0
        self._v6.v[POS].v[2] = 0.0
        self._v6.v[VEL].type = CARTESIAN
        self._v6.v[VEL].v[0] = 0.0
        self._v6.v[VEL].v[1] = 0.0
        self._v6.v[VEL].v[2] = 0.0

    def __init__(self, ctype=CARTESIAN, X=0.0, Y=0.0, Z=0.0,
                 Xdot=0.0, Ydot=0.0, Zdot=0.0):
        self._v6.v[POS].type = ctype
        self._v6.v[POS].v[0] = X
        self._v6.v[POS].v[1] = Y
        self._v6.v[POS].v[2] = Z
        self._v6.v[VEL].type = ctype
        self._v6.v[VEL].v[0] = Xdot
        self._v6.v[VEL].v[1] = Ydot
        self._v6.v[VEL].v[2] = Zdot

    cdef int getType(self):
        return self._v6.v[POS].type

    cdef setType(self, int t):
        self._v6.v[POS].type = t
        self._v6.v[VEL].type = t

    cdef getX(self):
        return self._v6.v[POS].v[0]

    cdef setX(self, double X):
        self._v6.v[POS].v[0] = X

    cdef getY(self):
        return self._v6.v[POS].v[1]

    cdef setY(self, double Y):
        self._v6.v[POS].v[1] = Y

    cdef getZ(self):
        return self._v6.v[POS].v[2]

    cdef setZ(self, double Z):
        self._v6.v[POS].v[2] = Z

    cdef getXdot(self):
        return self._v6.v[VEL].v[0]

    cdef setXdot(self, double Xdot):
        self._v6.v[VEL].v[0] = Xdot

    cdef getYdot(self):
        return self._v6.v[VEL].v[1]

    cdef setYdot(self, double Ydot):
        self._v6.v[VEL].v[1] = Ydot

    cdef getZdot(self):
        return self._v6.v[VEL].v[2]

    cdef setZdot(self, double Zdot):
        self._v6.v[VEL].v[2] = Zdot

    cdef _tpm_vec.V6 getV6(self):
        return self._v6

    cdef setV6(self, _tpm_vec.V6 _v6):
        self._v6 = _v6

    cdef _tpm_vec.V3 getPOS(self):
        return self._v6.v[POS]

    cdef setPOS(self, _tpm_vec.V3 _v3):
        if (_v3.type != self.getType()):
            raise ValueError, "Type of V3 must be the same as that of V6."
        self._v6.v[POS] = _v3

    cdef _tpm_vec.V3 getVEL(self):
        return self._v6.v[VEL]

    cdef setVEL(self, _tpm_vec.V3 _v3):
        if (_v3.type != self.getType()):
            raise ValueError, "Type of V3 must be the same as that of V6."
        self._v6.v[VEL] = _v3


cdef class V6C(V6):
    """Class for Cartesian V6 vector"""
    # The following is read only.
    ctype = CARTESIAN
    def __init__(self, x=0.0, y=0.0, z=0.0, xdot=0.0, ydot=0.0, zdot=0.0):
        self.x = x
        self.y = y
        self.z = z
        self.xdot = xdot
        self.ydot = ydot
        self.zdot = zdot

    def __getx(self):
        return self.getX()
    def __setx(self, x):
        self.setX(x)
    x = property(__getx, __setx, doc="X coordinate.")

    def __gety(self):
        return self.getY()
    def __sety(self, y):
        self.setY(y)
    y = property(__gety, __sety, doc="Y coordinate.")

    def __getz(self):
        return self.getZ()
    def __setz(self, z):
        self.setZ(z)
    z = property(__getz, __setz, doc="Z coordinate.")

    def __getxdot(self):
        return self.getXdot()
    def __setxdot(self, xdot):
        self.setXdot(xdot)
    xdot = property(__getxdot, __setxdot, doc="XDOT coordinate.")

    def __getydot(self):
        return self.getYdot()
    def __setydot(self, ydot):
        self.setYdot(ydot)
    ydot = property(__getydot, __setydot, doc="YDOT coordinate.")

    def __getzdot(self):
        return self.getZdot()
    def __setzdot(self, zdot):
        self.setZdot(zdot)
    zdot = property(__getzdot, __setzdot, doc="ZDOT coordinate.")

    def __sub__(V6C self, V6C other):
        """Return V6C that holds difference between two V6C vectors."""
        if isinstance(self, V6C) and isinstance(other, V6C):
            v6c = V6C()
            v6c.setV6(_tpm_vec.v6diff(self.getV6(), other.getV6()))
            return v6c
        else:
            raise TypeError, "Can only subtract two V6C values."

    def __add__(V6C self, V6C other):
        """Return V6C that holds the sum of two V6C vectors."""
        if isinstance(self, V6C) and isinstance(other, V6C):
            v6c = V6C()
            v6c.setV6(_tpm_vec.v6sum(self.getV6(), other.getV6()))
            return v6c
        else:
            raise TypeError, "Can only add two V6C values."

    def mod(self):
        """Return modulus, i.e., length, of position component of V6C vector."""
        return _tpm_vec.v6mod(self.getV6())

    def unit(self):
        """Return V6C with unit POS vector and scaled VEL."""
        v6c = V6C()
        v6c.setV6(_tpm_vec.v6unit(self.getV6()))
        return v6c
