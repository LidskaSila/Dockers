#!/bin/sh
# ---------------------------------------------------------------------
# TeamCity Java search script
# ---------------------------------------------------------------------
# Environment variables:
# $* optional: any additional directories for JVM discovery
# ---------------------------------------------------------------------
scan_directory () {
for args in $*
do
  echo "Looking for Java in '$args'"
  JAVA_EXEC_TOP=`find -L "$args" -name java -type f -perm -u=rx 2>/dev/null|sort|head -n 1`
  if [ -f "$JAVA_EXEC_TOP" ]; then
    JAVA_EXEC=$JAVA_EXEC_TOP
    return 0
  fi
  done
  return 1
}

find_java () {

darwin=false
case "`uname`" in
Darwin*) darwin=true;;
esac

# Make sure prerequisite environment variables are set
if [ -z "$JAVA_HOME" -a -z "$JRE_HOME" ]; then

  # Mac OS X
  if $darwin; then
    # Try java_home utility first
    candidate=`/usr/libexec/java_home`
    if [ -d "$candidate" -a -x "$candidate/bin/java" ]; then
      JRE_HOME=$candidate
    # Fallback on Mac if java_home didn't work
    elif [ -x "/System/Library/Frameworks/JavaVM.framework/Home/bin/java" ]; then
      JRE_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
    fi
  fi

  # Not Mac OS X or Mac OS X searcher failed
  if [ -z "$JRE_HOME" ]; then
   # try to find java executable
   JAVA_EXEC=`which java 2>/dev/null|tee`

   # On Solaris `which java` may return something like 'no java in /opt/csw/bin /usr/xpg4/bin /usr/sbin /usr/bin /usr/ucb' without error code
   if [ -z "$JAVA_EXEC" -o ! -f "$JAVA_EXEC" ]; then
     # looking into predefined directories
     scan_directory "$*" ;
     if [ $? -eq 0 ]; then
       JRE_HOME=`dirname $JAVA_EXEC|tee`/..
     fi
   else
     JRE_HOME=`dirname $JAVA_EXEC|tee`/..
   fi
  fi

elif [ -z "$JRE_HOME" ]; then
  # JAVA_HOME set only
  JRE_HOME=$JAVA_HOME

fi

# Report status
if [ -z "$JRE_HOME" ]; then
  echo "Java executable is not found:"
  echo " - Neither the JAVA_HOME nor the JRE_HOME environment variable is defined"
  echo " - JVM is not found in paths"
  if [ -n "$*" ]; then
    echo " - JVM is not found under predefined '$*' directories"
  fi
  echo "Please make sure one of the environment variables is defined and is pointing to valid Java (JRE) installation, then run again"
  return 1
else
  echo "Java executable is found in '$JRE_HOME'."
  export JRE_HOME
  return 0
fi

}
