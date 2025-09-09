echo "making mount subdirectory"
mkdir mnt/ps1

echo "mounting database to mount subdirectory"
mount-s3 s3://stpubdata/panstarrs/ps1/ mnt/ps1/ --no-sign-request

echo "downloading hipsgen"
curl https://aladin.cds.unistra.fr/java/Hipsgen.jar -O