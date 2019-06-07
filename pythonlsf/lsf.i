/* 
* (C) Copyright IBM Corporation 2013
* 
* This library is free software; you can redistribute it and/or
* modify it under the terms of the Eclipse Public License.
* 
*/

/* File: lsf.i */
%module lsf
%include "cpointer.i"
%include "carrays.i"

FILE *fopen(char *filename, char *mode);
int fclose(FILE *f);

%{
#define SWIG_FILE_WITH_INIT
#include "lsf.h"
#include "lsbatch.h"
%}

//new_X, delete_X, X_assign X_value
%pointer_functions(int, intp)
%pointer_functions(float, floatp)
%pointer_functions(long, longp)
%pointer_functions(LS_LONG_INT, LS_LONG_INT_POINTER)

//new_X, delete_X, X_set_item, X_get_item...
%array_functions(int, intArray)
%array_functions(float, floatArray)
%array_functions(char *, stringArray)
%array_functions(struct dependJobs, dependJobsArray)
%array_functions(long, longArray)
%array_functions(LS_LONG_INT, LS_LONG_INTArray) // Eunsung Lee add 20190408
//%array_functions(struct _limitInfoEnt, limitInfoEntArray2); // Eunsung Lee add 20181205

// x_frompointer
%array_class(struct queueInfoEnt, queueInfoEntArray); //seg error(10.1) -> ok(9.1)
%array_class(struct groupInfoEnt, groupInfoEntArray); //Eunsung Lee add, seg error(10.1) -> ok(9.1)
%array_class(struct userInfoEnt, userInfoEntArray); //Eunsung Lee add, seg error(10.1) -> ok(9.1)
%array_class(struct hostInfo, hostInfoArray); // Eunsung Lee add 20190418
%array_class(struct hostInfoEnt, hostInfoEntArray); //ok
%array_class(struct hostLoad, hostLoadArray);
%array_class(struct shareAcctInfoEnt, shareAcctInfoEntArray); // Eunsung Lee add 20180419
%array_class(struct userShares, userSharesArray); // Eunsung Lee add 20181011
%array_class(struct resItem, resItemArray); // Eunsung Lee add 20181205
%array_class(struct _limitInfoEnt, limitInfoEntArray); // Eunsung Lee add 20181205
%array_class(struct _reasonRefEntry, reasonRefEntryArray); // Eunsung Lee add 20190531
%array_class(struct reasonRefStrTab, reasonRefStrTabArray); // Eunsung Lee add 20190531
%array_class(struct _lsb_reasonMsgConf, lsb_reasonMsgConfArray); // Eunsung Lee add 20190531
%array_class(struct _lsb_rsrcConf, lsb_rsrcConfArray); // Eunsung Lee add 20190531
%array_class(struct reasonRefString, reasonRefStringArray); // Eunsung Lee add 20190531


//helper function for transforming char** to python list
%inline %{
PyObject * char_p_p_to_pylist(PyObject* ptrobj, int size){
      void* cptr = 0;
      int res = 0;
      PyObject * list = 0;
      int i = 0;
      res = SWIG_ConvertPtr(ptrobj, &cptr,SWIGTYPE_p_p_char, 0);
      if (!SWIG_IsOK(res)) {
        PyErr_SetString(PyExc_TypeError,"not a SWIGTYPE_p_p_char");
        return NULL;
      }
      list = PyList_New(size);
      for (i = 0; i < size; i++) {
          PyList_SetItem(list,i,PyString_FromString(((char**)cptr)[i]));
      }
      return list;
}

PyObject * string_array_to_pylist(PyObject* ptrobj, int size){
    return char_p_p_to_pylist(ptrobj,size);
}
%}



// handle int arrays
%typemap(in) int [ANY] (int temp[$1_dim0]) {
  int i;
  for (i = 0; i < $1_dim0; i++) {
    PyObject *o = PySequence_GetItem($input,i);
      temp[i] = (int) PyInt_AsLong(o);
  }
  $1 = temp;
}

// See github issue 1
//%typemap(freearg) int [ANY] {
//  free((int *) $1);
//}

%typemap(out) int [ANY] {
  int i;
  $result = PyList_New($1_dim0);
  for (i = 0; i < $1_dim0; i++) {
    PyObject *o = PyLong_FromDouble((int) $1[i]);
    PyList_SetItem($result,i,o);
  }
}

// typemap for time_t
%typemap(in) time_t {
    $1 = (time_t) PyLong_AsLong($input);
}

