
/*
	discrete time weak integrator filter (Matlab 6 version)

	(c) Rene' van de Molengraft, 2002

	last update: February, 2th, 2003

	Inputs : u[0]     = signal to be filtered
	Outputs: y[0]     = weak integrator-filtered signal

	Parameter: [f_num] (frequency in Hz)
*/

#define S_FUNCTION_NAME dweakint
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define NSTATES		0
#define NINPUTS		1
#define NOUTPUTS	1
#define NPARAMS		2

#define NRWRK		2

#define PI		3.14159265358979

/* aliases for parameters */

#define F_NUM		ssGetSFcnParam(S,0)
#define STEPSIZE	ssGetSFcnParam(S,1)

#define UKM1		rwrkpr[0]
#define YKM1		rwrkpr[1]

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
	InputRealPtrsType uPtrs=ssGetInputPortRealSignalPtrs(S,0);
	real_T *rwrkpr=ssGetRWork(S);

    real_T a0;
	real_T a1s,a0s,b1s,b0s;
	real_T omp,alfa,eps;
	real_T fnum,om;

	fnum=absval(*param_fnum);
	om=2.0*PI*fnum;

/*	parameters are (re)computed here to enable changes on-the-fly */

	eps=1.0e-16;
	omp=om+eps;
	alfa=omp/tan(omp*get_step_size(S)/2.0);

/*	continuous time parameters */

/*	a1=1; */
	a0=om;

/*	b1=1; */
/*	b0=0; */

/*	discrete time parameters (tustin with prewarping) */

	a1s=alfa+a0;
	a0s=-alfa+a0;

	b1s=alfa;
	b0s=-alfa;

/*	filter output */

	y[0]=1.0/b1s*(-b0s*YKM1+a1s*U(0)+a0s*UKM1);

/*	save history */

	UKM1=U(0);
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
