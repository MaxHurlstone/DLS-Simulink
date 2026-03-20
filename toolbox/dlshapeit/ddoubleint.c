/*
	discrete time double integrator filter (Matlab 6 version)

	(c) Rene' van de Molengraft, 2002
	(c) Gert Witvoet, 2022

	last update: October, 7th, 2022

	Inputs : u[0]     = signal to be filtered
	Outputs: y[0]     = double integrator-filtered signal

	Parameters: [f_num,b_num] (frequency in Hz, and normalized damping)
*/

#define S_FUNCTION_NAME ddoubleint
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define NSTATES		0
#define NINPUTS		1
#define NOUTPUTS	1
#define NPARAMS		3

#define NRWRK		4

#define PI		3.14159265358979

/* aliases for parameters */

#define F_NUM		ssGetSFcnParam(S,0)
#define B_NUM		ssGetSFcnParam(S,1)
#define STEPSIZE	ssGetSFcnParam(S,2)

#define UKM1		rwrkpr[0]
#define UKM2		rwrkpr[1]
#define YKM1		rwrkpr[2]
#define YKM2		rwrkpr[3]

/* just to be sure... */
#include <math.h>

/*====================*
 * S-function methods *
 *====================*/
 
#define MDL_START /* Change to #undef to remove function */
#if defined(MDL_START)
/* Function: mdlStart =======================================================
* Abstract:
* This function is called once at start of model execution. If you
* have states that should be initialized once, this is the place
* to do it.
*/
static void mdlStart(SimStruct *S)
{
	real_T *rwrkpr=ssGetRWork(S);
	int_T i;

/*	zeroise work space */
	for (i=0;i<NRWRK;i++) {
		rwrkpr[i]=0;
	}
}
#endif /* MDL_START */





#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S)
{
}
#endif /* MDL_CHECK_PARAMETERS */





static void mdlInitializeSizes(SimStruct *S)
{
	ssSetNumSFcnParams(S,NPARAMS);  /* Number of expected parameters */
#if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S)==ssGetSFcnParamsCount(S)) {
	  mdlCheckParameters(S);
	  if (ssGetErrorStatus(S)!=NULL) {
	    return;
	  }
	} else {
	  return; /* Parameter mismatch will be reported by Simulink */
	}
#endif

	ssSetNumContStates(S,NSTATES);
	ssSetNumDiscStates(S,0);

	if (!ssSetNumInputPorts(S,1)) return;
	ssSetInputPortWidth(S,0,NINPUTS);
	ssSetInputPortDirectFeedThrough(S,0,NINPUTS);

	if (!ssSetNumOutputPorts(S,1)) return;
	ssSetOutputPortWidth(S,0,NOUTPUTS);

	ssSetNumSampleTimes(S,1);
	ssSetNumRWork(S,NRWRK);
	ssSetNumIWork(S,0);
	ssSetNumPWork(S,0);
	ssSetNumModes(S,0);
	ssSetNumNonsampledZCs(S,0);
}





static real_T get_step_size(SimStruct *S)
{
	const real_T *param_step = mxGetPr(STEPSIZE);
	real_T eps=1.0e-16;
	real_T step;

	if (ssIsVariableStepSolver(S)) {
		step=*param_step;
		if (step<eps) {
			step=0.001;
		}
	} else {
		step=ssGetSampleTime(S, 0);
	}
	return step;
}





static void mdlInitializeSampleTimes(SimStruct *S)
{
	if (ssIsVariableStepSolver(S)) {
		ssSetSampleTime(S,0,get_step_size(S));
	        ssSetOffsetTime(S,0,0.0);
#ifdef  MATLAB_MEX_FILE
		printf("dweakint: discete stepsize = %f s.\n",get_step_size(S));
#endif
	} else {
		ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
	        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
	}
}





real_T absval(real_T x)
{
	if (x>=0) {
		return x;
	} else {
		return -x;
	}
}





real_T minval(real_T x, real_T y)
{
	if (x<=y) {
		return x;
	} else {
		return y;
	}
}





real_T maxval(real_T x, real_T y)
{
	if (x>=y) {
		return x;
	} else {
		return y;
	}
}





static void mdlOutputs(SimStruct *S, int_T tid)
{
	real_T *y=ssGetOutputPortRealSignal(S,0);
	const real_T *param_fnum = mxGetPr(F_NUM);
	const real_T *param_bnum = mxGetPr(B_NUM);
	InputRealPtrsType uPtrs=ssGetInputPortRealSignalPtrs(S,0);
	real_T *rwrkpr=ssGetRWork(S);

    real_T a0,a1,a2,b0;
	real_T a2s,a1s,a0s,b2s,b1s,b0s;
	real_T omp,alfa,eps;
	real_T om;

/*	parameters are (re)computed here to enable changes on-the-fly */
/*	choosing the prewarp frequency equal to the zero location */

	om=2.0*PI*absval(*param_fnum);
	
	eps=1.0e-16;
	omp=om+eps;
	alfa=omp/tan(omp*get_step_size(S)/2.0);

/*	continuous-time parameters */
/*	filter definition: (s^2+2*beta*omega*s+omega^2)/s^2 */

	a2=1.0;
	a1=2.0*absval(*param_bnum)*om;
	a0=om*om;

	b0=1.0;

/*	discrete time parameters (tustin with prewarping) */
/*	obtained by substituting alfa*(z-1)/(z+1) for every s */

	a2s = a2*alfa*alfa + a1*alfa + a0;
	a1s = -2.0*a2*alfa*alfa + 2.0*a0;
	a0s = a2*alfa*alfa - a1*alfa + a0;

	b2s=alfa*alfa*b0;
	b1s=-2.0*alfa*alfa*b0;
	b0s=alfa*alfa*b0;

/*	filter output */
/*	difference equation is:
		b2*y(k+2)+b1*y(k+1)+b0*y(k) = a2*u(k+2)+a1*u(k+1)+a0*u(k)
	or...
		b2*y(k)+b1*y(k-1)+b0*y(k-2) = a2*u(k)+a1*u(k-1)+a0*u(k-2) */

	y[0]=1.0/b2s*(-b1s*YKM1-b0s*YKM2 + a2s*U(0)+a1s*UKM1+a0s*UKM2);

/*	save history */

	UKM2=UKM1;
	UKM1=U(0);

	YKM2=YKM1;
	YKM1=y[0];

}
 
 
 


static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
