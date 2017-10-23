yum update -y
yum install -y git cmake gcc-c++ gcc python36-devel chrpath
cd /tmp
wget https://github.com/barisozcelik/aws-lambda-python-opencv/archive/master.zip
unzip master.zip
chmod 777 aws-lambda-python-opencv-master
cd aws-lambda-python-opencv-master
su -c './build.sh' ec2-user