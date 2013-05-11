virt-construct
==============

Automation script for virt-install and kickstart


###usage

	virt-construct.py [-h] [-c CONF] [-d KSDIR] [-b KSBASEURL] [-s] [-n]


###optional arguments

	-h, --help            show this help message and exit
	-c CONF, --conf CONF  Config file
	-d KSDIR, --ksDir KSDIR
	                        directory to place ks.cfg
	-b KSBASEURL, --ksBaseurl KSBASEURL
	                        baseurl for ks.cfg
	-s, --startvm         start vm after installed
	-n, --dryrun          exit after showing ks.cfg and virt-install options

