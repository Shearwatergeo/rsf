// Lowrank decomposition for 2-D prestack exploding reflector
//   Copyright (C) 2010 University of Texas at Austin
//  
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//  
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//  
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#include <time.h>

#include <rsf.hh>

#include "vecmatop.hh"
#include "serialize.hh"

using namespace std;

static std::valarray<float>  vs;
static std::valarray<double> ks;
static float dt;
static int nh;

int sample(vector<int>& rs, vector<int>& cs, DblNumMat& res)
{
    int nr = rs.size();
    int nc = cs.size();
    res.resize(nr,nc);  
    setvalue(res,0.0);
    for(int a=0; a<nr; a++) {
	for(int b=0; b<nc; b++) {
	    res(a,b) = 2*(cos(vs[rs[a]/nh]*ks[cs[b]]*dt)-1); 
	}
    }
    return 0;
}

int main(int argc, char** argv)
{   
    sf_init(argc,argv); // Initialize RSF

    iRSF par(0);
    int seed;

    par.get("seed",seed,time(NULL)); // seed for random number generator
    srand48(seed);

    float tol;
    par.get("tol",tol,1.e-4); // tolerance

    int npk;
    par.get("npk",npk,20); // maximum rank

    par.get("dt",dt); // time step

    iRSF vel;

    int nz,nx; // velocity comes transposed
    vel.get("n1",nx);
    vel.get("n2",nz);
    
    int m = nx*nz;
    std::valarray<float> vels(m);
    vel >> vels;    
    vs.resize(m);
    vs = vels;

    par.get("nh",nh); /* number of offsets */
    m *= nh;
    
    iRSF fft("fft");

    int nkh,nkx,nkz;
    fft.get("n1",nkh);
    fft.get("n2",nkx);
    fft.get("n3",nkz);

    float dkh,dkx,dkz;
    fft.get("d1",dkh);
    fft.get("d2",dkx);
    fft.get("d3",dkz);
    
    float kh0,kx0,kz0;
    fft.get("o1",kh0);
    fft.get("o2",kx0);
    fft.get("o3",kz0);

    float kh, kx, kz;

    float eps;
    par.get("eps",eps,0.001); // regularization
    eps *= dkz;
    eps *= eps;

    int n = nkh*nkx*nkz;
    std::valarray<double> k(n);
    for (int ih=0; ih < nkh; ih++) {
	kh = kh0+ih*dkh;
	kh *= kh;
	for (int ix=0; ix < nkx; ix++) {
	    kx = kx0+ix*dkx;
	    kx *= kx;
	    for (int iz=0; iz < nkz; iz++) {
		kz = kz0+iz*dkz;
		kz *= kz;

		k[iz+ix*nkz] = SF_PI*sqrt((kx+kz)*(1+kh/(kz+eps)));
	    }
	}
    }
    ks.resize(n);
    ks = k;

    vector<int> lidx, ridx;
    DblNumMat mid;

    iC( lowrank(m,n,sample,(double) tol,npk,lidx,ridx,mid) );

    int m2=mid.m();
    int n2=mid.n();
    double *dmid = mid.data();

    std::valarray<float> fmid(m2*n2);
    for (int k=0; k < m2*n2; k++) {
	fmid[k] = dmid[k];
    }

    oRSF middle;
    middle.put("n1",m2);
    middle.put("n2",n2);
    middle << fmid;

    vector<int> midx(m), nidx(n);
    for (int k=0; k < m; k++) 
	midx[k] = k;
    for (int k=0; k < n; k++) 
	nidx[k] = k;    

    DblNumMat lmat(m,m2);
    iC ( sample(midx,lidx,lmat) );
    double *ldat = lmat.data();

    std::valarray<float> ldata(m*m2);
    for (int k=0; k < m*m2; k++) 
	ldata[k] = ldat[k];
    oRSF left("left");
    left.put("n1",m);
    left.put("n2",m2);
    left << ldata;

    DblNumMat rmat(n2,n);
    iC ( sample(ridx,nidx,rmat) );
    double *rdat = rmat.data();

    std::valarray<float> rdata(n2*n);    
    for (int k=0; k < n2*n; k++) 
	rdata[k] = rdat[k];
    oRSF right("right");
    right.put("n1",n2);
    right.put("n2",n);
    right << rdata;

    return 0;
}
