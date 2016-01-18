### Yum Repository Mirror scripts

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

Run the script! Edit BASE to change storage path. 
