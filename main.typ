#import "template.typ": *
#import "typst-boxes.typ": * //https://github.com/lkoehl/typst-boxes?tab=readme-ov-file
#let emph_blue(testo) = emph(text(fill: blue, testo))

#let long-symbol(sym, factor) = {
  assert(type(sym) == "symbol", message: "Input needs to be a symbol")
  assert(type(factor) == "integer" or type(factor) == "float", message: "Scale factor must be a number")
  assert(factor >= 1, message: "Scale factor must be >= 1")
  
  factor = 5*factor - 4
  let body = [#sym]
  style(styles => {
    let (body-w,body-h) = measure(body,styles).values()
    align(left)[
      #box(width: body-w*2/5,height: body-h,clip: true)[
        #align(left)[
          #body
        ]
      ]
      #h(0cm)
      #box(height: body-h, width: body-w*1/5*factor)[
        #scale(x: factor*100%,origin:left)[
          #box(height: body-h, width: body-w*1/5,clip:true)[
            #align(center)[
              #body
            ]
          ]
        ]
      ]
      #h(0cm)
      #box(width: body-w*2/5,clip: true)[
        #align(right)[
          #body
        ]
      ]
    ]
  })
}

// vec and math have all squared lines
#set math.vec(delim: "[")
#set math.mat(delim: "[")

/*#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")*/

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "3D Vision and Extended Reality",
  authors: (
    (name: "Andrea Favero", email: "andrea.favero96@gmail.com", affiliation: "Università degli Studi di Padova"),
    (name: "Leonardo Monchieri", email: "leonardo.monchieri@studenti.unipd.it", affiliation: "Università degli Studi di Padova"),
  ),
)

//https://www.reddit.com/r/typst/comments/12irwkj/how_can_i_create_a_colored_box_similar_to/
#let my_block(back_color, frame_color, title_color, content_color, title, content) = {
  block(radius: 4pt, stroke: back_color + 2pt)[
    #block(width: 100%,fill: back_color, inset: (x: 20pt, y: 5pt), below: 0pt)[#text(title_color)[#title]]
    #block(width: 100%, fill: frame_color, inset: (x: 20pt, y: 10pt))[#text(content_color)[#content]]
  ]
}

= Perspective and cameras
Every image is created by the interaction of light, real objects and an optic device.

A camera acquires images from the real world following a precise pattern. 
A source of light emits rays that reach an object which, reflects them in many directions; a lens acquires these rays and focuses them on an array/plate of sensors. The output of the sensors is passed to some analogue electronics components that transform the light taken in input by the camera to a charge/tension and convert it into numerical digital values. These values are then stored into a memory after some processing.
#figure(
  image("img/camera-pipeline.png", width: 70%),
  caption: [
    The camera's pipeline.
  ],
)

== The simplified pinhole model
Rays travel from an illumination source to an object that reflects them, afterwards they are captured by an acquisition device (e.g.: our eye, an analog or a digital camera) that fucuses them on a photo responsive element (e.g.: the retina, a film, a matrix of sensors).

The #emph(text(blue)[pinhole model]) is a mathematically consistent model that is at the basis of computer vision and computer graphics.

The idea is that the acquisition element (e.g.: pupil, lens, ...) can be approximated to a #emph(text(blue)[pinhole]) or #emph(text(blue)[center of projection]) (COP) $bold(C)$. The rays of light pass through the pinhole and are projected onto the #emph(text(blue)[image plane]) (also called the projection plane). The pinhole is so small that we assume that only a single ray of light for a specific direction goes into the hole.

The #emph(text(blue)[optical axis]) is the axis that passes through the pinhole and is orthogonal to the image plane. The #emph(text(blue)[focal length]) $f$ is the distance from the pinhole to the image plane measured on the optical axis. //It determines wheather a point is in focus or not, if it isn't in focus you notice that instead of having a single point you have a circle.

#figure(
  image("img/pinhole.png", width: 70%),
  caption: [
    The pinhole camera model (from Fusiello's book).
  ],
)

Given a point $bold(tilde(M))$ in our $3$D world, it is projected through the pinhole $bold(C)$ onto the image plane. The intersection between the plane and the ray identifies the point $bold(tilde(m))$ in the plane. Capital bold letters are used for points in the $3$D space and lower case bold letters are used for points in the $2$D image plane./*#footnote[The letter $bold(m)$ is borrowed from physics and stays for "mass".]*/

To characterize the model from a geometric point of view, some references are required: we start with a $3$D reference system $bold(X),bold(Y), bold(Z)$ whose origin  is located at the pinhole and a $2$D reference system $bold(u), bold(v)$ for the image plane, centered at the intersection between the image plane and the optical axis. The $bold(Z)$'s direction is towards the $3$D object (so it "points outside the camera"). This direction is just a convention and in some books you can find the opposite situation with $bold(Z)$ that points towards the image plane.
#figure(
  image("img/simplified-pinhole-model.png", width: 70%),
  caption: [
    The pinhole camera model with reference systems from Fusiello's book. The orange dotted line is the optical axis. $cal(Q)$ is the image plane, $cal(F)$ is called the #emph(text(blue)[focal plane]) and it is a plane parallel to $cal(Q)$ that contains the pinhole $bold(C)$.
  ],
)


In real life, where we use digital cameras, an image is a matrix of discrete elements named _pixels_. Pixels information is obtained from a grid of CMOS sensors that measure the intensity of the light that hits them. The bigger is the grid, the bigger is the resolution of the camera and so of the image. The CMOS grid that we have in the real world has integer coordinates while, the pinhole camera model that exists in the ideal world has real coordinates. The coordinates of a point in a digital image are somehow quantized and can only be multiples of the sizes of the sensors.

When we refer to a digital picture we speak in terms of #emph(text(blue)[pixels]), while when we refer to the pinhole model we speak in terms of #emph(text(blue)[image points]).

== Projective equations
For the sake of simplicity we consider two cases, one that involves the $bold(X)$ and $bold(Z)$  axes, and one that involves the $bold(Y)$ and $bold(Z)$ axes.

#figure(
    grid(
        columns: (auto, auto),
        rows:    (auto, auto),
        gutter: 1em,
        [ #image("img/XZ.png", width: 90%) ],
        [ #image("img/YZ.png", width: 90%) ],
    ),
    //caption: []
) <projective-equations>

In both cases there is a ray that is projected from the $3$D point $bold(tilde(M)) = vec(x, y, z)$ onto the image plane at the point $bold(tilde(m)) = vec(u, v)$.

The triangle $overline(bold(C tilde(M))), x, z$ is similar to the triangle $overline(bold(C tilde(m))), u, f$ in the first case and to the triangle $overline(bold(C tilde(m))), v, f$ in the second case.

From this fact it is clear that 
$
f/z = (-u)/x = (-v)/y
$

where $u$ and $v$ are multiplied by $-1$ because they are located in the "negative side" of the $bold(u)$ and $bold(v)$ axes respectively, and we want them to be positive quantities.

From the equation above, the equations for the image points $u$ and $v$ can be derived.

$
f/z = (-u)/x => (-f)/z = u/x => u = -f x/z
$

$
f/z = (-v)/y => (-f)/z = v/y => v = -f y/z
$

and so the projection of a $3$D point onto a point on the image plain is given by 
$
cases(
  u = (-f)/z x,
  v = (-f)/z y
)
$

The fact that $u$ and $v$ are negative means that the object projected on the image plane is flipped both horizontaly and vertically.
#figure(
  image("img/camera-obscura.png", width: 80%),
  caption: [
    The image is flipped both horizontaly and vertically.
  ],
)

The derived equations tell us that the farther the point $bold(tilde(M))$ is, the smaller its projection will be on the image plane because, to find $u$ and $v$ we divide by $z$ which is the distance of $bold(tilde(M))$ from the center of projection $bold(C)$. The division by $z$ accounts for the effect of _foreshortening_ or #emph(text(blue)[scorcio]).

Example: the spires of the Duomo di Milano have all the same height but, if we look at the ones in @duomo-spires, we notice that those which are far away appear smaller. This is the principle of #emph(text(blue)[perspective]): the farther the objects are from the camera, the smaller they appear.
#figure(
  image("img/duomo.png", width: 30%),
  caption: [
    Duomo di Milano's spires.
  ],
)<duomo-spires>

== Problems due to projection 
It is impossible to measure the $3$D world from a _single_ image because the projection of a point from $3$D to $2$D is subject to a loss of information.

Projection means loss of:
- distances
- angles/vanishing points
- sizes

=== Loss of distances
Distances are lost due to projection. For example, if we have two coins of different size that lie on the same plane, we can notice they aren't the same.
#figure(
  image("img/coins-same-plane.png", width: 40%),
  caption: [
    Two coins of different size.
  ],
)

If you take the coins and place them properly in the $3$D space, their projection on the $2$D space will make them appear as they have the same size.
#figure(
  image("img/coins-lost-distance.png", width: 40%),
  caption: [
    The same coins appear, as they have the same size.
  ],
)
There are also positions of the two coins whose projection makes the smaller one appear as the biggest.

=== Loss of angles
Example: rail tracks are parallel but, in @binaries, they appear as converging to a point at the infinite.
#figure(
  image("img/rail-tracks-convergence.png", width: 70%),
  caption: [
    Loss of the angles.
  ],
)<binaries>
Following the equations that we have obtained from the pinhole model, we can try to compute the coordinate in the $bold(u)$ axis of the $2$D points in @binaries (we can see the picture as the image plane whose projected objects are not flipped, so $f$ is not multiplied by $-1$ in this case).

For the two points at the extrema of the yellow line, we have that 
$
u_0 = f x_0/z_0 #h(1cm) u_0+delta u_0 = f (x_0 + Delta)/z_0
$

