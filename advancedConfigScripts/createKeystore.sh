#!/bin/bash
#===============================================================================
# Title:       createKeystore.sh
#
# Disclaimer:  This script is provided "AS IS" and without any official support
#              from Oracle. Its use needs to be performed using details from the
#              comments section and/or readme file (if one is included). Any bugs
#              encountered, feedback, and/or enhancement requests are welcome.
#
#              No liability for the contents of this script can be accepted. Use
#              the concepts, examples, and information at your own risk. However,
#              great care has been taken to ensure that all technical information
#              is accurate and as useful as possible.
#
#              Copyright © 2018, Oracle and/or its affiliates. All rights reserved.
#              The Universal Permissive License (UPL), Version 1.0
#
#
# Description: This script is used to create a keystore ($JKS_FILENAME) in the
#              certificates directory (-cd=...) containing all the certificates
#              that match the file pattern provided on the command-line (-cp=).
#              The details needed later for the import process (importToAgent.py)
#              are captured in the importToAgent.ini by this script.  This is
#              the first script to run in a two step process for importing the
#              certificates into the ICS Connectivity Agent keystore.
#
# Author:      Greg Mally
#
# Date:        31-October-2016
#
# Version:     1.0    
#
# Usage:       ./createKeystore.sh -cd=./certificates -cp=*.crt
#
# Notes:       The above usage assumes that this script has execute permission.
#              If it doesn't have execute permission, then add "bash" in front
#              of the command.  For example, bash ./createKeystore.sh ...
#
#              The details needed by importToAgent.py include things like
#              the list of certificate alias' in the keystore as well as the
#              associated password. This script will use the certificate file
#              name (less extension) as the alias and a default password defined
#              in the importToAgentEnv.sh (AGENT_KS_PASSWORD). These lists are
#              captured in the importToAgent.ini and look something like the
#              following:
#
#              keyAliases: root-VeriSignClass3-G5,intermediate-Symantec-G4,main-us
#              keyPasswords: changeit,changeit,changeit
#
#===============================================================================

. ./importToAgentEnv.sh

##################################################
# Process arguments
##################################################
for i in "$@"
do
case $i in
    -cd=*|--certificateDir=*)
    CERTS_DIR="${i#*=}"
    shift
    ;;
    -cp=*|--certificatePattern=*)
    CERTS_PATTERN="${i#*=}"
    shift
    ;;
    -jh=*|--javaHome=*)
    JAVA_HOME="${i#*=}"
    shift
    ;;
    --help)
    HELP=YES
    ;;
    *)
    # unknown option
    ;;
esac
done


##################################################
# Expand the use of ~ in the javaHome
##################################################
JAVA_HOME_EXPANDED=$(eval echo $JAVA_HOME)


##################################################
# Setup Variables
##################################################
export KEYTOOL=$JAVA_HOME_EXPANDED/bin/keytool
export KEYSTORE=$CERTS_DIR/$JKS_FILENAME


##################################################
# Make sure the keytool is available
##################################################
if [[ ! -f $KEYTOOL ]]; then
    echo "\"$KEYTOOL\" does not exist."
    echo "Please verify JAVA_HOME in importToAgentEnv.sh"
    echo "or override using -jh command-line option, exiting ..."
    exit 1
fi


##################################################
# Check for usage
##################################################
if [[ ( -z $CERTS_DIR ) || ( -z $CERTS_PATTERN ) || ( "$HELP" = "YES" ) ]]; then
    echo "usage: ./$0 -cd=PathToCertificates -cp=CertificateFilePattern [-jh=JavaJDKHome]"
    echo "For example, ./$0 -cd=~/certificates -cp=*.crt"
    exit 1
fi


##################################################
# Check for valid certificates directory
##################################################
if [[ ! -d $CERTS_DIR ]]; then
    echo "Directory \"$CERTS_DIR\" does not exist, exiting ..."
    exit 1
fi


##################################################
# Check for certificate files
##################################################
CERTS=$(ls $CERTS_DIR/$CERTS_PATTERN | xargs -n1 basename)

if [[ -z $CERTS ]]; then
    echo "No certificates found for \"$CERTS_DIR/$CERTS_PATTERN\", exiting ..."
    exit 1
fi


##################################################
# Check for existing keystore and remove
##################################################
if [[ -f $KEYSTORE ]]; then
    echo "Keystore \"$KEYSTORE\" already exists, removing ..."
    rm $KEYSTORE
fi


##################################################
# Loop through certificates and add to keystore
# and create variables for wlst ini file
##################################################
echo "Certificates will be added to $KEYSTORE"

ALIASES=""
KEYPASSES=""

for c in $CERTS
do
    ALIAS=$(echo $c | cut -f 1 -d '.')
    KEYTOOL_CMD="$KEYTOOL -importcert -trustcacerts -keystore $KEYSTORE -storepass $AGENT_KS_PASSWORD -keypass $AGENT_KS_PASSWORD -storetype JKS -alias $ALIAS -file $CERTS_DIR/$c"
    echo "Adding certificate $c"
    $KEYTOOL_CMD
    echo ""
    
    if [[ ! -z $ALIASES ]]; then
        ALIASES=$ALIASES","
        KEYPASSES=$KEYPASSES","
    fi
    
    ALIASES=$ALIASES$ALIAS
    KEYPASSES=$KEYPASSES$AGENT_KS_PASSWORD
done

##################################################
# Create importToAgent.ini
##################################################
echo "[ImportKeyStore]"                     >  importToAgent.ini
echo "appStripe: system"                    >> importToAgent.ini
echo "keystoreName: trust"                  >> importToAgent.ini
echo "keyAliases: $ALIASES"                 >> importToAgent.ini
echo "keyPasswords: $KEYPASSES"             >> importToAgent.ini
echo "keystorePassword: $AGENT_KS_PASSWORD" >> importToAgent.ini
echo "keystorePermission: true"             >> importToAgent.ini
echo "keystoreType: JKS"                    >> importToAgent.ini
echo "keystoreFile: $KEYSTORE"              >> importToAgent.ini


##################################################
# List all the certificates in the keystore
##################################################
$KEYTOOL -list -keystore $KEYSTORE -storepass $AGENT_KS_PASSWORD

echo ""
echo ""
echo ""
echo "Keystore ready for connectivity agent import: $KEYSTORE"
