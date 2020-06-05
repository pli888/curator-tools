# curator-tools

Commands for testing download bash script:

```
# Go to bin directory
$ cd bin
# Use test data
$ ./run.sh -V -f ../test/data/test-urls.txt 2>&1 | tee download.log

# Use real URLs to test download of author's data files
$ ./run.sh -V -f ../test/data/real-urls.txt 2>&1 | tee download.log
```

Use `nohup` command to run bash script for downloading the real files and continue running it when session is disconnected:
```
# Go to bin directory
$ cd bin
# The "&" symbol tells bash to run bash script in background
$ nohup ./run.sh -V -f ../data/S3ObjectListUrl-1.txt 2>&1 | tee download.log &

# Check download process is running
$ ps -F -u peter
```
