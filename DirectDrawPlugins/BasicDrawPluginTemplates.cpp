// DrawPluginTemplates.cpp
//
/////////////////////////////////////////////////////////////////////////////

#include <cassert>

//	Templatized drawing/filling methods. This file is included in DrawPlugin.h
//	because it's needed by the compiler in order to expand the templates.

/////////////////////////////////////////////////////////////////////////////
// circle
/////////////////////////////////////////////////////////////////////////////

template <bool fill>
void BasicDrawPlugin::circle(int xOri, int yOri, int radius, int color)
{
	assert(radius > 0);

	if (radius <= 0) return;

	// circle->F(x,y) = x^2 + y^2 = radius^2, relative to center (xOri, yOri)

	// calculate decision variable vars
	int d = 1 - radius;
	int dE = 3;
	int dSE = 5 - 2*radius;

	// starting point
	int x = 0;
	int y = radius;

	// compute 45 degrees and draw the rest using symmetrical points
	while (y > x){
		fill ? fillSymmetrical4ScanLines(x, y, xOri, yOri, color) : drawSymmetrical8Points(x, y, xOri, yOri, color);
		if (d < 0){
			d += dE;
			dSE += 2;
		} else {
			d += dSE;
			dSE += 4;
			y--;
		}
		dE += 2;
		x++;
	}
}

/////////////////////////////////////////////////////////////////////////////
// ellipse
/////////////////////////////////////////////////////////////////////////////

template <bool fill>
void BasicDrawPlugin::ellipse(int xOri, int yOri, int a, int b, int color)
{
	assert((a > 0) && (b > 0));

	if ((a <= 0) || (b <= 0)) return;

	// ellipse->F(x,y) = (x/a)^2 + (y/b)^2 = 1, relative to center (xOri, yOri)

	// precompute some vars
	int a2 = a*a;
	int b2 = b*b;
	int twoa2 = 2*a2;
	int twob2 = 2*b2;

	// compute 90 degrees and draw the rest using symmetrical points

	// calculate gradients
	int gradX = 0;
	int gradY = twoa2*b;

	// calculate decision variable vars
	int d = b2 + (a2*(1 - 4*b) - 2)/4;
	int dE = 3*b2;
	int dSE = dE + twoa2*(1 - b);

	// starting point
	int x = 0;
	int y = b;

	// compute x axis dominant part
	while (gradX <= gradY){
		fill ? fillSymmetrical2ScanLines(x, y, xOri, yOri, color) : drawSymmetrical4Points(x, y, xOri, yOri, color);
		if (d < 0){
			d += dE;
			dSE += twob2;
		} else {
			d += dSE;
			dSE += twoa2 + twob2;
			gradY -= twoa2;
			y--;
		}
		dE += twob2;
		gradX += twob2;
		x++;
	}

	// calculate gradients
	gradX = twob2*a;
	gradY = 0;

	// calculate decision variable vars
	int t = a2 + (b2*(1 - 4*a) - 2)/4;
	int tN = 3*a2;
	int tNO = tN + twob2*(1 - a);

	// starting point
	x = a;
	y = 0;

	// compute y axis dominant part
	while (gradX >= gradY){
		fill ? fillSymmetrical2ScanLines(x, y, xOri, yOri, color) : drawSymmetrical4Points(x, y, xOri, yOri, color);
		if (t < 0){
			t += tN;
			tNO += twoa2;
		} else {
			t += tNO;
			tNO += twoa2 + twob2;
			gradX -= twob2;
			x--;
		}
		tN += twoa2;
		gradY += twoa2;
		y++;
	}
}
