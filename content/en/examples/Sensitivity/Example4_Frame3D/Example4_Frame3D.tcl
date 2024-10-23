#refer to " Quan Gu, Michele Barbato, and Joel P. Conte. Handling of Constraints in Finite Element Response 
# Sensitivity Analysis. ASCE Journal of Engineering Mechanics. 2009."


# OpenSees Example 5.1
#
# Units: kips, in, sec
# 1 kips = 4448.222 N, 1 in= 0.0254 m
#
#  change to kN k-kg, kPa, m, sec.
#
#
#
#         15______________________ 16
#         /|                     /|
#        / |                    / |
#     18/  |                   /  |
#      |----------------------/17 |                         z
#      |   |                  |   |                        /|\    / y
#      |   |                  |   |                         |    /
#      |   |10________________|___|11                       |   /
#      |  /|                  |  /|                         |  /
#      | / |                  | / |                         | /                          
#      |/  |                  |/  |                         |/
#      |13--------------------|12 |                         |-----------> x
#      |   |                  |   |
#      |   |                  |   |
#      |   |5_________________|___|6
#      |  /|                  |  /|
#      | / |                  | / |
#      |/  |                  |/  |
#      |8---------------------|7  |
#      |   |                  |   |
#      |   |                  |   |
#      |   |                  |   |
#      |   |1                 |   |2
#      |                      |   
#      |4                     |3  



model BasicBuilder -ndm 3 -ndf 6
reliability
set h 3.6576;       # Story height
set by 6.096;      # Bay width in Y-direction
set bx 6.096;      # Bay width in X-direction
 
#    tag             X             Y           Z 
node  1  [expr -$bx/2] [expr  $by/2]           0
node  2  [expr  $bx/2] [expr  $by/2]           0
node  3  [expr  $bx/2] [expr -$by/2]           0 
node  4  [expr -$bx/2] [expr -$by/2]           0 
node  5  [expr -$bx/2] [expr  $by/2]          $h 
node  6  [expr  $bx/2] [expr  $by/2]          $h 
node  7  [expr  $bx/2] [expr -$by/2]          $h 
node  8  [expr -$bx/2] [expr -$by/2]          $h 
node 10  [expr -$bx/2] [expr  $by/2] [expr 2*$h]
node 11  [expr  $bx/2] [expr  $by/2] [expr 2*$h] 
node 12  [expr  $bx/2] [expr -$by/2] [expr 2*$h] 
node 13  [expr -$bx/2] [expr -$by/2] [expr 2*$h] 
node 15  [expr -$bx/2] [expr  $by/2] [expr 3*$h] 
node 16  [expr  $bx/2] [expr  $by/2] [expr 3*$h] 
node 17  [expr  $bx/2] [expr -$by/2] [expr 3*$h] 
node 18  [expr -$bx/2] [expr -$by/2] [expr 3*$h]

# ----------------- Master nodes for rigid diaphragm ---------
#    tag X Y          Z 
node  9  0 0         $h 
node 14  0 0 [expr 2*$h]
node 19  0 0 [expr 3*$h]

# ----------------- Set base constraints --------------------
#   tag DX DY DZ RX RY RZ
fix  1   1  1  1  1  1  1
fix  2   1  1  1  1  1  1
fix  3   1  1  1  1  1  1
fix  4   1  1  1  1  1  1

# --------------- Define rigid diaphragm multi-point constraints --

#               normalDir  master     slaves
rigidDiaphragm     3          9     5  6  7  8
rigidDiaphragm     3         14    10 11 12 13
rigidDiaphragm     3         19    15 16 17 18

# -------------- Constraints for rigid diaphragm master nodes ------
#   tag DX DY DZ RX RY RZ
fix  9   0  0  1  1  1  0
fix 14   0  0  1  1  1  0
fix 19   0  0  1  1  1  0

# ------------- Define materials for nonlinear columns ------------
 
#--- --------- Core concrete (confined) -------------------
#                           tag    f'c     epsc0   f'cu       epscu
uniaxialMaterial Concrete01  1  -34473.8  -0.005   -24131.66  -0.02

# ------------ Cover concrete (unconfined) ---------------
set fc 27579.04
uniaxialMaterial Concrete01  2   -$fc -0.002   0.0 -0.006
    
# ------------- Reinforcing steel ------------------------
#                        tag   fy      E         b
uniaxialMaterial Steel01  3  248200.  2.1e8    0.02


