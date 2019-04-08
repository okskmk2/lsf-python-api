from pythonlsf import lsf
import enum


class JobStat(enum.Enum):
    PEND = lsf.JOB_STAT_PEND
    PSUSP = lsf.JOB_STAT_PSUSP
    RUN = lsf.JOB_STAT_RUN
    SSUSP = lsf.JOB_STAT_SSUSP
    USUSP = lsf.JOB_STAT_USUSP
    EXIT = lsf.JOB_STAT_EXIT
    DONE = lsf.JOB_STAT_DONE
    PDONE = lsf.JOB_STAT_PDONE
    PERR = lsf.JOB_STAT_PERR
    WAIT = lsf.JOB_STAT_WAIT
    RUNKWN = lsf.JOB_STAT_RUNKWN
    UNKWN = lsf.JOB_STAT_UNKWN
    PROV = lsf.JOB_STAT_PROV


def _convert_job_dict(job_into_ent):
    job_dict = dict()
    job_dict['job_id'] = job_into_ent.jobId
    job_dict['user_name'] = job_into_ent.user
    job_dict['queue_name'] = job_into_ent.submit.queue
    job_dict['job_status'] = _convert_job_status(job_into_ent.status)
    return job_dict


def get_job_ids_req(job_id=0, queue=None, host=None, user=lsf.ALL_USERS, project=None, status=lsf.ALL_JOB):
    """
    feature : Could search by projectName. but only fetch job_ids not job_ents
    :param job_id: 
    :param queue: 
    :param host: 
    :param user: 
    :param project: 
    :param status: 
    :return: 
    """
    job_info_req = lsf.jobInfoReq()
    job_info_req.options = status
    job_info_req.userName = user
    job_info_req.jobId = job_id
    job_info_req.queue = queue
    job_info_req.host = host
    job_info_req.projectName = project
    # jobInfoReq.licenseProjectName = "CSIM" # lic is alwalys none.
    job_info_head_ext = lsf.lsb_openjobinfo_req(job_info_req)
    job_info_head = job_info_head_ext.jobInfoHead
    for i in xrange(job_info_head.numJobs):
        print lsf.LS_LONG_INTArray_getitem(job_info_head.jobIds, i)


def get_jobs(job_id=0, job_name=None, user_name=lsf.ALL_USERS, queue_name=None, host_name=None,
             option=lsf.ALL_JOB):
    """
    Standard job_ent query function.
    :param job_id: 
    :param job_name: 
    :param user_name: 
    :param queue_name: 
    :param host_name: 
    :param option: 
    :return: 
    """
    job_cnt = lsf.lsb_openjobinfo(job_id, job_name, user_name, queue_name, host_name, option)
    more = lsf.new_intp()
    job_list = list()
    for _ in xrange(job_cnt):
        job_info = lsf.lsb_readjobinfo(more)
        job_list.append(_convert_job_dict(job_info))
    lsf.delete_intp(more)
    lsf.lsb_closejobinfo()
    return job_list


def _convert_job_status(status):
    if status & lsf.JOB_STAT_PEND:
        job_status = JobStat.PEND.name
    elif status & lsf.JOB_STAT_PSUSP:
        job_status = JobStat.PSUSP.name
    elif status & lsf.JOB_STAT_RUN:
        job_status = JobStat.RUN.name
    elif status & lsf.JOB_STAT_SSUSP:
        job_status = JobStat.SSUSP.name
    elif status & lsf.JOB_STAT_USUSP:
        job_status = JobStat.USUSP.name
    elif status & lsf.JOB_STAT_EXIT:
        job_status = JobStat.EXIT.name
    elif status & lsf.JOB_STAT_DONE:
        job_status = JobStat.DONE.name
    elif status & lsf.JOB_STAT_PDONE:
        job_status = JobStat.PDONE.name
    elif status & lsf.JOB_STAT_PERR:
        job_status = JobStat.PERR.name
    elif status & lsf.JOB_STAT_WAIT:
        job_status = JobStat.WAIT.name
    elif status & lsf.JOB_STAT_RUNKWN:
        job_status = JobStat.RUNKWN.name
    elif status & lsf.JOB_STAT_UNKWN:
        job_status = JobStat.UNKWN.name
    else:
        job_status = JobStat.UNKWN.name
    return job_status


if __name__ == '__main__':
    if lsf.lsb_init("test") != 0:
        raise Exception(lsf.lsb_sysmsg())
    jobs = get_jobs()  # fetch all
    for job in jobs:
        print job
