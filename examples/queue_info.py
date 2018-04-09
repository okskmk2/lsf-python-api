#!/usr/bin/python

from pythonlsf import lsf


def query_queue(queue_name):
    """
    c api style
    """

    if lsf.lsb_init("test") != 0:
        exit(1)

    intp_num_queues = lsf.new_intp()
    lsf.intp_assign(intp_num_queues, 1)
    queue_p = lsf.new_stringArray(1)
    lsf.stringArray_setitem(queue_p, 0, queue_name)
    info = lsf.lsb_queueinfo(queue_p, intp_num_queues, None, None, 0)
    if info is not None:
        return info.queue, info.description
    else:
        print 'queueInfo is null'
        exit(1)


def queue_info(queue_name=None):
    """
    :param queue_name:
    :return:
    python api style
    """
    if lsf.lsb_init("test") != 0:
        exit(1)

    queue = lsf.new_stringArray(1)
    lsf.stringArray_setitem(queue, 0, queue_name)

    for info in lsf.get_queue_info_by_name(queue, 0):
        print info.queue
        print info.description
        print ''


if __name__ == '__main__':
    print("LSF Clustername is :", lsf.ls_getclustername())
    print(query_queue("normal"))
    queue_info()
