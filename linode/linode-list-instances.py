#! /usr/bin/env python3
# 202106.03MeV
# uses linode's linode_api4 to crawl through linode's running instances
# extracts various info
#
# python3 and the linode_api4 library are required to run this tool
# uses region defined in awscli's credentials if not specified in REGION
# credentials file must be present with the region
# allows for jinja2 templating with -t <TEMPLATE> option

import argparse
import jinja2
import linode_api4
import os
import pprint
import sys

# shell expands '~' but you need to do it explicitly in python
TOKEN = os.environ.get('LINODE_TOKEN')
PROG = os.path.basename( sys.argv[0] )
DEFAULT_REGION = 'us-west'

def parse_arguments():
    """
    parse the argument list, build help and usage messages
    
    :param: None
    :return:
        a namespace with the arguments passed and their values
    """
    parser = argparse.ArgumentParser(
                description='list running AWS instance information')
    parser.add_argument('REGION',
                        action="store",
                        help='region to use for running Linode images [default: {}]'.format(DEFAULT_REGION),
                        # choices=regions_list(),   # don't use...don't like error output
                        nargs="?",
                        default=DEFAULT_REGION,
                        )
    parser.add_argument('-i', '--images',
                        action="store_true",
                        help='List the valid Linode images',
                        required=False
                        )
    parser.add_argument('-r', '--regions',
                        action="store_true",
                        help='List the valid Linode regions',
                        required=False
                        )
    parser.add_argument('-y', '--types',
                        action="store_true",
                        help='List the valid Linode Types',
                        required=False
                        )
    parser.add_argument('-t', '--template',
                        action="store",
                        help='JINJA2 template file to fill in with Linodes instance info',
                        required=False
                        )
    parser.add_argument('-v', '--verbose',
                        action="store_true",
                        help='show all the instance info',
                        required=False
                        )
    args = parser.parse_args()

    if args.template:   # passed a template filename?
        if not os.path.exists( args.template ):
            print('{} -- template file {} not found'.format(PROG, args.template))
            exit(1)
    #else:
    return args

def images_list():
    """
    list all Linode images

    :param: None
    :return: returns sorted list of image strings

    requires
        LINODE_TOKEN must be defined
    """
    client = linode_api4.LinodeClient(TOKEN)

    image_list = []
    for image in client.images():
        image_list.append(image.label + '  (' + image.id+')')
    return sorted(image_list)

def regions_list():
    """
    list all the valid Linode regions

    :param: None
    :return: returns sorted list of region strings

    requires
        LINODE_TOKEN must be defined
    """
    client = linode_api4.LinodeClient(TOKEN)

    region_list = []
    for region in client.regions():
        region_list.append(region.id)
    return sorted(region_list)

def regions_print(incr=5,tab='    '):
    """
    print the regions as a list of sort strings INCR number per line
    
    :param: incr -- int number of elements to print per line
    :param: tab -- string of spaces at beginning of line
    :return: returns None

    requires
        LINODE_TOKEN must be defined
    """
    start = 0; stop = incr
    valid_regions = regions_list()
    while start < len( valid_regions ):
        print('{}{}'.format(tab,' '.join(valid_regions[start:stop])))
        start = stop
        stop = stop + 5
    return None

def types_list():
    """
    list all Linode types

    :param: None
    :return: returns sorted list of type strings

    requires
        LINODE_TOKEN must be defined
    """
    client = linode_api4.LinodeClient(TOKEN)

    type_list = []
    for type in client.linode.types():
        type_list.append( type.id + '  (' + type.label + ')' )
    return sorted(type_list)

def valid_region(region):
    """
    check if a region is valid

    :param: region -- str of the region to check
    :return:
        returns True if region is in regions_list
        returns False if region is NOT in regions_list

    requires
        LINODE_TOKEN must be defined
    """
    valid_regions = regions_list()
    # do a simple "in" rather than bother with regex
    if region in valid_regions:
        return True
    else:
        return False

def descr_instances():
    """
    get the running linodes for the owner of the LINODE_TOKEN

    :param: None
    :return: dict{ImageID} -- all the instance attributes

    requires
        LINODE_TOKEN must be defined
    """
    # this returns dict with Images,Metadata keys
    # Images is a list of dicts containing each image's info
    client = linode_api4.LinodeClient(TOKEN)
    response = client.linode.instances( )
    # PaginatedList
    # convert into:
    instances = []       # - list of dict{Instances}
    for res in response:
        for ins in res:
            # add duplicate Tags from list of dict{Key,Value} to Tag_KEY: VALUE
            # which makes them easier to address
            # for t in ins['Tags']:   # iterate through tag dicts
            #     ins['Tag_{}'.format(t['Key'])] = t['Value']

            # add instance to list of instances to return
            instances.append(ins) 
    return instances

