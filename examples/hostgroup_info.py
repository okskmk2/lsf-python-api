

def get_hostgrp_info():
    """
    "query host group info"
    """
    if lsf.lsb_init("queryHostGroupInfo") != 0:
        exit(1)

    hostgrp_p = lsf.new_stringArray(2)
    lsf.stringArray_setitem(hostgrp_p, 0, "hg1")
    lsf.stringArray_setitem(hostgrp_p, 1, "hg2")
    for hgroupInfo in lsf.get_hostgroup_info_by_name(hostgrp_p, 2):
        if hgroupInfo is not None:
            print 'hgroup name = %s' % hgroupInfo.group
            print 'hgroup list = %s' % hgroupInfo.memberList


if __name__ == '__main__':
    get_hostgrp_info()
