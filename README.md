# Hipsgen-S3
A combination of the Hipsgen and mountpoint-s3 libraries that enables building Skybackgrounds from an S3 sources

### Hipsgen
[Hipsgen](https://aladin.cds.unistra.fr/hips/HipsIn10Steps.gml) is a software package dedicated to generating a Hierarchical Progressive Survey, or HiPS, from a set of images, also known as a "sky survey". A HiPS is both a format and a protocol for viewing astronomical data, based on a hierarchical "tiling" that allows zooming and moving through astronomical images represented as a coherent entity. It is defined in an international IVOA standard "HiPS 1.0".

### mountpoint-s3 
[Mountpoint for Amazon S3](https://github.com/awslabs/mountpoint-s3) is a high-throughput open source file client for mounting an Amazon S3 bucket as a local file system. With Mountpoint, your applications can access objects stored in Amazon S3 through file system operations, such as open and read. Mountpoint automatically translates these operations into S3 object API calls, giving your applications access to the elastic storage and throughput of Amazon S3 through a file interface.

# Requirements 
- [Docker](https://www.docker.com/)
- ample free time (the program takes a while to run) 

# Running Hipsgen against an s3 bucket 
In this example, we will walk through running hipsgen against a subset of the files stored in STSci's Panstarrs DS1 dataset in the AWS open data bucket.

1. Build the docker container
In order to use this tool, you must first build a docker container off of the provided Dockerfile.
```zsh
docker build -t hipsgen-s3 .
```

2. Run the docker container
You will then need to run your docker container. The command below will automatically enter you into a bash terminal inside of the docker container 
```zsh
docker run -ti --cap-add SYS_ADMIN --devoce /dev/fuse --entrypoint bash hipsgen-s3
```

3. Run the startup script
From within the container, run the startup script. This will mount the STScI Panstarrs DS1 dataset onto the containers local file system. It will also download the most recent version of Hipsgen from CDS
```bash
./startup.sh
```

4. Index the data 
Hipsgen has various steps that it runs, the first of which is INDEX, which creates a map of all of the files in the directory structure we are pointing at. We run this separate so that we can modify the results to filter out any unrelated files that happen to be in the folder(s) we are indexing. 
```bash
java -jar Hipsgen.jar in="mnt/ps1/public/rings.v3.skycell/2381/053" out="/data/hips" INDEX order=9 id=test -nice -d
```

5. Filter the generated index
Currently the below command will filter out all but the `i`, `r`, and `g`, detectors. Future updates will make the filter regex configurable.
```bash
./filter.sh /data/hips/HpxFinder/Norder9
```

6. Run the rest of the Hipsgen commands 
At this point, all manual intervention is done and you simply need the run the rest of the Hipsgen commands in order
```bash
java -jar Hipsgen.jar in="mnt/ps1/public/rings.v3.skycell/2381/053" out="/data/hips" TILES order=9 id=test -nice -d

java -jar Hipsgen.jar in="mnt/ps1/public/rings.v3.skycell/2381/053" out="/data/hips" PNG order=9 id=test -nice -d

java -jar Hipsgen.jar in="mnt/ps1/public/rings.v3.skycell/2381/053" out="/data/hips" CHECKCODE order=9 id=test -nice -d

java -jar Hipsgen.jar in="mnt/ps1/public/rings.v3.skycell/2381/053" out="/data/hips" DETAILS order=9 id=test -nice -d
```

7. Verify success 
Currently, the docker container does not support port forwarding, so we need to download the Hipsgen results to view them. 

From docker desktop, navigate to `Container` -> `hipsgen-s3` -> `files`. Download the `data/hips` directory to your local machine.

Open the downloaded directory in cmdline and run `npx serve . --cors`. This will allow you to launch `http://localhost:3000` which will take you to an aladin-lite instance with your newly generated Skybackground. It will be mostly empty since we only generated a subset, so navigate to `10 13 21.24 +23 02 06.5` to see your generated tiles. 


# Roadmap
- custom regex filtering of INDEX results
- port forwarding so that the server can be launched from docker and viewed on your local machine 
- example hipsgen with better resolution and use of Hipsgen color flags 