def dict_instances(RegionConfig):
    """
    get a region's running instances for the owner of the account

    :param RegionConfig: Config object which defines the region to query
    :return: dict{ImageID} -- all the instance attributes with ImageID as key
    """
    # this returns dict with Images,Metadata keys
    # Images is a list of dicts containing each image's info
    response = descr_instances()

    # list of dict{Reservations[dict{Group,Instances,OwnerId,ReservationId}], ResponseMetadata}
    # convert into:
    instance_id = []       # - list of dict{Instances}
    for ins in response:
        # insert instance into dict{InstanceID}
        instance_id[ ins['InstanceId'] ] = ins 
    return instance_id


def main():
    if not TOKEN:
        print('{} -- LINODE_TOKEN environment variable not defined'.format(PROG, TOKEN))
        return 1

    args = parse_arguments()

    # display regions
    if args.regions:
        print('{} -- valid regions:'.format(PROG))
        regions_print(incr=6)
        return 0

    # display types
    if args.types:
        print('{} -- valid Linode types:'.format(PROG))
        for t in types_list():
            print('     {}'.format(t))
        return 0

    # display types
    if args.images:
        print('{} -- valid Linode images:'.format(PROG))
        for i in images_list():
            print('     {}'.format(i))
        return 0

    # this will always contain a string with either the validated region provided
    # on the command line or the default region specified in the config file
    # which is why the config file must exist and contain a default region
    if args.REGION:
        # validate region (done here b/c don't like output of add_argument choices
        if not valid_region(args.REGION):
            print('{} -- "{}" REGION invalid...valid regions:'.format(PROG,args.REGION))
            regions_print(incr=6)
            return 1

        instance_list = descr_instances()
        if not instance_list:
            print('{} -- no instances found in {}'.format(PROG,args.REGION))
            return 0

        elif args.verbose:
            pprint.pprint(instance_list)
            return 0

        # convert list of dict with keys for template
        #   Reservations[ dict{Group,Instances,OwnerId,ReservationId} ], ResponseMetadata}
        # into list of strings with key fields
        # this needs to know the OS' supported as each has their own list
        # organized this way because each of these lists uses a different username to
        # access the AWS instance which is part of the template
        templ_alma = []
        templ_centos = []
        templ_debian  = []
        templ_ubuntu = []
        templ_unk = []

        # apparently jinja2 can't handle a lot of variables, so process each section
        for ins in instance_list:
            d = dict(
                region     = args.REGION,
                os         = ins['Tag_os'],
                name       = ins['Tag_Name'],
                ImageID    = ins['ImageId'],
                avz        = ins['Placement']['AvailabilityZone'],
                public_ip  = ins['PublicIpAddress'],
                dns        = ins['PublicDnsName']
            )
            if ins['Tag_os'] == 'alma8':
                templ_alma.append(d)
            elif ins['Tag_os'] == 'centos7' or ins['Tag_os'] == 'centos8':
                templ_centos.append(d)
            elif ins['Tag_os'] == 'debian9' or ins['Tag_os'] == 'debian10':
                templ_debian.append(d)
            elif ins['Tag_os'] == 'ubuntu16' or ins['Tag_os'] == 'ubuntu18' or \
            ins['Tag_os'] == 'ubuntu20':
                templ_ubuntu.append(d)
            else:
                templ_unk.append(d)

        # processed the region's AMIs, so fill in Jinja2 template
        # jinja2 can't deal with lots of variables, so do multiple sections
        if args.template:
            file_loader = jinja2.FileSystemLoader('.')
            env = jinja2.Environment(loader=file_loader)
            template = env.get_template(args.template)
            output = template.render(
                alma=templ_alma,
                centos=templ_centos,
                debian=templ_debian,
                ubuntu=templ_ubuntu,
                unk=templ_unk
                )
            # if args.output: print to output file else print to stout
            print(output)

        # or print them out
        else:
            if not args.verbose:
                dashes = 60*'-'
                try:
                    size = os.get_terminal_size()
                    print('{} {}'.format(dashes,'alma'))
                    pprint.pprint(templ_alma,width=size.columns)
                    print('{} {}'.format(dashes,'centos'))
                    pprint.pprint(templ_centos,width=size.columns)
                    print('{} {}'.format(dashes,'debian'))
                    pprint.pprint(templ_debian,width=size.columns)
                    print('{} {}'.format(dashes,'ubuntu'))
                    pprint.pprint(templ_ubuntu,width=size.columns)
                    print('{} {}'.format(dashes,'unk'))
                    pprint.pprint(templ_unk,width=size.columns)

                except OSError:     # likely can't get terminal info in debugging session
                    print('{} {}'.format(dashes,'alma'))
                    pprint.pprint(templ_alma,width=132)
                    print('{} {}'.format(dashes,'centos'))
                    pprint.pprint(templ_centos,width=132)
                    print('{} {}'.format(dashes,'debian'))
                    pprint.pprint(templ_debian,width=132)
                    print('{} {}'.format(dashes,'ubuntu'))
                    pprint.pprint(templ_ubuntu,width=132)
                    print('{} {}'.format(dashes,'unk'))
                    pprint.pprint(templ_unk,width=132)

        return 0


if __name__ == '__main__': sys.exit(main())