# Column width
set d 0.4572
source RCsection.tcl
#         id  h  b  coverThick    coreID  coverID steelID nBars  area       nfCoreY nfCoreZ nfCoverY nfCoverZ
RCsection  1 $d $d   0.04           1      2        3       3   0.00051       8       8       10       10

# Concrete elastic stiffness
# set E [expr 57000.0*sqrt($fc*1000)/1000]; American unit
set E 24855585.89304;

# ---Column torsional stiffness
 set GJ 68947600000000;
# ---Linear elastic torsion for the column
 uniaxialMaterial Elastic 10 $GJ
# ---Attach torsion to the RC column section
#                 tag uniTag uniCode       secTag
section Aggregator 2    10      T    -section 1
set colSec 2

# -------------- Define column elements -----------------------

geomTransf Linear  1   1 0 0

# Number of column integration points (sections)
set np 4
# Create the nonlinear column elements
#                           tag ndI ndJ nPts   secID  transf
element dispBeamColumnWithSensitivity  1   1   5   $np  $colSec    1
element dispBeamColumnWithSensitivity  2   2   6   $np  $colSec    1
element dispBeamColumnWithSensitivity  3   3   7   $np  $colSec    1
element dispBeamColumnWithSensitivity  4   4   8   $np  $colSec    1
element dispBeamColumnWithSensitivity  5   5  10   $np  $colSec    1
element dispBeamColumnWithSensitivity  6   6  11   $np  $colSec    1
element dispBeamColumnWithSensitivity  7   7  12   $np  $colSec    1
element dispBeamColumnWithSensitivity  8   8  13   $np  $colSec    1
element dispBeamColumnWithSensitivity  9  10  15   $np  $colSec    1
element dispBeamColumnWithSensitivity  10 11  16   $np  $colSec    1
element dispBeamColumnWithSensitivity  11 12  17   $np  $colSec    1
element dispBeamColumnWithSensitivity  12 13  18   $np  $colSec    1

# ------------ Define beam elements ------------
# Define material properties for elastic beams
# Using beam depth of 24 and width of 18
# ----------------------------------------------
set Abeam 0.278709

# "Cracked" second moments of area
set Ibeamzz 0.004315;
set Ibeamyy 0.002427;
# Define elastic section for beams
#               tag  E    A      Iz       Iy     G    J
section Elastic  3  $E $Abeam $Ibeamzz $Ibeamyy $GJ   1.0  
set beamSec 3

# Geometric transformation for beams
#                tag  vecxz

geomTransf Linear 2   1 1 0
 
set np 3
# ---------- Create the beam elements----------------
#                       tag ndI ndJ nPts    secID   transf
element dispBeamColumnWithSensitivity  13  5   6   $np  $beamSec     2    Legendre
element dispBeamColumnWithSensitivity  14  6   7   $np  $beamSec     2    Legendre
element dispBeamColumnWithSensitivity  15  7   8   $np  $beamSec     2    Legendre
element dispBeamColumnWithSensitivity  16  8   5   $np  $beamSec     2    Legendre
element dispBeamColumnWithSensitivity  17 10  11   $np  $beamSec     2    Legendre
element dispBeamColumnWithSensitivity  18 11  12   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  19 12  13   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  20 13  10   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  21 15  16   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  22 16  17   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  23 17  18   $np  $beamSec     2	  Legendre
element dispBeamColumnWithSensitivity  24 18  15   $np  $beamSec     2	  Legendre
									   
# --------------- Define gravity loads ----------------			  
# Gravity load applied at each corner node				  
# 10% of column capacity

set p  74.0

# --------------- Mass lumped at master nodes ---------
set g 9.8;            # Gravitational constant
set m 30.0;

# Rotary inertia of floor about master node
set i [expr $m*($bx*$bx+$by*$by)/12.0]
# Set mass at the master nodes
#    tag MX MY MZ RX RY RZ
mass  9  $m $m  0  0  0 $i
mass 14  $m $m  0  0  0 $i
mass 19  $m $m  0  0  0 $i
# Define gravity loads
#pattern Plain 1 Constant {
pattern Plain 1 {Series -time {0.0 2.0 100000.0} -values {0.0 1.0 1.0} } {
   foreach node {5 6 7 8  10 11 12 13  15 16 17 18} {
      load $node 0.0 0.0 -$p 0.0 0.0 0.0
   }
}

#--------------------------------------------------------------------------------------------------------
#                                    CORE CONCRETE
#
# ------------------------------ R.V.#1 Core concrete epsco ---------------------------------------------
set h epsco
set gradNumber 1

parameter      $gradNumber   -element 1   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 1 $h