%typemap(freearg) time_t {
    if ($1) free((time_t *) $1);
}

%typemap(out) time_t {
    $result = PyLong_FromLong((long)$1);
}

%typemap(arginit) time_t {
   $1 = 0;
}

/*
 The following routines are not wrapped because SWIG has issues generating
 proper code for them
 */

// Following are ignored from lsf.h

%ignore getBEtime;
%ignore ls_gethostrespriority;
%ignore ls_loadoftype;
%ignore ls_lostconnection;
%ignore ls_nioclose;
%ignore ls_nioctl;
%ignore ls_niodump;
%ignore ls_nioinit;
%ignore ls_niokill;
%ignore ls_nionewtask;
%ignore ls_nioread;
%ignore ls_nioremovetask;
%ignore ls_nioselect;
%ignore ls_niosetdebug;
%ignore ls_niostatus;
%ignore ls_niotasks;
%ignore ls_niowrite;
%ignore ls_placeoftype;
%ignore ls_readrexlog;
%ignore ls_verrlog;
%ignore lsb_globalpolicy;
%ignore lsb_jobidindex2str;
%ignore LOG_VERSION;
%ignore ls_errmsg;

// Following are ignored from lsbatch.h

%ignore lsb_readstatusline;

// Now include the rest...

%include "lsf.h"
%include "lsbatch.h"

%inline %{
PyObject * get_host_names() {
    struct hostInfo *hostinfo;
    char   *resreq;
    int    numhosts = 0;
    int    options = 0;

    resreq="";

    hostinfo = ls_gethostinfo(resreq, &numhosts, NULL, 0, options);

    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) {
        PyObject *o = PyString_FromString(hostinfo[i].hostName);
        PyList_SetItem(result,i,o);
    }

    return result;
}

PyObject * get_host_info() {
    struct hostInfo *hostinfo;
    char   *resreq;
    int    numhosts = 0;
    int    options = 0;

    resreq = "";

    hostinfo = ls_gethostinfo(resreq, &numhosts, NULL, 0, options);

    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostinfo[i]),
                                         SWIGTYPE_p_hostInfo, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

/* taken form stdio.h */
#define SEEK_SET    0   /* Seek from beginning of file.  */
#define SEEK_CUR    1   /* Seek from current position.  */
#define SEEK_END    2   /* Seek from end of file.  */
PyObject * lsb_fseek(PyObject *obj0, PyObject *obj1, PyObject *obj2){
  FILE *arg1 = (FILE *) 0 ;
  void *argp1 = 0 ;
  long val2 = 0 ;
  int val3 = 0 ;
  int res1 = 0 ;
  int res2 = 0 ;
  int res3 = 0 ;
  PyObject *resultobj = 0;
  int result;

  res1 = SWIG_ConvertPtr(obj0, &argp1,SWIGTYPE_p_FILE, 0 |  0 );
  if (!SWIG_IsOK(res1)) {
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "fseek" "', argument " "1"" of type '" "FILE *""'");
  }
  arg1 = (FILE *)(argp1);

  res2 = SWIG_AsVal_long(obj1, &val2 );
  if (!SWIG_IsOK(res2)) {
    SWIG_exception_fail(SWIG_ArgError(res2), "in method '" "fseek" "', argument " "2"" of type '" "long *""'");
  }

  res3 = SWIG_AsVal_int(obj2, &val3 );
  if (!SWIG_IsOK(res3)) {
    SWIG_exception_fail(SWIG_ArgError(res3), "in method '" "fseek" "', argument " "3"" of type '" "int *""'");
  }

  result = (int)fseek(arg1,val2,val3);
  resultobj = SWIG_From_int((int)(result));
  return resultobj;
fail:
  return NULL;
}

PyObject * lsb_ftell(PyObject *obj0){
  FILE *arg1 = (FILE *) 0 ;
  void *argp1 = 0 ;
  int res1 = 0 ;
  PyObject *resultobj = 0;
  long result;

  res1 = SWIG_ConvertPtr(obj0, &argp1,SWIGTYPE_p_FILE, 0 |  0 );
  if (!SWIG_IsOK(res1)) {
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "fseek" "', argument " "1"" of type '" "FILE *""'");
  }
  arg1 = (FILE *)(argp1);

  result = (long)ftell(arg1);
  resultobj = SWIG_From_long((long)(result));
  return resultobj;
fail:
  return NULL;
}

