readonly TMOUT=900 ; export TMOUT

# This is to work around a bug in curl with https
# endpoints when using nss versions less than 3.52.
# Without this it creates many negative dentries
# each time it is called.
export NSS_SDB_USE_CACHE=no