recorder Node -file ddmCore9epsco.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 1"
recorder Node -file ddmCore14epsco.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 1"
recorder Node -file ddmCore19epsco.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 1"

# ------------------------------ R.V.#2 Core concrete fc----------------------------------------------
set h fc
set gradNumber 2

parameter      $gradNumber   -element 1   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 1 $h


recorder Node -file ddmCore9fc.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 2"
recorder Node -file ddmCore14fc.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 2"
recorder Node -file ddmCore19fc.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 2"

# ------------------------------ R.V.#3 Core concrete epscu----------------------------------------------
set h epscu
set gradNumber 3

parameter      $gradNumber   -element 1   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 1 $h

recorder Node -file ddmCore9epscu.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 3"
recorder Node -file ddmCore14epscu.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 3"
recorder Node -file ddmCore19epscu.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 3"


# ------------------------------ R.V.#4 Core concrete fcu----------------------------------------------
set h fcu
set gradNumber 4

parameter      $gradNumber   -element 1   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 1 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 1 $h

recorder Node -file ddmCore9fcu.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 4"
recorder Node -file ddmCore14fcu.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 4"
recorder Node -file ddmCore19fcu.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 4"


#--------------------------------------------------------------------------------------------------------
#                                    COVER CONCRETE
#
# ------------------------------ R.V.#5 Cover concrete epsco----------------------------------------------
set h epsco
set gradNumber 5

parameter      $gradNumber   -element 1   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 2 $h

recorder Node -file ddmCover9epsco.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 5"
recorder Node -file ddmCover14epsco.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 5"
recorder Node -file ddmCover19epsco.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 5"

# ------------------------------ R.V.#6 Cover concrete fc----------------------------------------------
set h fc
set gradNumber 6

parameter      $gradNumber   -element 1   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 2 $h

recorder Node -file ddmCover9fc.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 6"
recorder Node -file ddmCover14fc.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 6"
recorder Node -file ddmCover19fc.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 6"

# ------------------------------ R.V.#7 Cover concrete epscu----------------------------------------------
set h epscu
set gradNumber 7


parameter      $gradNumber   -element 1   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 2 $h

recorder Node -file ddmCover9epscu.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 7"
recorder Node -file ddmCover14epscu.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 7"
recorder Node -file ddmCover19epscu.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 7"

# ------------------------------ R.V.#8 Cover concrete fcu----------------------------------------------
set h fcu
set gradNumber 8

parameter      $gradNumber   -element 1   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 2 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 2 $h

recorder Node -file ddmCover9fcu.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 8"
recorder Node -file ddmCover14fcu.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 8"
recorder Node -file ddmCover19fcu.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 8"

#----------------------------------------------------------------------------------------------
#                                  STEEL SENSITIVITY
#
# ------------------------------ R.V.#9 steel fy ----------------------------------------------
set h sigmaY
set gradNumber 9


parameter      $gradNumber   -element 1   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 3 $h

recorder Node -file ddmSteel9fy.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 9"
recorder Node -file ddmSteel14fy.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 9"
recorder Node -file ddmSteel19fy.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 9"

# ------------------------------ R.V.#10 steel E ----------------------------------------------
set h E
set gradNumber 10

parameter      $gradNumber   -element 1   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 3 $h

recorder Node -file ddmSteel9E.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 10"
recorder Node -file ddmSteel14E.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 10"
recorder Node -file ddmSteel19E.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 10"

# ------------------------------ R.V.#11 steel b ----------------------------------------------
set h b
set gradNumber 11

parameter      $gradNumber   -element 1   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 2   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 3   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 4   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 5   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 6   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 7   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 8   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 9   -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 10  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 11  -section 2 -section  -material 3 $h
addToParameter $gradNumber   -element 12  -section 2 -section  -material 3 $h

recorder Node -file ddmSteel9b.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 11"
recorder Node -file ddmSteel14b.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 11"
recorder Node -file ddmSteel19b.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 11"

# ------------------------------ R.V.#12 column GJ ----------------------------------------------
set h E
set gradNumber 12

parameter      $gradNumber   -element 1   -section 2   $h
addToParameter $gradNumber   -element 2   -section 2   $h
addToParameter $gradNumber   -element 3   -section 2   $h
addToParameter $gradNumber   -element 4   -section 2   $h
addToParameter $gradNumber   -element 5   -section 2   $h
addToParameter $gradNumber   -element 6   -section 2   $h
addToParameter $gradNumber   -element 7   -section 2   $h
addToParameter $gradNumber   -element 8   -section 2   $h
addToParameter $gradNumber   -element 9   -section 2   $h
addToParameter $gradNumber   -element 10  -section 2   $h
addToParameter $gradNumber   -element 11  -section 2   $h
addToParameter $gradNumber   -element 12  -section 2   $h