while, for the two points at the extrema of the green line we have that
$
u_1 = f x_1/z_1 #h(1cm) u_1+delta u_1= f (x_1 + Delta)/z_1
$

The rails are parallel and so the distance between them is the same quantity $Delta$. The points on the yellow line are at distance $z_0$ from the center of projection, while the one on the green line, which are far away, are at distance $z_1$ where $z_0 < z_1$.

$
delta u_0 = f (x_0 + Delta)/z_0 - u_0 = f (x_0 + Delta)/z_0 - f x_0/z_0 = f Delta/z_0
$
$
delta u_1 = f (x_1 + Delta)/z_1 - u_1 = f (x_1 + Delta)/z_1 - f x_1/z_1 = f Delta/z_1
$

$z_0 < z_1 => delta u_1 < delta u_0$ which means that the projected rails are not parallel,  otherwise we would have that $delta u_0 = delta u_1$.

=== Loss of sizes
As shown by the @loss-of-sizes, the projection is also responsible for the size loss of the objects.
#figure(
    grid(
        columns: (auto, auto, auto),
        rows:    (auto, auto, auto),
        gutter: 0.2em,
        [ #image("img/pisa.png", width: 90%) ],
        [ #image("img/people-sizes.png", width: 85%) ],
        [ #image("img/pinhole-size-loss.png", width: 100%) ]
    ),
    caption: [Loss of sizes.]
) <loss-of-sizes>

== Modify the simple pinhole model
Since the pinhole model is a mathematical model, it is possible to move the image plane between the center of projection and the world without loss of generality. In this way, the object's projection will not be flipped anymore.
#figure(
    grid(
        columns: (auto, auto),
        rows:    (auto, auto),
        gutter: 0.1em,
        [ #image("img/pinhole-centered.png", width: 90%) ],
        [ #image("img/image-plane-centered.png", width: 100%) ]
    ),
    caption: [On the left: the version of the simple pinhole model with the image plane at the left of the COP. On the right: the version of the simple pinhole model with the image plane moved between the COP and the world.]
) <simple-pinhole-model-different-planes>

== Perspective projection of a plane and the projective space
A #emph(text(blue)[perspective projection]) is the mapping of $3$D points $bold(M)$ into $2$D points $bold(m)$ of the plane $cal(Q)$,  by intersecting the line passing from $bold(M)$ and $bold(C)$ with $cal(Q)$.
The points $bold(M)$ are located on a ground plane $cal(G)$ that is orthogonal to $cal(Q)$.
#figure(
  image("img/ground-plane-projection.png", width: 50%),
  caption: [
    Perspective projection.
  ],
)<perspective-projection>

As @perspective-projection suggest, the line $f$, determined by the intersection of the plane $cal(G)$ with the plane parallel to $cal(Q)$ and containing $bold(C)$ does not project onto $cal(Q)$ and, the line $h$, intersection of $cal(Q)$ with the plane parallel to $cal(G)$ and passing through $bold(C)$ is
not the projection of any line on the plane $cal(G)$.



If we look at the perspective projection from the "side", we obtain a 2D representation like the one in @perspective-projection-2D where, the vertical line corresponds to $cal(Q)$, and the horizontal line corresponds to $cal(G)$. 
#figure(
  image("img/perspective.projection-2D.png", width: 80%),
  caption: [
    Perspective projection in $2$D.
  ],
)<perspective-projection-2D>

If $bold(M)$ is moved towards $+ infinity$  ($bold(M) -> + infinity$) it is possible to notice that the point projected onto $cal(Q)$ converges to $h$ ($bold(m) → h$). Instead, if $bold(M) -> f$ then $bold(m) -> + infinity$.
#figure(
  image("img/perspective.projection-2D-to-infinity.png", width: 80%),
  caption: [
    Perspective projection in $2$D with points $bold(M) -> infinity$ and $bold(M) -> f$.
  ],
)<projection-to-infinity>

So, if we want our model to work correctly, we should add to the Euclidean planes, “ideal” lines lying at the infinite.

These new planes are called #emph(text(blue)[projective planes]). The projective plane for the @projection-to-infinity is
$
PP^2 eq.def RR^2 union {l_infinity} "where" l_infinity "is the line at the infinite"
$
This concept is generalizable for $PP^n$ (e.g.: $PP^3 eq.def RR^3 union {p_infinity} "where" p_infinity "is a plane at the infinite"$).

In the Cartesian plane:
- Given two different points, there exists only one line that contains them both;
- There exists only one line with a given direction and containing a given point $bold(P)$;
- Two different lines have either a common point (incident) *or* the same direction (parallel).
#figure(
  image("img/lines-parallel-incident.png", width: 60%),
  caption: [
    On the left: two parallel lines. On the right: two incident lines..
  ],
)

