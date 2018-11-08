#!/bin/bash
#===============================================================================
# Title:       importToAgentEnv.sh
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
# Description: This is the environment file for the ICS Connectivity Agent
#              createKeystore.sh and importToAgent.sh scripts.  The contents of
#              this file should be updated to reflect your environment.
#
# Author:      Greg Mally
#
# Date:        31-October-2016
#
# Version:     1.0    
#
# Usage:       . ./importToAgentEnv.sh
#
# Notes:       The file name for JKS_FILENAME will be created in the same
#              directory where the certificates are located.  If this file
#              already exists, it will be removed prior to importing the
#              certificates.
#
#              The AGENT_KS_PASSWORD is set to a standard default value of
#              "changeit".  This value shouldn't be modified unless you know
#              exactly what you are doing.
#
#===============================================================================

export JAVA_HOME=/oracle/java/jdk1.7.0

export AGENT_HOME=/oracle/agenthome

export JKS_FILENAME=agentcerts.jks

# The following (changeit) is the default for the connectivity agent keystore
# DO NOT CHANGE
export AGENT_KS_PASSWORD=changeit