recorder Node -file ddm9GJ.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 12"
recorder Node -file ddm14GJ.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 12"
recorder Node -file ddm19GJ.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 12"


#-----------------------------------------------------------------------------------------
#        
#                            ELASTIC BEAM
#
#-----------------------------------------------------------------------------------------

# ------------------------------ R.V.#13 Beam E ----------------------------------------------
set h E
set gradNumber 13

parameter      $gradNumber  -element 13  -section 3  $h
addToParameter $gradNumber  -element 14  -section 3  $h
addToParameter $gradNumber  -element 15  -section 3  $h
addToParameter $gradNumber  -element 16  -section 3  $h
addToParameter $gradNumber  -element 17  -section 3  $h
addToParameter $gradNumber  -element 18  -section 3  $h
addToParameter $gradNumber  -element 19  -section 3  $h
addToParameter $gradNumber  -element 20  -section 3  $h
addToParameter $gradNumber  -element 21  -section 3  $h
addToParameter $gradNumber  -element 22  -section 3  $h
addToParameter $gradNumber  -element 23  -section 3  $h
addToParameter $gradNumber  -element 24  -section 3  $h


recorder Node -file ddm9BeamE.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 13"
recorder Node -file ddm14BeamE.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 13"
recorder Node -file ddm19BeamE.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 13"


# ------------------------------ R.V.#14 Beam G ----------------------------------------------
set h G
set gradNumber 14

parameter      $gradNumber  -element 13  -section 3  $h
addToParameter $gradNumber  -element 14  -section 3  $h
addToParameter $gradNumber  -element 15  -section 3  $h
addToParameter $gradNumber  -element 16  -section 3  $h
addToParameter $gradNumber  -element 17  -section 3  $h
addToParameter $gradNumber  -element 18  -section 3  $h
addToParameter $gradNumber  -element 19  -section 3  $h
addToParameter $gradNumber  -element 20  -section 3  $h
addToParameter $gradNumber  -element 21  -section 3  $h
addToParameter $gradNumber  -element 22  -section 3  $h
addToParameter $gradNumber  -element 23  -section 3  $h
addToParameter $gradNumber  -element 24  -section 3  $h

recorder Node -file ddm9BeamG.out  -time -node  9 -dof 1 2 3 4 5 6 "sensitivity 14"
recorder Node -file ddm14BeamG.out -time -node 14 -dof 1 2 3 4 5 6 "sensitivity 14"
recorder Node -file ddm19BeamG.out -time -node 19 -dof 1 2 3 4 5 6 "sensitivity 14"

# ---------------------- Define earthquake excitation ------------
# Set up the acceleration records for Tabas fault normal and fault parallel
set tabasFN "Path -filePath tabasFN.txt -dt 0.02 -factor $g"
set tabasFP "Path -filePath tabasFP.txt -dt 0.02 -factor $g"
 
#                         tag dir         accel series args
pattern UniformExcitation  2   1  -accel      $tabasFN
pattern UniformExcitation  3   2  -accel      $tabasFP

recorder Node -file node.out -time -node 9 14 19 -dof 1 2 3 4 5 6 -precision 16 disp

# ------------------------- add static analysis ------------------------
constraints Transformation
#                tol   maxIter  printFlag
test EnergyIncr 1.0e-16   20         2
integrator LoadControl 1 1 1 1
algorithm Newton
system BandGeneral
numberer RCM

sensitivityIntegrator -static
sensitivityAlgorithm -computeAtEachStep

analysis Static 

set startT [clock seconds]
analyze 3
puts "soil gravity nonlinear analysis completed ..."

# ------------------------- add analysis ------------------------
wipeAnalysis

#                tol   maxIter  printFlag
test EnergyIncr 1.0e-16   20         2
algorithm Newton
system BandGeneral
constraints Transformation
#integrator Newmark   0.5  0.25
numberer RCM

integrator NewmarkWithSensitivity  0.55 0.275625  0. 0. 0. 0.
# (0.55+0.5)^2/4=0.275625
sensitivityIntegrator -definedAbove
sensitivityAlgorithm -computeAtEachStep


analysis Transient


analyze   2500   0.01

set endT [clock seconds]
puts "Execution time: [expr $endT-$startT] seconds."
