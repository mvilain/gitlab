#! /usr/bin/env python3
# 202105.16MeV
# uses aws boto3 to crawl through AWS' marketplace and list instances for
# - centos7 almalinux (centos8 replacement)
# - debian9 debian10
# - ubuntu16.04 ubuntu18.04 ubuntu20.04
#
# python3 and the boto3 library are required to run this tool
# uses region defined in awscli's credentials if not specified in REGION
# credentials file must be present with the region and keys environment variables

import sys, os, re, argparse, datetime
import boto3, json, pprint, jmespath
from botocore.config import Config
# from jmespath import exceptions

# shell expands '~' but you need to do it explicitly in python
CRED = os.path.expanduser( '~/.aws/credentials' )
CONFIG = os.path.expanduser( '~/.aws/config' )
PROG = os.path.basename( sys.argv[0] )

# distro and ProductCode for each Gitlab-supported distros
DISTROS = dict(
    alma83     =  '2pag55a9fkn96t01w4zg0hjzx',
    centos79   =  'aw0evgkw8e5c1q413zgy5pjce',
    centos83   =  'ef6kit54bxdxm5ec5h7921duf',
    debian913  =  'wa59nhjens2s3nbfqlcjxiyy',
    debian107  =  'a8to8juz0snuukwdxuz7x3ol8',
    ubuntu1604 =  'a77pfe5qy4y0x0ovr82l3q0jt',
    ubuntu1804 =  '3iplms73etrdhxdepv72l6ywj',
    ubuntu2004 =  '9rxhntdy981dz5t3gbzpdd60w'
)

def parse_arguments(default_region):
    """
    parse the argument list, build help and usage messages
    
    :param default_region: string containing a valid default region (from config file)
    :return:
        a namespace with the arguments passed and their values
    """
    parser = argparse.ArgumentParser(
            description='display the AMI strings for Gitlab-supported virtual machines')
    parser.add_argument('REGION',
                        help='region to use for AMI images [default: {}]'.format(default_region),
                        default=default_region,
                        # choices=regions_list(), # don't use this...don't like the error output
                        nargs="?",
                        )
    parser.add_argument('-l', '--list',
                        help=('List the valid AWS regions'),
                        required=False,
                        action="store_true"
                        )
    args = parser.parse_args()
    return args


def regions_list():
    """
    list all the valid AWS regions as strings

    :param none:
    :return:
        returns sorted list of strings of regions

    requires
        credentials file to exist and have valid keys to make AWS query
        config file to exist and contain the default region
    """
    client = boto3.client( 'ec2' )
    response = client.describe_regions( )  # dict{ Regions, ResponseMetadata }
    valid_regions = []
    for r in response['Regions']: # list of dictionaries -> list of strings
        valid_regions.append(r['RegionName'])
    return sorted(valid_regions)


def regions_print(incr=5,tab='    '):
    """
    print the regions as a list of sort strings INCR number per line
    
    :param incr: int number of elements to print per line
    :param tab:  string of spaces at beginning of line
    :return:
        returns None
    """
    start = 0; stop = incr
    valid_regions = regions_list()
    while start < len( valid_regions ):
        print('{}{}'.format(tab,' '.join(valid_regions[start:stop])))
        start = stop
        stop = stop + 5
    return None


def valid_region(region):
    """
    check if a region is valid

    :param region: the region to check
    :return:
        returns True if region is valid
        returns False if region is invalid

    requires
        credentials file to exist and have valid keys to make AWS query
        config file to exist and contain the default region
    """
    valid_regions = regions_list()
    # do a simple "in" rather than bother with regex
    if region in valid_regions:
        return True
    else:
        return False

def date_convert(aws_date):
    """
    converts the aws CreationDate string (YYYY-MM-DDThh:mm:ss.000Z)
        into a datetime object
    :param aws_date: string in the form YYYY-MM-DDThh:mm:ss.000Z for AWS' CreationDate
    :return: a datetime object
    """
    return datetime.datetime.strptime(aws_date, '%Y-%m-%dT%H:%M:%S.000Z')


