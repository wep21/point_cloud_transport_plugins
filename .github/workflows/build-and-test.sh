#!/bin/bash
set -ev

# Configuration.
export COLCON_WS=~/ws
export COLCON_WS_SRC=${COLCON_WS}/src
export DEBIAN_FRONTEND=noninteractive
export ROS_PYTHON_VERSION=3

apt update -qq
apt install -qq -y lsb-release wget curl build-essential

# Dependencies.
echo "deb http://packages.ros.org/ros2-testing/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-testing.list
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
apt-get update -qq
apt-get install -y python3-colcon-common-extensions \
                   python3-rosdep python3-vcstool python3-vcstools

rosdep init
rosdep update
rosdep install --from-paths ./ -i -y -r --rosdistro $ROS_DISTRO $ROSDEP_ARGS

# Build.
source /opt/ros/$ROS_DISTRO/setup.bash
mkdir -p $COLCON_WS_SRC
cp -r $GITHUB_WORKSPACE $COLCON_WS_SRC
cd $COLCON_WS
echo $1
wget $1
vcs import src < point_cloud_transport.repos
rosdep install --from-paths ./ -i -y -r --rosdistro $ROS_DISTRO $ROSDEP_ARGS
colcon build --event-handlers console_direct+

# Tests.
colcon test --event-handlers console_direct+
colcon test-result