Let's consider two incident lines on a point $bold(P)$. If $bold(P)$ is drawn at the infinite the two lines become paralel. 
#figure(
    grid(
        columns: (auto, auto),
        rows:    (auto, auto),
        gutter: 0.5em,
        [ #image("img/incident-lines-at-P.png", width: 100%) ],
        [ #image("img/parallel-lines-P-at-infinite.png", width: 100%) ]
    ),
    caption: [On the left: Two lines incident on a point $P$. On the right: The two lines becomes parallel when $P$ is drawn at infinite. ]
) <glacier>

In a projective space:
+ Given two points, there exists only one line that contains them both.
+ Two different lines *have* only *one common point*
These two rules identify a line point dualism and so, in projective spaces even parallel lines share a common point (which is at infinite).

To insert projective spaces in our model we need to model them analitically and we do so using homogeneus coordinates.

== Homogeneus coordinates
If we are in the Cartesian plane $RR^2$ (or in the Euclidean space $RR^3$, ...), lines can be described by their standard equation form.

Two lines in $RR^2$ for example, are described by:
$
a x + b y + c &= 0 \

a' x + b' y + c' &= 0
$
/*
These equations can be transformed into their slope-intercept form to explicit the $y$ and obtain the slope as a coefficient of $x$:
$
y &= -a/b x + -c/b \

y &= -a'/b' x + -c'/b'
$

Defining the slopes as $r = -a/b, r' = -a'/b'$ and the intercepts as $q = -c/b, q' = -c'/b'$, the equations become:
$
y &= r x + q \

y &= r' x + q'
$
*/
To see if the two lines intersect, we can put them in a linear system. If the system has one unique solution the lines intersect, if it has infinite solutions the lines overlap, otherwise, if it has no solution at all, the lines are parallel.

The system
$
cases(
a x + b y + c &= 0 \

a' x + b' y + c' &= 0
)

#h(0.5cm)
<==>
#h(0.5cm)

cases(
a x + b y &= -c \

a' x + b' y &= -c'
)
$

can be rewritten as 
$ 
mat(a, b;   a',b';) vec(x,y) = vec(-c,-c')
$

Defining $A eq.def mat(a, b;   a',b';)$, it corresponds to:
$ 
A vec(x,y) = vec(-c,-c')
$

#slantedColorbox(
  title: [Cramer's theorem],
  color: "green",
  radius: 2pt,
  width: auto
)[
Given a system of linear equations $A bold(x) = bold(b)$ (where $A$ is an $n times n$ matrix), if $A$ is invertible ($det(A) eq.not 0$), then the system has a unique solution and $forall x_i $ with  $ i = 1,..., n$
$
 x_i =  1/det(A) Delta_i
$
where $Delta_i$ is the determinant of the matrix that has the same columns of $A$ except for the $i"-th"$ one that, is equal to $bold(b)$.
]

If the two lines intersect, the system has a unique solution $=>$ the matrix $A$ is invertible ($det(A) eq.not 0$) $=>$ Cramer can be used to solve the system.

$
 x &= 1/det(A) Delta_1 = det(mat(-c,b; -c',b'))/det(mat(a,b; a',b')) = (b c' -b' c)/(a b' -a' b) eq.def u/w \

 y &= 1/det(A) Delta_2 = det(mat(a, -c; a', -c'))/det(mat(a,b; a',b')) = (a' c - a c')/(a b' -a' b) eq.def v/w
$

- If $det(A) = w eq.not 0$ then $A$ is invertible and so the system has just one solution which is the point of intersection of the two lines $(x = u slash w, #h(0.1cm) y = v slash w)$, and it belongs to $RR^2$;
- if $det(A) = w = 0$ the matrix is not invertible, and so the system doesn't have a unique solution:
 - it could have infinite solutions ($u = v = 0$), which means that the lines overlap;
 - it could not have any solution at all in $RR^2$ ($u eq.not 0$ or $v eq.not 0)$, which means that the lines are parallel/* (and linearly dependent)*/. In this case, the intersection point *lies at the infinite* and its coordinates can be expressed in the projective space $PP^2$ with a triple $vec(u, v, w)$ where $w = 0$.

The representation $ bold(m) = vec(u, v,w) $ where $bold(m) in PP^2$ is called #emph(text(blue)[homogeneous coordinate]). 

If $gamma = 0$ then $bold(m)$ lies at the infinite and is called an #emph(text(blue)[ideal point]).

Points in cartesian coordinates are represented in bold with a tilde $tilde$ like $bold(tilde(m))$, while points in homogeneous coordinates are just in bold like $bold(m)$.
 
== Points in homogeneous coordinates and their relation with the Cartesian plane

As consequence of the defintion of homogeneous coordinates, we can represent points into the #emph(text(blue)[projective space]) $PP^2$ as a triplet: 
$
vec(u, v, w) != vec(0, 0, 0)
$ 
The triplet $vec(0, 0, 0)$ corresponds to two lines that are coincident and so, it represents an infinite set of points and not a single point, therefore it doesn't belong to $PP^2$.

It is possible to convert homogeneous coordinates into Cartesian coordinates due to the fact that:
$
x=u/w #h(1cm) y=v/w
$

and so:
$
 PP^2 in.rev vec(u, v, w) 
 attach(limits(#long-symbol(sym.arrow.r.filled,8)), t: w eq.not 0) 
 vec(u/w, v/w) in RR^2
$

where $w eq.not 0$ because we can find a correspondent point in $RR^2$ only for real points, not the ones that lie at the infinite.

It is possible to do the inverse conversion from Cartesian coordinates to homogeneous
coordinates and, it is even more simple:
$
 PP^2 in.rev vec(x, y, 1)
 attach(limits(#long-symbol(sym.arrow.l.filled,8)), t: "")  
 vec(x, y) in RR^2
$

It is interesting to notice that in projective spaces, the multiplication by a scalar constant $lambda eq.not 0$ in $PP^2$ doesn't change the corresponding point in $RR^2$.
All the homogeneous coordinate vectors are defined with respect to a scale factor $lambda eq.not 0$. So $bold(m)$ and $lambda bold(m)$ are the same point in $RR^2$

$forall lambda !=0 :$
$
 lambda vec(u, v, w) = vec(lambda u, lambda v, lambda w) in PP^2 
 attach(limits(#long-symbol(sym.arrow.r.filled,8)), t: "")  
 vec((lambda u) / (lambda w), (lambda v) / (lambda w)) = vec(u/w, v/w) in RR^2
$

All these correspondences are generalizable to $PP^n$ and $RR^n$.

== Lines in homogeneous coordinates

Similar to points, in $PP^2$ we can represent lines just using a vector of three real numbers. Like in $RR^2$ where a line ($a x + b y + c = 0 $) has three real coefficients, we can represent a line in $PP^2$ with the equation:

$ a u/w + b v/w + c = 0 $
multiplying by $w$ we obtain:
$ a u + b v + c w = 0 $
using  vector notation, it becomes:
$
mat(a, b, c) vec(u, v, w) = 0
$


Posing $ bold(italic(l))^T eq.def mat(a,b,c)$ and $ bold(p) eq.def vec(u, v, w)$ the equation can be rewritten as:
$
bold(italic(l))^T bold(p) = 0
$

Recap with a visual scheme:

$
 a u/w + b v/w + c &= 0 "(in " PP^2 ")" #h(1cm)  attach(limits(#long-symbol(sym.arrow.l.r.double,3)), t: "") #h(1cm) a x + b y + c =& 0 "(in " RR^2 ")" \
 
 arrow.t.b.double \
 
 a u + b v + c w &= 0 \
 
 arrow.t.b.double \
 
 mat(a, b, c) vec(u, v, w) &= 0 \

 arrow.t.b.double \

 bold(italic(l))^T bold(p)&= 0
$

== Transformations

/*
This kind of transformations are used to convert one convex quadrilateral into another.\
In case of images we use them to change prospective, in particular we will use them to rewrite the projective equation.\
*/
#figure(
  image("img/2D-planar-transforms-set.png", width:50%),
  caption: [
   Transforms on $PP^2$ from Szeliski's book
  ],
)
=== Projective transformations (projectivities)
Projectivities are _linear functions_ that map points in $PP^n$ to points in $PP^n$. They are defined by an _invertible_ matrix $H$ of order $(n+1) times  (n+1)$ called #emph(text(blue)[homography]).
$
 f: PP^n &-> PP^n \
       bold(m) &|-> H bold(m)
$

- the fact that $H$ is invertible implies that if the points $bold(m)$ taken in input lies on the same plane, then also the points $H bold(m)$ outputted by $f$ lies on the same plane too (collinearity);
- projectivities form a group $f in cal(G)_P$;
- $H$ and $lambda H (lambda in RR, lambda eq.not 0)$ are the same (similarity).

/*Point 3. implies that this kind of transformation in a *//*If $n=2$ then $H$ is a $3 times 3$ matrix that has $8$ _degrees of freedom_, *since we can use $lambda$ as scale factor to maintain one of the parameters fixed (to 1)*.
$
H = mat(
  A, bold(b);
  bold(h)^T, 1;
)
$
$A$ il called _transformation matrix_, $bold(b)$ is the _translation vector_.*/

=== Affine transformations
An affine transformation is a projectivity that maps real points into real points and, ideal points into ideal points (because of the last row $mat(bold(0)^T, 1)$ of $H$ that, when multiplied by $bold(m)$, makes $1$  the last element of the resulting vector $H bold(m)$ if $1$ is the last element of $bold(m)$, $0$ if $0$ is the last element of $bold(m)$).
$
H = mat(
  A_(n times n), bold(b);
  bold(0)^T,  1;
)
$
An affine transform preserves the _parallelism_ but doesn't preserve the angles.

In $PP^2$, $H$ is $3 times 3$ and has $6$ degrees of freedom because the last row is fixed to $mat(0,0,1)$.
$
H = mat(
  a_(1,1), a_(1,2), b_1;
  a_(2,1), a_(2,2), b_2;
  0, 0, 1;
)
$

=== Similarity
A similarity is a subclass of affinities that use an orthogonal rotation matrix $R$ with a scale factor $s$ and a traslation vector $bold(t)$. /*preserve the absolute conic $cal(C)$.*/
$
H = mat(
  s R_(n times n), bold(t);
  bold(0)^T, 1;
) 
$

A similarity preserves the angles and, being an affine transform, preserves also the parallelism.

In the Euclidean space $RR^n$, similarity operates as
$
  bold(tilde(m)) -> s R_(n times n) bold(tilde(m)) + bold(t)
$

In $RR^3$ for example:
$
 H bold(m) 
 = 
 mat(s R_(3 times 3), bold(t); bold(0)^T, 1)
 vec(x, y, z, 1)
 =
 mat(s R_(3 times 3) vec(x,y,z) + bold(t); 1)

 => s R_(3 times 3) vec(x, y, z) + bold(t)
 = s R_(3 times 3) tilde(m) + bold(t)
 
$


In $PP^2$, $H$ has $4$ degrees of freedom. //since $R_(2 times 2)$ represent an angle (so a single parameter), $bold(t)_(2 times 1)$ is a vector and finally $s$ which is a single value.


=== Euclidean transformations
If in a similarity $s = 1$, the transform is called _rigid_ transformation or _Euclidian_ transformation.
$
H = mat(
  R_(n times n), t;
  0^T, 1;
)
$

A Euclidean transformation, preserves the distances, the lengths and, just like similarity, also the angles and the parallelism.

$s$ is fixed, so in $PP^2$,  $H$ has $3$ degrees of freedom.

/*
#my_block(rgb(198, 243, 149), rgb(198, 243, 249),  rgb(0,138,235), black, [Absolute conic $cal(C)$],
[
On the infinity plane, there is a special geometric locus (set of points) named *absolute conic*, which can be defined in every space $PP^n$ as:
$
cal(C) = { bold(mono(x)) in PP^n bar.v x_1^2+x_2^2+...+x_n^2 and x_(n+1) = 0}
$
It represents the set of _all possible ideal image points_ that could be mapped to a specific set of _ideal points_ in *3D* space through the process of projection.
])
*/
=== Tranformations in $PP^2$, recap:
#table(
  columns: (auto, auto, auto, 1fr,  auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [*Transformation*], [*D.o.f.*], [*Matrix*], [*Distortion*], [*Preserves*]
  ),
  //First row
  [Projectivity],
  $8$,
  $mat(H_(1,1), H_(1,2), H_(1,3); H_(2,1), H_(2,2), H_(2,3); H_(3,1), H_(3,2), H_(3,3))$,
  image("img/projectivity.png"),
  [Collinearity],
  
  //Second row
  [Affinity],
  $6$,
  $mat(H_(1,1), H_(1,2), H_(1,3); H_(2,1), H_(2,2), H_(2,3); 0, 0, 1)$,
  image("img/affinity.png"),
  [Parallelism],

  //Third row
  [Similarity],
  $4$,
  $mat(s R_(n times n), bold(t); bold(0)^T, 1)$,
  image("img/similarity.png"),
  [Angles],

  //Fourth row
  [Euclidean],
  $3$,
  $mat(R_(n times n), bold(t); bold(0)^T, 1)$,
  image("img/euclidean.png"),
  [Distances \ and \ lengths],
)

== Camera matrix
If we look at the projective equations in cartesian coordinates that we have derived before:
$
cases(
  u = (-f)/z x,
  v = (-f)/z y
)
$
we can see that they are _not linear_ because $x$ and $y$ are multiplied by $1 slash z$.

/*The projective equations in cartesian coordinates can be rewritten in vectorial form: 
$
vec(u,v) = -f/z vec(x,y) <==> z vec(u,v) = -f vec(x,y)
$
*/
The equations, can be rewritten _linearly_ in matrix form, using homogeneous coordinates:// for the representation of the cartesian points $tilde(m) = vec(u,v)$ and $tilde(M) = vec(x, y,z)$.
/*$
cases(
 z u = -f x,
 z v = -f y,
 z 1 = z
)
#h(2.5cm) // little trick to align the system with the equation underneath
$
$
&arrow.t.b.double \

z vec(u, v, 1) &= vec(-f x, -f y, z) \

&arrow.t.b.double \

z vec(u, v, 1) &= 
mat(
  -f, 0, 0, 0;
  0, -f, 0 ,0;
  0, 0, 1, 0;
) vec(x, y ,z , 1)
$*/

$
cases(
 z u = -f x,
 z v = -f y,
 z 1 = z
)
#h(0.5cm) <==> #h(0.5cm)
z vec(u, v, 1) &= vec(-f x, -f y, z)  \
&= 
mat(
  -f, 0, 0, 0;
  0, -f, 0 ,0;
  0, 0, 1, 0;
) vec(x, y ,z , 1)
$

If we define $bold(m) eq.def vec(u, v, 1), bold(M) eq.def vec(x, y ,z , 1), P eq.def mat(-f, 0, 0, 0; 0, -f, 0 ,0; 0, 0, 1, 0;)$ we can rewrite the equation as:
$
z #h(1mm) bold(m) &= 
mat(
  -f, 0, 0, 0;
  0, -f, 0 ,0;
  0, 0, 1, 0;
) bold(M) \

&arrow.t.b.double \

z #h(1mm) bold(m) &= P bold(M)
$

Since homogeneous coordinates are not affected by the rescaling ($forall z eq.not 0: bold(m) = z bold(m)$), $z  bold(m)$ and $bold(m)$ represent the same point. So we write
$ bold(m) tilde.eq P bold(M) $
to denote that $bold(m)$ and $P bold(M)$ are equal with _respect to a scale factor_ $z$.

Notice that, even if the rescaling factor $z$ is omitted in homogeneous coordinates, it plays
a crucial role when referring to real measurements. The parameter $z$ can be
related to the distance of the points with respect to the reference system of
the camera, and therefore, it links the size of real objects to the size of their
projection in the image.

$P$ is called #emph(text(blue)[projection matrix]) (or #emph(text(blue)[camera matrix])) and defines the projection
rules mapping $3$D points into image points.

Using $P$ and the two points in homogeneous coordinates we were able to transform a nonlinear operation into a linear one.

The simplest camera matrix $P$ that we can obtain is the one were the focal length $f = -1$.// and the world coordinates have origin at the center of projection $C$.
$ P = mat(1, 0, 0, 0; 0, 1, 0,0; 0, 0, 1, 0;) = mat(I_3, &\| underline(bold(0)) ) $
It is an #emph(text(blue)[ideal camera matrix]) which is never met in general. Just by zooming, $f$ changes. By the way, any camera matrix can be brought into this form.// and generally, this is done when different cameras have to be combined (e.g.: 3D decompression systems). In order to do this, the general pinhole camera model has to be introduced.

/*#figure(
  image("img/ideal_camera_matrix.png", width: 30%),
  caption: [
    Projective plane using the _ideal camera matrix_($f=-1$)
  ],
)*/

== General pinhole model
In our world, there are a lot of _non idealities_ that affect the ideal camera matrix. When we are using our camera to take a picture of a subject, we change its focal lengths $f$ just by zooming to put the target into focus. /*Moreover, the focal length is affected by the size of the sensors, which, must be taken into account also for the reference system of the image plane.*/
Furthermore, when we are dealing with digital images,  their coordinates are in pixel not in meters; we consider them to have their origin $(0,0)$ in the upper left corner, not at the center of the image plane anymore.
#figure(
  image("img/img_coordinates.png", width: 40%),
  caption: [
    Coordinate system of a digital image.
  ],
)

We move from the simplified pinhole camera model to a more realistic model, called the #emph(text(blue)[general pinhole model]) that takes into account all these non idealities.

=== Intrinsic parameters
Every camera has some #emph(text(blue)[intrinsic parameters]) which are related to its manufacturing process. These parameters remain the same even if the camera changes its orientation because, they are related to its _configuration_, not the position.

The general equation of a camera matrix looks like:
$

P= mat(
  -f k_u, -f k_u cot theta, u_0, 0;
  0, -(f k_v)/(sin theta), v_0, 0;
  0, 0, 1, 0;
)
$
and it takes into account three different non idealities.

The first non ideality, regards the fact that now, the point $(0,0)$ on the image plane isn't anymore at the center of the image plane but, it appears in the upper left corner. At the center now, there is the #emph(text(blue)[principal point]) $(u_0, v_0)$. This adds two "shift" parameters $u_0$ and $v_0$ that define the position in pixel units of the center of the plane.
#figure(
  image("img/I_non_ideality.png", width: 50%),
  caption: [The image plane with its origin located in the upper left corner and, the principal point $(u_0, v_0)$ at the center. (Notice that in this picture, the image plane has been moved to the right of the COP but, there would be no difference if it were at its left).],
)

The second non ideality, regards the fact that, being the coordinates of the sensor grid expressed in pixel units, they represent integer values so, images coordinates must be quantized and discretized. Coordinates in the grid, can be obtained dividing the image coordinates by the width and height of a pixel.
Pixels' shape could be rectangular instead of square, so we define $p_u$ and $p_v$ as the horizontal and vertical size of a sensor, measured in meters $m$, then, we define $k_u eq.def 1 slash p_u$ and $k_v eq.def 1 slash p_v$,  the inverse of the effective pixel size along the direction $bold(u)$ and $ bold(v)$ respectively, measured in $m^(-1)$. Finally, we need also to distinguish between the #emph(text(blue)[focal length]) $f$ which is the physical distance between the image plane and COP, measured in meters, and the #emph(text(blue)[focal]) $f k_u$ (or $f k_v$) used in the camera matrix of the general pinhole model, that is the product of the focal length $f$ and $k_u$ (or $k_v$) and is adimensional.
/*For this reason, two scale parameters $k_u$ and $k_v$, that represent the size of the sensors, are added.*/ /*Furthermore, being the coordinates of the sensor grid expressed in pixel units, the coordinates of the pixels need to be multiplied by the sizes of the sensors. Coordinates from the 3D world, measured in meters, have to be quantized and discretized into pixels on the grid.*/

The third non ideality, regards the fact that, due to
manufacturing errors, the grid of pixel isn't always perfectly squared and so, the camera coordinate system might be skewed. This means that the angle $theta$ between the axes $bold(u)$ and $bold(u)$ could not be equal to $90°$. The difference, by the way, is usually not so much and, we will not consider this fact in the future (which means that for us $theta = pi slash 2$ so that $cot (pi slash 2) = 0$ and $sin (pi slash 2) = 1$).
#figure(
  image("img/III_non_ideality.png", width: 40%),
  caption: [A skewed pixel grid of sensors],
)

The equation of a pixel in the image plane can be derived in the following way:
$
z vec(u, v, 1)
&=
mat(
  -f k_u, -f k_u cot theta, u_0, 0;
  0, -(f k_v)/(sin theta), v_0, 0;
  0, 0, 1, 0;
)
vec(x, y, z, 1) 

= mat(
  -f k_u x, -f k_u y cot theta, z u_0, 0;
  0, -(f k_v y)/(sin theta), z v_0, 0;
  0, 0, z, 0;
) 
$
Which in system form is equal to:
$
cases(
  z u = -f k_u x - f k_u y cot theta + z u_0,
  z v = -(f k_v y)/(sin theta) + z v_0,
  z 1 = z
)
$
that, in Cartesian coordinates, assuming $theta = pi slash 2$ is:
$
cases(
  u = - f k_u (x)/z + u_0,
  
  v = -f k_v (y)/z + v_0
) 
$
#v(0.50cm)
Intrinsic parameters can be represented using the #emph(text(blue)[intrinsic matrix]) $K$: 
$
/*"Assuming " theta = pi/2
#h(1.5cm)*/
K = mat(-f k_u, 0, u_0; 0, -f k_v, v_0; 0, 0, 1) 
#h(0.50cm)
"(assuming" theta = pi slash 2 ")"
$
and $P$ can be written as:
$
 P = mat(-f k_u, 0, u_0, 0; 0, -f k_v, v_0, 0; 0, 0, 1, 0) 
   = mat(-f k_u, 0, u_0; 0, -f k_v, v_0; 0, 0, 1) 
     mat(1, 0, 0, 0; 0,  1, 0, 0; 0, 0, 1, 0)
   = K mat(I_3, bar.v, bold(0))
$
#v(0.5cm)
The coordinates of a point $bold(m)$ can be normalized into a point $bold(m') = K^(-1) bold(m)$, if we know the intrinsic parameters://, into a pixel $bold(m')$ as:
$ 
  bold(m) &tilde.eq P bold(M) \
  bold(m) &tilde.eq K mat(I_3, bar.v, 0) bold(M) \
  K^(-1) bold(m) &tilde.eq K^(-1) K mat(I_3, bar.v, 0) bold(M) \
  bold(m') eq.def K^(-1) bold(m) &tilde.eq underbrace(mat(I_3, bar.v, 0), "P") bold(M)
$
and it follows that in this case $P = mat(I_3, bar.v, 0)$, the ideal camera matrix. Normalized coordinates allows us to work with image points independently of the camera characteristics. Doing so, the obtained image points are _invariant_ from the principal point $(u_0, v_0)$ and the zoom factor.
/*
Parte di Leonardo riscritta più sopra.
Tenere per chiedergli se va bene come ho riscritto.

== General pinhole model
#figure(
  image("img/intrinsic_parameters.png", width: 30%),
  caption: [
    Real world situation where the camera reference system does not correspond to the word reference system.
  ],
)

For this reason we provide a more general definition of $P$ that take in account those *non ideality* and correct them to reach the _ideal_ camera matrix using *intrinsic parameters*.
$
P= mat(
  -f k_u, -f k_u cot theta, u_0, 0;
  0, (-f k_v)/(sin theta), v_0, 0;
  0, 0, 1, 0;
)
$
- $(u_0, v_0)$: represent the *principal point*, a shift into the origin and are determined by the _plane size_.
#figure(
  image("img/I_non_ideality.png", width: 40%),
  caption: [
    coordinate referece of the camera without the shift.
  ],
)


- $theta$: represent the angle that depends on the _sensor shape_ and is used to fix the fact that axis are not orthogonal, typically is $pi/2$ in such a way that $cot (pi/2) = 0$ and $sin (pi/2) = 1$ 
- $k_u, k_v$: used to esclude real values they depends on the _pixel size_ $k_u = 1/P_u$, this calibration happen putting an object of a known size in front of the camera.
#figure(
  image("img/III_non_ideality.png", width: 40%),
  caption: [
    Pixel grid of the sensor
  ],
)
In this phase it is important to distinguish between:
- _Focal lenght_(m): distance of the image plane from the center of projectin
- _Focal(Adimensional) = focal lenght \* $k_u$ _

This values can be represented using the _intrinisc matrix_ $K$: 


$
"Assuming " theta = pi/2
#h(1.5cm)
bold(K)= mat(-f k_u, 0, u_0; 0, -f k_v, v_0; 0, 0, 1) 
$


So finally the new camera matrix can be rewritten as:
$
bold(P) = mat(K,bar.v, bold(0))
$
It is important to notice that this parameters are measured during the calibration phase.*/

=== Extrinsic parameters
Previously, we assumed that the world coordinates ($bold(X), bold(Y), bold(Z)$) were localized at the center of projection $bold(C)$, now instead, the camera reference system and the world reference system are different.
#figure(
  image("img/general-pinhole-model-1.png", width: 60%),
  caption: [
    The general pinhole model.
  ],
)

It is possible that the camera is placed in a different position with respect to the world coordinates. 
We can use a rotation and translation to links the two axes systems. We do so, by using the matrix $G$ that represent a Euclidean transformation.
$
G = mat(
  R_(3 times 3), bold(t);
  bold(0)^T , 1;
)
$

#figure(
  image("img/extrinsic_params.png", width: 50%),
  caption: [
    The world coordinates are mapped to the camera coordinates through a Euclidean transform.
  ],
)

We denote with $bold(M_c)$ a point in camera reference coordinates and with $bold(M)$ a point expressed in the world reference coordinates. The world coordinate $bold(M)$, can be mapped into the camera coordinate $bold(M_c)$ using $G$:
$
bold(M)_c = G bold(M)
$

$G$ is called the matrix of the #emph(text(blue)[extrinsic parameters]). It contains the rotation matrix $R$ and the translation vector $bold(t)$, so it has $6$ parameters that encode the exterior orientation of the camera with respect to the world reference system. If the camera moves, only the extrinsic parameters change, not the instrinsic, provided that the acquiring configuration (focus, zooming, ...) doesn't change.

When the camera coordinates coincide with the world coordinates, we have that $R = I_3$ and $bold(t) = bold(0).$


The equation of a pixel $bold(m)$ in homogeneous coordinates is:
$
  bold(m) tilde.eq P bold(M_c) 
                    &= mat(-f, 0, u_0, 0;
                           0, -f, u_0, 0;
                           0, 0,  1,   0) bold(M_c) \
                    &= mat(K, bar.v, bold(0)) #h(1mm) bold(M_c) \
                    &= K mat(I_3, bar.v, bold(0)) #h(1mm) bold(M_c) \
                    &= K mat(I_3, bar.v, bold(0)) #h(1mm) G bold(M) \
                    &= underbrace(K, "intrinsic \n parameters") underbrace(mat(I_3, bar.v, bold(0)), "projective \n normalized \n coordinates") underbrace(mat(R_(3 times 3), bold(t); bold(0)^T, 1;), "coordinate \n change") bold(M) \
                    &=  K mat(R, bar.v, bold(t)) bold(M)
                        
$
and therefore, we can write the #emph(text(blue)[general camera matrix]) $P$ as:
$
P = K mat(R, bar.v, bold(t))
$

//The #emph(text(blue)[camera calibration]) is the process used to do the estimation of both intrinsics and extrinsics parameters.

When the camera coordinates don't coincide with the world coordinates, it is possible to normalize the coordinates of a pixel $bold(m)$ into a pixel $bold(m') = K^(-1) bold(m)$, just by knowing $K$:
$ bold(m) &tilde.eq P bold(M) \
  bold(m) &tilde.eq K mat(R, bar.v, bold(t)) bold(M) \
  K^(-1) bold(m) &tilde.eq K^(-1) K mat(R, bar.v, bold(t)) bold(M) \
  K^(-1) bold(m) &tilde.eq K^(-1) K mat(R bar.v bold(t)) bold(M) \
  bold(m') eq.def K^(-1) bold(m) &tilde.eq underbrace(mat(R bar.v bold(t)), "P") bold(M) $
//$ bold(m') = K^(-1) bold(m) = K^(-1) P bold(M) = X X^(-1) mat(R bar.v bold(t)) bold(M) = mat(R bar.v bold(t)) bold(M) $
and it follows that in this case $P = mat(R bar.v bold(t))$.

== Center of projection coordinates
A generic camera matrix $P$ can be rewritten according to its rows as:
$ P = vec(bold(p_1)^T, bold(p_2)^T, bold(p_3)^T) $
and the prospective equation can be rewritten as:
$
 bold(m)  tilde.eq P bold(M) = vec(bold(p_1)^T, bold(p_2)^T, bold(p_3)^T) bold(M) = vec(bold(p_1)^T bold(M), bold(p_2)^T bold(M), bold(p_3)^T bold(M))
$

so, the coordinates of a pixel in the plane becomes, in Cartesian coordinates:
$
 cases(
  u = (bold(p_1)^T bold(M)) / (bold(p_3)^T bold(M)),
  
  v = (bold(p_2)^T bold(M)) / (bold(p_3)^T bold(M))
) 
$

But what about $bold(C)$? It is the 3D point that is at the origin of the camera coordinate system 
//($bold(tilde(C)) = mat(0,0,0)^T in RR^3$) 
and lies on the focal plane $cal(F)$. Homogeneous coordinates are nice to represent all the points made exception for $bold(C)$ because, it represents a point in the Euclidean space with a specific location. Homogeneous coordinates, on the other hand, are used to represent points in the projective space, which extends Euclidean space to include points at infinity and facilitate projective transformations. It doesn't make sense to represent $C$ as a point at infinity or as a point that can be scaled arbitrarily, therefore, it is represented using Cartesian coordinates.

$cal(F)$ (made of all the points which are projected at the infinite, except for $bold(C)$) is defined by the equation $bold(p_3)^T bold(M) = 0$, while the axes $u = 0$ and $v = 0$ correspond to the projection on the image plane $cal(Q)$, of the planes $bold(p_1)^T bold(M) = 0$ and $bold(p_2)^T bold(M) = 0$ respectively.
#figure(
  image("img/geometric-determination-COP.png", width: 60%),
  caption: [
   Geometric determination of the center of projection.
  ],
)
To find $bold(C)$ we have to solve the system that express the intersection of the $3$ planes at that point:
$
 cases(
  bold(p_1)^T bold(C) = 0,  
  bold(p_2)^T bold(C) = 0,
  bold(p_3)^T bold(C) = 0
)
#h(1cm)
<==>
#h(1cm)
P bold(C) = bold(0)
$

If we rewrite our generic $P$ as 
$  //bold(C) = vec(bold(tilde(C)), 1), #h(1cm) 
  P = mat(Q_(3 times 3), bar.v, bold(q)) 
$
 and express $bold(C)$ as
$
 bold(C) = vec(bold(tilde(C)), 1)
$
then
$
 P bold(C) &= bold(0) \ 
 mat(Q, bar.v, bold(q))  vec(bold(tilde(C)), 1) &= bold(0) \
 Q bold(tilde(C)) + bold(q) &= bold(0)
$
which leads to the Cartesian coordinates of the COP:
$  bold(tilde(C)) &= - Q^(-1) bold(q) $
//The center of projection is a fixed point in space with a specific location, and it doesn't make sense to represent it as a point at infinity or as a point that can be scaled arbitrarily. Therefore, it is typically represented using Cartesian coordinates rather than homogeneous coordinates

== Equation of a ray
Given two points $bold(M_1)$ and $bold(M_2)$, the convex combination of $bold(M_1)$ and $bold(M_2)$, gives you any point in the segment $overline(bold(M_1) bold(M_2))$:
$ alpha bold(M_1) + (1 - alpha) bold(M_2) "   with" alpha in #h(0.1cm) ]0,1[ $

To represent any point on the line that passes through $bold(M_1)$ and $bold(M_2)$, a general linear combination can be used:
$ alpha bold(M_1) + beta bold(M_2)  "   with" alpha, beta in RR $

The #emph(text(blue)[optical ray]) of a point $bold(m)$ is the line that contains $bold(C)$ and $bold(m)$ itself. It corresponds to the infinite set of 3D points 
$ {bold(M) : bold(m) tilde.eq P bold(M)} $
and it contains all the points $bold(M)$ in the Euclidean space of which $bold(m)$ is the projection onto the image plane.

By definition, $bold(C)$ is in the set#footnote[$bold(m)$ is not an element of the set, it is a point in the image plane, not in the Euclidean space.]. Another point contained in the set is the ideal point $bold(M_infinity)$ defined as
$
 M_infinity = vec(Q^(-1) bold(m), 0) " (the last element is " 0  "because it lies at " infinity ")"
$

We can see that $M_infinity$ is projected into $bold(m)$ because given a generic $P = mat(Q, bar.v, bold(q))$, $P bold(M_infinity)$ is
$ P bold(M_infinity) = underbrace(Q Q^(-1), "I") bold(m) + 0 bold(q) = bold(m) $

In homogeneous coordinates, it is
possible to write a parametric equation of the optical ray as a linear combination of $bold(C)$ and $bold(M_infinity)$:
$ bold(M) = bold(C) + lambda vec(Q^(-1) bold(m), 0), #h(1cm) lambda in RR union infinity $

//which in Cartesian coordinates is equivalent to:
//$ bold(tilde(M)) = bold(tilde(C)) + lambda vec(Q^(-1) bold(m)) $

Optical ray equations are the same for projectors and lasers as well. Given $Q$ and $bold(q)$ associated to the camera (projector) matrix $P$ obtained from the process of calibration, it is possible to compute $bold(M)$ in case the equation of the projection plane is known.
#figure(
  image("img/projector.png", width: 40%),
  caption: [
   Projection of the point $bold(M)$ on a plane.
  ],
)

== Camera calibration
There is a process called #emph(text(blue)[camera calibration]),  that allows us to estimate both the matrix of the intrinsic parameters $K$ and the matrix of the extrinsic parameters $mat(R, bar.v, bold(t))$.

We know the coordinates of $n$ 3D points $bold(M_i)$ (#emph(text(fill: blue)[calibration points])) and their projections $bold(m_i) = P bold(M_i) #h(0.25cm) (i = 1, ..., n)$ on the image plane. Knowing these points allows us to estimate the unknown parameters of $P$ (assuming that we don't change the configuration or the position of the camera), which means knowing where every 3D point of the world will be projected in our camera.
//#figure(
//  image("img/calibration-object.png", width: 40%),
//  caption: [
//   A calibration object.
//  ],
//)

Usually the $bold(M_i)$ points are chosen from a 2D checkerboard (it is very easy to detect its corners). Multiple images of the checkerboard are taken in different positions, keeping the camera fixed and translating and rotating the checkerboard, simulating the motion of the camera (same $K$, different $R$ and $bold(t)$ for each picture).

#figure(
  image("img/checkerboard-calibration.png", width: 40%),
  caption: [
   calibration through a checkerboad.
  ],
)

The calibration operation requires pixel precision. Usually, $tilde 30 slash 40$ images are enough.

It is preferable to don't use JPEG images because, this format has compression and, compression destroys the smaller details. We need instead, to be as precise as possible!

We want to find a $P$ such that the following quantity is _minimized_:
$ sum_(i=1)^n || bold(m_i) - P bold(M_i) || $

There exist different calibration methods, the most famous are:
- Direct calibration (camera parameters are estimated) [Caprile and Torre]#footnote( "https://link.springer.com/article/10.1007/BF00127813" );
- Estimate perspective projection matrix [Faugeras 1993]#footnote("https://mitpress.mit.edu/9780262061582/three-dimensional-computer-vision/");
- Zhang's method[2000]#footnote("https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr98-71.pdf").

#pagebreak()
= Homography computation
== Eigenvalues and eigenvectors recap
$
A_(n times n) bold(v) = lambda bold(v) #h(1cm) lambda in RR
$
all the $lambda_i$ values that solve this equation are called _eigenvalues_, all the $bold(v_i)$ that solve this equation are called _eigenvectors_.

$A$ can be decomposed into 
$
A = Q^T D Q
$ 
where 
$
D = mat(lambda_1, 0, ..., ..., 0;
         0, lambda_2, dots.down, dots.v,  dots.v;
       dots.v, dots.down, dots.down, dots.down, dots.v;
       dots.v, dots.v, dots.down, lambda_(n-1), 0;
       0, ..., ...., 0, lambda_n)

#h(1cm)

"and"

#h(1cm)

Q = mat(bold(v_1), bold(v_2), ..., bold(v_n))
$
$D$ is the diagonal matrix and Q is orthogonal (square matrix whose columns are orthogonal unit vectors)

If the matrix $A$ is invertible ($exists A^(-1)$), then every eigenvalue $lambda_i eq.not 0 #h(0.2cm) (i in {1, ..., n})$. Otherwise, if $A$ is not invertible $(exists.not A^(-1)$) it exists at least a $lambda_i$ such that $lambda_i = 0 "with" i in {1, ..., n}$.  

If it exists, $A^(-1) = (Q^T D Q)^(-1) = Q^T D^(-1) Q$. 

In case $exists lambda_i = 0$, we want to put on the right side of $Q$, all the columns $bold(v_i)$ such that their $bold(v_i) = bold(0)$.

$
Q = mat(dots.v, dots.v, ..., dots.v, 0, ..., 0;
        dots.v, dots.v, ..., dots.v, 0, ..., 0;
        dots.v, dots.v, ..., dots.v, 0, ..., 0;
        dots.v, dots.v, ..., dots.v, 0, ..., 0)
$

== Plane to plane mapping

A first real world application of the homography is the *plane to plane mapping*, the task to map the _point of a plane_ $bold(Pi)$ into the _image plane_.
This operation can be done by a mapping function called *homography* ($H_(Pi)$).\
Starting from the equation $bold(m) tilde.eq P bold(M)$ we obatain that $bold(m') tilde.eq H_Pi bold(m)$:
$
vec(u,v,1) tilde.eq mat(
  p_(1,1), p_(1,2), p_(1,3), p_(1,4);
  p_(2,1), p_(2,2), p_(2,3), p_(2,4);
  p_(3,1), p_(3,2), p_(3,3), p_(3,4);
)
vec(x, y, 0 ,1) =
mat(
  p_(1,1), p_(1,2), p_(1,4);
  p_(2,1), p_(2,2), p_(2,4);
  p_(3,1), p_(3,2), p_(3,4);
)
vec(x, y,1) 

\
"Since we are working in 2D the z value is 0"
$


Note that we can map any plane to any plane using $H_Pi(3 times 3)$ matrix.
This means that we can compose homgraphy to map an image throught diffetent planes.

Since I got a $3 times 3$ matrix I have $8$ degrees of freedom.
To compute $H_Pi$ we are going to use a set of $i$ known points $(bold(m)', bold(m))$:
$
bold(m)_i ' &tilde.equiv H_Pi bold(m)_i  #h(0.5cm) \

&arrow.t.b.double " since " {(m, m') | bold(m) in Pi and bold(m') in "image plane"}\
 
bold(m)_i ' &times H_Pi bold(m)_i = 0 #h(0.5cm)  \

&arrow.t.b.double "since "  bold(m)_i ' " is parallel to " H_Pi  \

"vec"(&[bold(m)_i ']_times H_Pi bold(m)_i) = 0 #h(0.5cm) \

&arrow.t.b.double "vectorize the operation" \

(bold(m)_i ^T &times.circle [bold(m)_i ']_times) "vec"(H_Pi) = 0 \

$

Let' s define $A= bold(m)_i ^T times.circle [bold(m)_i ']_times$ which is a matrix of rank 2(only 2 equation are linearly indipendent) so given $n$ points we are going to obtain $2n$ equations, for this reason we need at least *4* points to compute $H_Pi$.
$
A = vec(
bold(m)_1 ^T times.circle [bold(m)_1 ']_times, 
bold(m)_2 ^T times.circle [bold(m)_2 ']_times,
bold(m)_3 ^T times.circle [bold(m)_3 ']_times)

$

Sometimes can be usefull to rescale the coordinates using a scale factor $T slash T'$.


== Features detection
We need at least $4$ points to compute $H_Pi$ and so, we need to find to find a unequivocal correspondence between at least $4$ points of $Pi$ and $4$ points of the image plane.

This process can be thinked of as, finding the correspondences between the current image (from the camera) and some other visual information (from a database). //Some semantic information has to be extracted from the images.

To find the correspodences between points, we compute #emph(text(blue)[local descriptors]) using _feature detection_ algorithms.

#slantedColorbox(
  title: [Local Descriptors],
  color: "blue",
  radius: 2pt,
  width: auto
)[
  _Local descriptor_ are arrays that describe a specific point in an image so that, if an analogous array in another image is found, it may be assumed that, the two points described by the two arrays are exactly the same. This assumption by the way, may not always be correct.//(it is a projection of the same point that I have in the real world).
]

More formally, in computer vision we need to distinguish between keypoints and descriptors:

//https://web.archive.org/web/20201009073033/https://sites.google.com/site/eccv12features/
//https://answers.opencv.org/question/37985/meaning-of-keypoints-and-descriptors/
A #emph(text(blue)[key point]) (also #emph(text(blue)[local feature]) or feature point) is a pixel coordinate $(u, v)$ togheter with a _scale factor_ $s$ and an _orientation_ $o$:
$
bold(K_i) = vec(u_i, v_i, s_i, o_i)
$

a #emph(text(blue)[descriptor]) is an array of values which is the signature of the key point, that is, a representation of the intensity/color function of the point. It is used to compare the similarity between features:
$
bold(f)_i = vec(alpha_1, dots.v, alpha_t)
$
where $alpha_i$ depends on the representation defined by a #emph(text(blue)[feature detection algorithm]). By the way, according to the algotithm, there are various ways to represent a descriptor, such as:
- block of pixels;
- arrays of floats/bytes;
- binary arrays.
#slantedColorbox(
  title: [Feature detection algorithm],
  color: "green",
  radius: 2pt,
  width: auto
)[
    A feature detector (extractor) is an algorithm taking an image
as input and outputting a set of regions: local features (key points). 

Local features are _regions_, i.e. in principle arbitrary sets of pixels, not
necessarily contiguous, which are at least:
- distinguishable in an image regardless of viewpoint/illumination, scale, rotation;
- robust to occlusion: must be local;
- must have a discriminative neighborhood: they are “features”.

Example of detectors to extract local descriptors are: _SIFT, SURF, BRIEF, BRISK, FREAK _
#figure(
  image("img/sift.png", width: 60%),
  caption: [
   Desctiptor example using _Sift_
  ],
)
]

To identify the local descriptors, we proceed in two main steps:
1. #emph(text(blue)[Feature detection]): we extract the features of interest (edges, corners, ...);
2. #emph(text(blue)[Feature description]): we associate a _unique descriptor_ to each feature (it characterizes the feature and allows to distinguish it from other features).
In this way we can identify the key points (feature points) that represent the set of points used to compute the _homography matrix_ $H_Pi$.

== Feature matching
Once we have extracted the features $bold(K_i)$ from the camera image and have computed their local descriptors $bold(f_i)$, we do the same for the features $bold(K'_i)$ and their local descriptors $bold(f'_i)$ of the database image.
#figure(
  image("img/key_faeture.png", width: 60%),
  caption: [
   Key points ( 
      #emph(text(red)[$circle.big$])
   )
   and descriptors ( 
    #emph(text(green)[$square.big$])
    and 
    #emph(text(green)[$circle.big$])
   )  
  ],
)

If we take two descriptors, for example $bold(f_1)$ and $bold(f'_1)$ and compute their difference $norm(bold(f_1) - bold(f'_1))$, we could argue that if the result is lower than a threshold $epsilon$, the two descriptors describe the same key point. In practice, we don't do this because it is very difficult to find a good $epsilon$; its value could be too high or too low and, taking into account also the presence of noise, there could be a lot of false positive or false negative matches.

Then instead, to find the key points who really match the local descriptors, we compute the distance $d_(i,j)$ between each pair $(bold(f_i), bold(f'_j))$ of descriptors and, we order the results in ascending order; then we compute the ratio $r$ between the best two matches and, compare it with a threshold $tau$ that generally is $0.6$. If $r < tau$ then we can say that we have found a correct match (an #emph(text(blue)[inlier])) otherwise we have a wrong match (an #emph(text(blue)[outlier])).

The nitty-gritty is that, a key point should be uniquely distinguishable among all the other key points and, if $r > tau$, this doesn't hold anymore. The value of $tau$ determines if there is a match or not, in combination with the quality of the images and, it represents a crucial factor. The fact that we use a ratio between the best two matches excludes the possibility to have multiple matches (thing that could have happened instead if, we would have compared directly each descriptor $bold(f_i)$ and $bold(f'_j)$ with a threshold $epsilon$, that is: $norm(bold(f_i) - bold(f'_j))$ < $epsilon$).

This procedure is also sensible to noise and for this reason, in images with high levels of noise, there could be a lot of outliers.

Once we have determined the key points, we can finally compute the homography $H_Pi$.

=== Key points computation example
#figure(
  image("img/feature-matching.png", width: 70%),
  caption: [
   feature matching example \ (notice that in this case the symbols  #emph(text(red)[$circle.big$]) and #emph(text(green)[$square.big$]) are used to represent outliers and inliers respectively)
  ],
)<feature-matching>
Considering the @feature-matching, for each descriptor $bold(f_i)$ of the left picture, we compute the difference with all the descriptors $bold(f'_j)$ of the right picture. For example, we consider the computations needed to find a correspondence for the points described by $bold(f_1)$ and $bold(f_8)$. Once the distances have been computed, we order them in ascending order and obtain:
$
d_(1,2) &= norm(bold(f_1) - bold(f'_2)) #h(5cm) d_(8,6) &&= norm(bold(f_8) - bold(f'_6))

\ &<  #h(5cm)  &&< \

d_(1,1) &= norm(bold(f_1) - bold(f'_1)) #h(5cm) d_(8,5) &&= norm(bold(f_8) - bold(f'_5)) 

\ &<  #h(5cm)  &&< \
\ &dots.v  #h(5cm)  &&dots.v \ 
\ &<  #h(5cm)  &&< \
d_(1,7) &= norm(bold(f_1) - bold(f'_7)) #h(5cm) d_(8,3) &&= norm(bold(f_8) - bold(f'_3))

\ &<  #h(5cm)  &&< \

d_(1,6) &= norm(bold(f_1) - bold(f'_6)) #h(5cm) d_(8,4) &&= norm(bold(f_8) - bold(f'_4)) \
$ 

finally for each sequence, we compute the ratio between the best two matches and compare it with $tau = 0.6$:
$
d_(1,2) / d_(1,1) = 0.35 < 0.6 
#h(5cm)
d_(8,6) / d_(8,5) = 0.8 > 0.6
$

so, we can say that there is match between the key points represented by the descriptors $bold(f_1)$ and $bold(f'_2)$ and, that there are no matches for the point represented by the descriptor $bold(f_8)$.

#figure(
    grid(
        columns: (auto, auto),
        rows:    (auto, auto),
        gutter: 0.1em,
        [ #image("img/d_1x.png", width: 100%) ],
        [ #image("img/d_8x.png", width: 100%) ]
    ),
    caption: [\ On the left: the relation between the points $bold(f'_x)$ and their distance from $bold(f_1)$.\ On the right: the relation between the points $bold(f'_x)$ and their distance from $bold(f_8)$.]
)

//Threshold can change according to the images because, there could be very low illumination conditions, there could be occlusion, some images can be of very different qualities ...

== Noise and compression
As mentioned above, the feature matching computation is sensible to strong _noise_ levels that, generate false matches.

Unfortunately, noise and compression alter descriptors and key points (they change orientation, scale, locations); also, compression makes disappear the smallest local features and so, also the number of local descriptor is reduced.

The fact that compression also changes the position of the key points is a problem for 3D estimation because it reduces the level of precision when computing an homography.

Depending on the kind of descriptors that are used, there could be different problems. For example, SIFT is invariant to rotation but, only for angles of maximum $30°$, if the rotation introduced by the noise has a bigger angle, then features will not match anymore.
#figure(
  image("img/compression.png", width:90%),
  caption: [
    Effects of image compression.
  ],
)

We have seen that if we have an image $I$ taken with our camera and a query image $I_s$, we can look for a common object between the two regardless of rescaling,
occlusions, rotations, etc...

We can do so by computing (for example) SIFT key points and descriptors on $I$ and $I_s$, obtaining the sets
$
{(bold(k_i), bold(f_i)) | bold(K_i) = mat(u_i, v_i, s_i, o_i)^T}
#h(1cm) "and" #h(1cm)
{(bold(k^s_i), bold(f^s_i)) | bold(K^s_i) = mat(u^s_i, v^s_i, s^s_i, o^s_i)^T}
$
respectively. Then we match the descriptors $bold(f_i)$ to $bold(f^s_j)$ so that it is possible to build a set of couples $(bold(k_i), bold(k^s_j))$. We assume without loss of generality that, the i-th key point in $I$ is matched with the i-th key point in $I_s$ so that the set is made of couples of the form $(bold(k_i), bold(k^s_i))$.

Then we compute the affine transform (the homography) $H$ that satisfies the relation
$
vec(v_i, u_i, 1) = H vec(v^s_i, u^s_i, 1)
$

and if 
$
norm(vec(v_i, u_i, 1) - H vec(v^s_i, u^s_i, 1)) < delta
$
for a certain threshold $delta$, the object is found. 

The last step means that we are trying to match/make fit the object in $I_s$ with the object in $I$ through an affine transformation $H$ that rotates and scales $I_s$. 
If the two roughly fit with respect to a delta $delta$, then we have found the object.

The problem is that the two images can be really noisy and the position of the key points could be moved. To solve this problem, we could adopt some more intelligent strategies, the one that we see are linear regression and the RANSAC algorithm.

=== Linear regression
#emph(text(blue)[Linear regression]) is a supervised learning problem that consists of fitting an $(n+1)$-dimensional hyperplane (in $2$ dimensions a line) to a set of $n$ points ${(bold(x)_1, y_1), ..., (bold(x)_N, y_N)}$ where $ bold(x)_i = mat(x_(i,1), ..., x_(i,n))^T$. We want to find the set of parameters $theta_1, ..., theta_n$ that define the hyperplane which fits all these points.
The plain can be defined as:
#text(size: 13pt)[$ y_i = theta_1 x_(i,1)+theta_2 x_(i,2)+ ... +  theta_n x_(i,n) $]
and it corresponds to the _linear model_ of our data; it is corrupted by noise and in fact #text(size: 13pt)[$y_i eq.def overline(y_i) + e_y_i$] and #text(size: 13pt)[$x_(i,j) eq.def overline(x_(i,j)) + e_x_(i,j)$] where #text(size: 13pt)[$overline(y_i)$] and #text(size: 13pt)[$overline(x_(i,j))$] are noise free and, #text(size: 13pt)[$e_y_i$] and #text(size: 13pt)[$e_x_(i,j)$] are the noises added to them.

Considered:
$
bold(x_i) = 
  underbrace(
    vec(x_(i,1), dots.v, x_(i,n)), 
    "independent \n variables"),

underbrace(
  y_i, 
"dependent \n variable"),

#h(0.25cm)
bold(hat(theta)) = underbrace(
   vec(theta_1, dots.v , theta_n ), 
   "Estimated \n model \n parameters")
$
it can be rewritten as
#text(size: 13pt)[$ y_i tilde.eq bold(hat(theta))^T bold(x)_i $]
and we're using the approximately equal sign "$tilde.eq$", because we can't be absolutely sure that all the data lie completely on a single line/plane.

In practice we have /*the error $e_i$ and*/ $n$ weights $theta_1, ..., theta_n$ that must be tuned to minimize a loss function in a way such that:
$ y_i tilde.eq theta_1 x_(i,1)+theta_2 x_(i,2)+ ... +  theta_n x_(i,n) /* e_i */ $
which corresponds to fitting the hyperplane to the set of data points.

#figure(
  image("img/linear-regression.png", width:90%),
  caption: [
    \ On the left: linear regression in a $2$D space.
    \ On the right:linear regression in a $3$D space.
    \ (Picture taken from the book Machine Learning Refined by Watt, Borhani, Katsaggelos)
  ],
)

To fit the hyperplane we can use different approaches:
- #emph(text(blue)[LS-estimator (Least Square-estimator)]): we want to find the parameter $hat(theta)$ such that, the #emph(text(blue)[mean square error (MSE)]) function 
  $ sum_(i)norm(y_i - bold(hat(theta))^T bold(X_i))^2 $ 
  is minimized. 
  $ 
      y_i tilde.eq bold(hat(theta))^T bold(x_i) 
      
      " is equivalent to "
      
      bold(hat(theta))^T bold(x_i)^T bold(hat(theta)) = y_i 
  $
  which implies that the overdetermined system
  $   
    vec(bold(x_1)^T, dots.v, bold(x_n)^T) bold(hat(theta)) = vec(y_1, dots.v, y_n)
  $
  is equivalent to
  $ X hat(theta) = bold(y) $
  We can multiply both parts of the equation for $X^+$, the pseudo inverse of $X$ and get 
  $ bold(hat(theta)) = X^+ bold(y) $ 
  which is called the _least square solution_.  
  
  //More specific, this problem corresponds to the estimation of a line that "fits" all the points in #emph_blue[continuare guardando dal video ...]
  
  By the way, this approach is too simple and, the outliers still have an high impact on the computation of the paramter $bold(hat(theta))$.

  In the LS estimate, we minimize the mean of of the square:
  $ min( sum_i norm(y_i - bold(hat(theta))^T bold(x)_i )^2 ) $
  which is equivalent to:
  $ min sum_i r_i^2 eq.triple min EE[r_i^2] $
      #figure(
    image("img/LS.jpg", width: 40%),
    caption: [
      A representation of the mean square error approach, in red the _square error_ (distance from the line) and in the center we can see the mean.
    ]
  ) 
  
  An approach to reduce the effect of the outliers on the estimation is the  #emph(text(blue)[LMedS (Least Median Square)]) where the median of the residuals is computed instead of the mean: $ min { "med"_i r_i^2} $
  The LMedS algorithm is the following: given a set of $N$ samples
  + take a random set of $m$ samples ($m < N$);
  + compute the LS parameter estimate on the subset;
  + compute the median
    $ "med"_i { (y_i - bold(hat(theta))^T bold(x)_i )^2 } $
  + iterate stes 1.-3. $t$ times and take the estimation with the minimum median.
  
  //http://www-sop.inria.fr/odyssee/software/old_robotvis/Tutorial-Estim/node24.html
-  #emph(text(blue)[M-estimator (Maximum  likelihood-like estimator)]): An alternative is to modify the error function using a _loss/penalty function_ $rho$ (which has to be symmetric, subquadratic and having minimum in $bold(0)$) to obtain a more robust estimation:
    $ "min" sum_i rho(y_i - theta^T bold(x)_i) $
  
   An example of $rho$ is the Cauchy function
   $ rho(x) = beta^2 / 2 log(1 + x^2 / beta^2) $
   //that, affects the estimation more from the small error insteed of big ones.
-  #emph(text(blue)[R-estimator (Resistant estimator)]): suppose that we order residuals 
   $ r_i= y_i-bold(hat(theta))^T bold(x)_i $ 
   such that the placement of residuals $r_i$ is $R_i$.
   
   Then we want to minimize: $ min(sum_i a_n (R_i) r_i) $ where $a_n$ is a monotonic decreasing function such that $ sum_i a_n (R_i)=0 $

=== RANSAC
#emph_blue("RANSAC (Random Sample Consensus)") is a widely-used iterative algorithm for robust model estimation that basically, subsample randomly couple of matches with the objective to leave out outliers. This process is repeated multiple times untill the desired result is obtained.

Given a set of $N$ points:
+ Take a random subset of $m$ samples ($m < N$);
+ Compute the least square parameter estimate on the subset using a robust estimation technique (e.g.: _LMedS_);
+ Compute the numbers of _inliers_ over the entire set (with cardinality N), i.e.: the points that are distant at most $epsilon$ from the regression line: $norm(y_i-m x_i-q)^2 < epsilon$;
+ Iterate step 1.-3. until the number of _inliers_ is greater then a threshold $T$ or, for a finite number of iterations;
+ Take the best least square estimation and recompute the parameters only on the set of inliers. //(i.e. on the whole set of points such that :$norm(y_i - m x_i - q)^2 < epsilon$).

//Summing up, in RANSAC you take a random subset of the samples and compute the least square parameter $bold(hat(theta))$ and then, you compute the number of outliers that you get from the model. If you have a low amount of outliers, then you have a good sample, otherwise you can take another random subsample and retry. You proceed this way untill you're satisfied. The final estimate is refined since outliers are excluded from the estimation process.
#figure(
   image("img/RANSAC.png", width: 60%),
   caption: [
     RANSAC example with various iterations. The best iteration is the one corresponding to the green line ($79$ inliers), which is the one that approximate better the ground truth line (represented for convention with $-1$ inliers)
   ],
)

==== RANSAC homography estimate 
RANSAC can be used to estimate the homography $H_Pi$ and, the process is mostly the same as the one described above. In this case, the algorithm works on the couple of points from the two images.  
+ Compute the set of possible matches (cardinality $N$) using any feature detection algorithm (i.e. SIFT);
  #figure(
    image("img/RANSAC_SIFT.png", width: 70%),
    caption: [
      Match points obtained using SIFT.
    ],
  ) <matches>
  - Select a random subset of points (cardinality $m < M$) from the set of all the possible matches computed in 1.;
    #figure(
      image("img/RANSAC_subsamples.png", width: 50%),
      caption: [
        Subsample set of size 5 over a set of size 51.
      ],
    ) 
  - Compute the homography $H$ over the subsampled data using linear regression;
    #figure(
      image("img/RANSAC_regression.png", width: 50%),
      caption: [
        The regressor line computed over the subsamplded data
      ],
    ) 
  - Compute the number of inliers $n$ (i.e.: the points such that $|| m'_i - H m_i||^2 < epsilon $);
    #figure(
      image("img/RANSAC_trashold.png", width: 50%),
      caption: [
        The identification of inliers (blue dots) and outliers (red dots) over the entire data using an $epsilon=25$.
      ],
    ) 

  - Repeat until the max number of iterations is reached or, the inliers' threshold is reached. The number of iterations at the end is $k$.
    #align(
      center, 
      "it 1: " + $H_1 --> $ + "#inliers " + $n_2$ + "\n" +
      "it 2: " + $H_2 --> $ + "#inliers " + $n_2$ + "\n" +
       $dots.v$ + "\n" +
      "it k: " + $H_k --> $ + "#inliers " + $n_k$ 
    )
+ Take $H_k$ s.t. $k = arg max_i n_i$;
+ Finally recompute $H_pi$ on the inliers set.
At the end the object is found if $"#inliers"$ is greater than a threshold $T_("found")$.
#figure(
  image("img/RANSAC_final_match.png", width: 80%),
  caption: [
    The inliers above and  outliers below.
  ],
)

The accuracy of the homography estimation depends on:
- the tresholds: 
  - $epsilon$: its accuracy tells us if a point is an inlier or an outlier;
   - low value  $=>$ more robust matches but less inliers;
   - high value $=>$ less robust matches but more inliers. Notice that these matches are less robust, so in the end there is a risk of getting more false positive matches.
  - $T_"found"$: its accuracy tells us the number of inliers founded at the end of the algorithm;
   - low value  $=>$ faster but low confidence;
   - high value $=>$ high computational cost with high confidence.
- the number of iterations and confidence:
 - more iterations $=>$ more inliers but also more computational demanding;
 - more confidence $=>$ more inliers but also more computational demanding;
 - the more keyponts the more matches have to be done, matches implies iterations and the more iterations the more computation has to be done.
#figure(
    grid(
        columns: (auto, auto),
        rows:    (auto, auto),
        gutter: 0.1em,
        [ #image("img/iterations-confidence-inliers.png", width: 60%) ],
        [ #image("img/iterations-confidence-computational-time.png", width: 60%) ]
    ),
    caption: [\ On the left: the number of inliers as a function of the number of iterations and the confidence.\
    On the right: the execution time as a function of the number of iterations and the confidence]
) <trade-off-iterations-confidence>
So, in the end, a trade-off between the number of iterations and the confidence must be considered.

RANSAC improve the matching of local features despite variations in the viewpoint, illumination, and occlusions.
#figure(
  image("img/RANSAC_model_comparison.png", width: 50%),
  caption: [
    Comparison between the _linear_ model and the the _RANSAC_ model of @matches
  ],
)

==== The environment plays a significant role
Robust target recognition and tracking is
challenging to obtain due to several factors:
- natural and artificial environmental occlusions;
- false matches as a consequence of projected shadows;
- insufficient features recognition because of brightness variation and lightning saturation.

Resulting on:
- Unstable 3D model registration and tracking;
- 3D model oscillation and wrong positioning when user’s viewpoint is changed.

Possible solutions to this problem are:
- acquire a wide and diversified dataset;
- focus on multiple small and detailed targets;
- use 3D object targets.

#figure(
    grid(
        columns: (auto, auto, auto, auto),
        rows:    (auto, auto, auto, auto),
        gutter: 0.1em,
        [ #image("img/8-am.png", width: 70%) ],
        [ #image("img/9-am.png", width: 70%) ],
        [ #image("img/12-am.png", width: 70%) ],
        [ #image("img/4-pm.png", width: 70%) ]
    ),
    caption: [Same picture taken under different enviromental conditions, during the day,]
) <enviromental-conditions>


=== 3D object Target
It is important to notice that, in the end, when we are implementing a VR app, the homography estimation used to map the points will be unstable for tracking, as consequence of a change in the user's view point because, it moves the mobile phone and there can be model oscillations.
A possible solution to this problem is the #emph_blue[3D object target] which, allows us to recognize and track particular objects in the real world based on their shape.

It extends the capabilities of recognition and
tracking of complex 3D Objects and is recommended for monuments, statues, industrial objects, toys and tools.

It requires the 3D objects to be rigid, to present a sufficient number of stable surface features and to be fixed with respect to the environment.

It is implemented by using Object Recognition algorithms
such as the Simultaneous Localization and Mapping (SLAM).

#figure(
    grid(
        columns: (auto, auto, auto),
        rows:    (auto, auto, auto),
        gutter: 0.1em,
        [ #image("img/3d-obj-1.png", width: 80%) ],
        [ #image("img/3d-obj-2.png", width: 80%) ],
        [ #image("img/3d-obj-3.png", width: 80%) ],
    ),
    caption: [3D object target example taken from vuforia.com]
) <3d-obj-target>

#pagebreak()
