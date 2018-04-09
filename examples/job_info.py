from pythonlsf import lsf


def get_job_info():
    if lsf.lsb_init("test") != 0:
        exit(1)

    jobId = lsf.new_LS_LONG_INT()
    lsf.LS_LONG_INT.assign(jobId, 0)  # 0 for all
    jobName = None
    userName = None
    queueName = None
    hostName = None
    options = 0

    # open job
    num_job_record = lsf.lsb_openjobinfo(jobId, jobName, userName, queueName, hostName, 0)

    more = lsf.new_intp()
    lsf.intp_assign(more, num_job_record)

    job_list = list()
    for i in xrange(num_job_record):
        job_info = lsf.lsb_readjobinfo(more)
        job = dict()
        job['job_id'] = job_info.jobId
        job['user_name'] = job_info.user
        job['status'] = job_info.status
        job['directory'] = job_info.cwd
        job_list.append(job)

    # close job
    lsf.lsb_closejobinfo()


if __name__ == "__main__":
    print get_job_info()
