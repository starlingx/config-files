# TMOUT value will be updated to 900s by stx-puppet
# config.pp on runtime manifest or bootstrap.
export TMOUT=0

# This is to work around a bug in curl with https
# endpoints when using nss versions less than 3.52.
# Without this it creates many negative dentries
# each time it is called.
export NSS_SDB_USE_CACHE=no
