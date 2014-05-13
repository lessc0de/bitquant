#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo mkdir -p /var/run/opengamma
sudo chmod a+rwx /var/run/opengamma

sudo mkdir -p /var/log/OG-RStats
sudo chmod a+rwx /var/log/OG-RStats

mkdir -p ~/etc/OpenGammaLtd

arch=$(test "$(uname -m)" = "x86_64" && echo "amd64" || echo "i386")

echo "jvmLibrary=/usr/lib/jvm/java-1.7.0/jre/lib/$arch/server/libjvm.so
jvmProperty.opengamma.configuraton.url=http://localhost:8080/jax/configuration/0/" > ~/etc/OpenGammaLtd/LanguageIntegration

echo "serviceExecutable=/home/joe/git/OG-PlatformNative/og-language/target/run/Debug/ServiceRunner
connectorLogConfiguration=/home/joe/git/OG-PlatformNative/og-language/src/package/ai/log4cxx.properties" > ~/etc/OpenGammaLtd/OpenGammaR

pushd  $SCRIPT_DIR/../../OG-PlatformNative
export MVN_ARGS="-Dmaven.test.skip=true"
export PATH=/home/joe/git/OG-PlatformNative:$PATH
cat <<EOF > exe-kill
#!/bin/bash
echo $*
EOF
chmod a+x exe-kill
ant configure -Dprofile.nix=true -Dtool.cpptasks=true 
# -Dtool.r=true
ant install -Dskip.tests=true
#pushd /home/joe/git/OG-PlatformNative/og-language/target/run/Debug
#./ServiceRunner run >& $SCRIPT_DIR/../web/log/ServiceRunner.log &
#popd
#sleep 10
pushd og-rstats/target/package
export OG_RSTATS_TARGET=../../../

# Without this the installation will try to put the R library in the
# system directories where it does not have permissions
mkdir -p ~/R/`uname -m`-mageia-linux-gnu-library/3.0
R CMD INSTALL OpenGamma --no-test-load
popd
popd
#killall ServiceRunner