def desc_images(ProductCode,RegionConfig):
    """
    get all the Golden Image AMIs for a specific ProductCode

    :param ProductCode: string of the ProductCode for a vendor's images
    :param RegionConfig: Config object which defines the region to query
    :return: json object describing the AMIs and their attributes
    """
    client = boto3.client( 'ec2', config=RegionConfig )
    response = client.describe_images(
        Filters=[
            { 'Name': 'product-code', 'Values': [ ProductCode ] },
            { 'Name': 'product-code.type', 'Values': [ 'marketplace' ] }
        ],
        Owners=[ 'aws-marketplace' ]
        # DryRun=True|False
    ) # dict{Images(list of images)}
    return response


def main():
    # abort if no credentials to access AWS
    if not os.path.exists( CRED ):
        print('{} -- credentials file {} not found'.format(PROG, CRED))
        exit(1)
    if not os.getenv("AWS_ACCESS_KEY", default=None) or \
            not os.getenv("AWS_SECRET_KEY", default=None):
        print('{} -- AWS ACCESS KEY or AWS_SECRET_KEY not defined'.format(PROG))
        exit(1)

    # if config not found, exit with error
    if not os.path.exists( CONFIG ):
        print('{} -- config file {} not found'.format(PROG, CONFIG))
        exit(1)

    # search config for "^region = XXXXXX" and extract XXXX as default
    with open(CONFIG,'r') as config:    # don't bother with close() b/c used with
        config_lines = config.readlines()
        for l in config_lines:
            # extract region from config file...assumes region is a valid region
            if re.search(r'^region = ', l):
                default_region = re.sub(r'^region = ', '', l, flags=re.IGNORECASE).rstrip()

    args = parse_arguments(default_region)

    # display regions
    if args.list:  # 6 (default) at a time fits width=80
        print('{} -- valid regions:'.format(PROG))
        regions_print()
        return 0

    if args.REGION:
        # validate region (done here b/c don't like output of add_argument choices
        if not valid_region(args.REGION):
            print('{} -- "{}" REGION invalid...valid regions:'.
                  format(PROG,args.REGION))
            regions_print()
            return 1

        # create a Config object defining region to use with a boto3 client
        region_config = Config(
            region_name = args.REGION,
            signature_version = 'v4',
            retries = {
                'max_attempts': 10,
                'mode': 'standard'
            }
        )

        gold_ami = {}
        # scan region for Gold AMIs
        for distro,prodcode in DISTROS.items():
            print ('{}'.format(distro),end='...', flush=True)
            # this returns dict with Images,Metadata keys
            # Images is a list of dicts containing each images info
            images = desc_images(prodcode,region_config)    # describe_images for region

            # loop through each image dict which can have multiple entries
            # store entries in a list for each distro so it can be sorted
            distro_list = []
            for im in images['Images']:
            #     im.pop('Architecture', None)
            #     im.pop('BlockDeviceMappings', None)
            #   CreationDate form: YYYY-MM-DDThh:mm:ss.000Z
            #   Description
            #     im.pop('EnaSupport', None)
            #     im.pop('Hypervisor', None)
            #   ImageId
            #   ImageLocation
            #     im.pop('ImageOwnerAlias', None)
            #     im.pop('ImageType', None)
            #   Name
            #     im.pop('OwnerId', None)
            #     im.pop('PlatformDetails', None)
            #     im.pop('ProductCodes', None)
            #     im.pop('Public', None)
            #     im.pop('RootDeviceName', None)
            #     im.pop('RootDeviceType', None)
            #     im.pop('SriovNetSupport', None)
            #     im.pop('State', None)
            #     im.pop('UsageOperation', None)
            #     im.pop('VirtualizationType', None)
            #     print('{} {}'.format(60*'>',i['CreationDate']))
            #     pprint.pprint(im)
            #     print('{} {} end\n'.format(40*'-',distro))
                distro_list.append(
                    im['CreationDate'] + '|' + im['ImageId'] + '|' + im['Description']
                )
            # reverse sort and select newest version
            #   rather than using datetime objects
            # distro|CreationDate|ImageID|Description
            first = sorted( distro_list, reverse=True )[0]
            # split into fields
            newest = first.split('|')

            gold_ami[ distro ]  = \
                dict(
                    CreationDate = newest[0],
                    ImageID      = newest[1],
                    Description  = newest[2],
                    region       = args.REGION
                )

        print ('[done]',flush=True)
        # test for template...if true, process the template otherwise print
        size = os.get_terminal_size()
        pprint.pprint(gold_ami,width=size.columns)

        return 0


if __name__ == '__main__': sys.exit(main())