PyObject * get_load_of_hosts() {
    struct hostLoad *hostload;
    char   *resreq;
    int    numhosts = 0;

    resreq = "";

    hostload = ls_loadofhosts(resreq, &numhosts, 0, NULL, NULL, 0);

    PyObject *result = PyList_New(numhosts);
    int i;
    for (i = 0; i < numhosts; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostload[i]),
                                         SWIGTYPE_p_hostLoad, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

PyObject * get_host_load(char *resreq, int index) {
    struct hostLoad *hosts;

    int    numhosts = 0;

    int    options = 0;

    char   *fromhost = NULL;

    hosts = ls_load(resreq, &numhosts, options, fromhost);

    if (hosts == NULL || numhosts > 1) {
        ls_perror("ls_load");
        exit(-1);
    }

    PyObject *result = PyFloat_FromDouble(hosts[0].li[index]);
    return result;
}

// error(10.1) -> ok(9.1)
PyObject * get_queue_info_by_name(char** name, int num) {
    struct queueInfoEnt* queueinfo;
    int    numqueues = num;
    int    options = 0;

    queueinfo = lsb_queueinfo(name, &numqueues, NULL, 0, options);

    PyObject *result = PyList_New(numqueues);
    int i;
    for (i = 0; i < numqueues; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&queueinfo[i]),
                                         SWIGTYPE_p_queueInfoEnt, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

// ok
PyObject * get_hostgroup_info_by_name(char** name, int num) {
    struct groupInfoEnt* hostgroupinfo;
    int    numgroups = num;
    int    options = 0;

    hostgroupinfo = lsb_hostgrpinfo(name, &numgroups, options);

    PyObject *result = PyList_New(numgroups);
    int i;
    for (i = 0; i < numgroups; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostgroupinfo[i]),
                                         SWIGTYPE_p_groupInfoEnt, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

PyObject * get_conf_value(char *name, char *path) {
    struct config_param param[2];
    param[0].paramName = name;
    param[0].paramValue = NULL;
    param[1].paramName = NULL;
    param[1].paramValue = NULL;
    if (ls_readconfenv(&param[0],path) == 0) {
        return Py_BuildValue("s", param[0].paramValue);
    } else {
        Py_RETURN_NONE;
    }
}

// custom --

// added -> error(10.1) -> ok(9.1) by Eunsung Lee
PyObject * get_user_info_by_name(char** name, int num) {
    struct userInfoEnt* userinfo;
    int    numUsers = num;

    userinfo = lsb_userinfo(name, &numUsers);

    PyObject *result = PyList_New(numUsers);
    int i;
    for (i = 0; i < numUsers; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&userinfo[i]),
                                         SWIGTYPE_p_userInfoEnt, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

// added by Eunsung Lee
PyObject * get_host_info_by_name(char** name, int num) {
    struct hostInfoEnt* hostinfo;
    int    numHosts = num;

    hostinfo = lsb_hostinfo(name, &numHosts);

    PyObject *result = PyList_New(numHosts);
    int i;
    for (i = 0; i < numHosts; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&hostinfo[i]),
                                         SWIGTYPE_p_hostInfoEnt, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}



// add -> ok
PyObject * get_usergroup_info_by_name(char** name, int num) {
    struct groupInfoEnt* usergroupinfo;
    int    numgroups = num;
    int    options = 0;

    usergroupinfo = lsb_usergrpinfo(name, &numgroups, options);

    PyObject *result = PyList_New(numgroups);
    int i;
    for (i = 0; i < numgroups; i++) {
        PyObject *o = SWIG_NewPointerObj(SWIG_as_voidptr(&usergroupinfo[i]),
                                         SWIGTYPE_p_groupInfoEnt, 0 |  0 );
        PyList_SetItem(result,i,o);
    }

    return result;
}

int requeue_job(LS_LONG_INT job_id) {
    struct jobrequeue jobrequeuereq;

    jobrequeuereq.jobId = job_id;
    jobrequeuereq.status = JOB_STAT_PEND;
    jobrequeuereq.options = REQUEUE_DONE | REQUEUE_EXIT;
    return lsb_requeuejob(&jobrequeuereq);
}

//int get_limitInfo(limitInfoReq *req,  limitInfoEnt *limitItemRef, struct lsInfo* lsInfo) {
//    int *size;
//    // limitItemRef // <- pointer pointer by int*
//    result = lsb_limitInfo(&req, limitInfoEnt **limitItemRef, &size, &lsInfo)
//}

%}
