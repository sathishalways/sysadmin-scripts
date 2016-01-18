### Yum Repository Mirror script

## Note
Create the exclude file directory: 
```
mkdir /etc/sync
```

Create the exclude file for CentOS (if required)
```
cat > /etc/sync/centos-exclude << EOF
2
2.*
3
3.*
4
4.*
EOF
```

## Editables
```
BASE - path where you want the repo
RSYNC - rsync mirror to use
```

## Run the script

To sync the CentOS mirror
```
sh yum-sync.sh centos
```

To sync the EPEL mirror
```
sh yum-sync.sh epel
```
