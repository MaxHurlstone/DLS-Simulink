
/*
	discrete time second order notch filter (Matlab 6 version)

	(c) Rene' van de Molengraft, 2002

	last update: February, 25th, 2003

	Inputs : u[0]     = signal to be filtered
	Outputs: y[0]     = notch-filtered signal

	Parameter: [f_num b_num f_den b_den] (frequency in Hz)
*/

#define S_FUNCTION_NAME dnotch
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define NSTATES		0
#define NINPUTS		1
#define NOUTPUTS	1
#define NPARAMS		5

#define NRWRK		4

#define PI		3.14159265358979

/* aliases for parameters */

#define F_NUM		ssGetSFcnParam(S,0)
#define B_NUM		ssGetSFcnParam(S,1)
#define F_DEN		ssGetSFcnParam(S,2)
#define B_DEN		ssGetSFcnParam(S,3)
#define STEPSIZE	ssGetSFcnParam(S,4)

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
		printf("dnotch: discete stepsize = %f s.\n",get_step_size(S));
#endif
	} else {
		ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
	        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
	}
}





static real_T absval(real_T x)
{
	if (x>=0) {
		return x;
	} else {
		return -x;
	}
}





static real_T minval(real_T x, real_T y)
{
	if (x<=y) {
		return x;
	} else {
		return y;
	}
}





static real_T maxval(real_T x, real_T y)
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
    const real_T *param_fden = mxGetPr(F_DEN);
    const real_T *param_bnum = mxGetPr(B_NUM);
    const real_T *param_bden = mxGetPr(B_DEN);
	InputRealPtrsType uPtrs=ssGetInputPortRealSignalPtrs(S,0);
	real_T *rwrkpr=ssGetRWork(S);

	real_T a2,a1,a0,b2,b1,b0;
	real_T om1,om2;
	real_T a2s,a1s,a0s,b2s,b1s,b0s;
	real_T omp,alfa,eps;
	real_T u;
	

/*	parameters are (re)computed here to enable changes on-the-fly */

	om1=2.0*PI*absval(*param_fnum);
	om2=2.0*PI*absval(*param_fden);

	eps=1.0e-16;
	/* omp=maxval(om1,om2)+eps; */
    omp=om1+eps;
	alfa=omp/tan(omp*get_step_size(S)/2.0);

/*	continuous-time parameters */

	a2=1.0*om2*om2;
	a1=2.0*absval(*param_bnum)*om1*om2*om2;
	a0=om1*om1*om2*om2;

	b2=1.0*om1*om1;
	b1=2.0*absval(*param_bden)*om2*om1*om1;
	b0=om2*om2*om1*om1;

/*	discrete time parameters (tustin with prewarping) */

	a2s=a2*alfa*alfa+a1*alfa+a0;
	a1s=-2*a2*alfa*alfa+2*a0;
	a0s=a2*alfa*alfa-a1*alfa+a0;

	b2s=b2*alfa*alfa+b1*alfa+b0;
	b1s=-2.0*b2*alfa*alfa+2*b0;
	b0s=b2*alfa*alfa-b1*alfa+b0;

/*	filter output */

	y[0]=1.0/b2s*(-b1s*YKM1-b0s*YKM2+a2s*U(0)+a1s*UKM1+a0s*UKM2);

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
