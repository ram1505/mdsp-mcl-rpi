# Prepare folders
export WORK_HOME=/home/pi/customAgentExample
mkdir $WORK_HOME
mkdir $WORK_HOME/build
mkdir $WORK_HOME/build/openssl
mkdir $WORK_HOME/build/curl
mkdir $WORK_HOME/build/mcl
mkdir $WORK_HOME/build/agent

# Download openssl and curl
cd $WORK_HOME
wget https://openssl.org/source/openssl-1.0.2q.tar.gz
wget https://curl.haxx.se/download/curl-7.52.1.tar.gz
tar -xvzf openssl-1.0.2q.tar.gz
tar -xvzf curl-7.52.1.tar.gz

# Build openssl
cd $WORK_HOME/openssl-1.0.2q
./config --openssldir=$WORK_HOME/build/openssl -Wl,-rpath=$WORK_HOME/build/openssl/lib shared -fPIC
make install

# Build curl
cd $WORK_HOME/curl-7.52.1
LDFLAGS="-Wl,-R$WORK_HOME/build/openssl/lib" ./configure --with-ssl=$WORK_HOME/build/openssl --prefix=$WORK_HOME/build/curl --disable-threaded-resolver
make install

# Build mcl
cd /home/pi
unzip MindConnect_Library_V3.1.2.0.zip -d $WORK_HOME
cd $WORK_HOME/MindConnect_Library_V3.1.2.0
cmake -DMCL_LOG_UTIL_LEVEL=LOG_UTIL_LEVEL_INFO -DMCL_CREATE_DOXYGEN=OFF -DCMAKE_PREFIX_PATH="$WORK_HOME/build/openssl;$WORK_HOME/build/curl" .
cmake --build . --target mc
mv $WORK_HOME/MindConnect_Library_V3.1.2.0/build/libmc.so $WORK_HOME/build/mcl
cp -r $WORK_HOME/MindConnect_Library_V3.1.2.0/include $WORK_HOME/build/mcl/include

# Build agent
cd $WORK_HOME/build/agent
gcc -Wall -I$WORK_HOME/build/mcl/include /home/pi/agent.c -o agent -L$WORK_HOME/build/mcl -Wl,-R$WORK_HOME/build/mcl -lmc
